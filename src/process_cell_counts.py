import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import os

CELL_COLS = ['b_cell', 'cd8_t_cell', 'cd4_t_cell', 'nk_cell', 'monocyte']
RESPONSE_MAP = {'y': 'Responder', 'n': 'Non-responder'}
INPUT_FILE = 'data/cell-count.csv'
OUTPUT_DIR = 'output'
PLOT_DIR = 'plots'

plt.style.use('ggplot')
sns.set_palette("Set2")

def get_filtered_data(df):
    """
    Filter data for tr1, PBMC, melanoma, and y/n responses
    
    Parameters:
    df (pd.DataFrame): input data
    
    Returns:
    pd.DataFrame: filtered data
    """
    return df[(df['treatment'] == 'tr1') & 
              (df['sample_type'] == 'PBMC') &
              (df['condition'] == 'melanoma') &
              df['response'].isin(['y', 'n'])].copy()

def calculate_percentages(df, cell_columns=CELL_COLS):
    """
    Calculate total cell counts and percentages for each cell type
    
    Parameters:
    df (pd.DataFrame): input data
    cell_columns (list): list of cell column names
    
    Returns:
    pd.DataFrame: data with percentage columns
    """

    if 'total_count' not in df.columns:
        df.loc[:, 'total_count'] = df[cell_columns].sum(axis=1)
    
    for col in cell_columns:
        df.loc[:, f'{col}_percent'] = ((df[col] / df['total_count']) * 100).round(2)
    
    return df

def process_cell_counts(input_file=INPUT_FILE, output_file=f'{OUTPUT_DIR}/processed_cell_counts.csv'):
    """
    Process cell count data, calculate percentages and create output file
    
    Parameters:
    input_file(str): path to input csv 
    output_file(str): path to output csv
    
    Returns:
    pd.DataFrame: data with processed data
    """
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    df = pd.read_csv(input_file)

    df = calculate_percentages(df)
    
    # new dataframe to store the results
    result_df = df[['sample', 'total_count']].copy()
    
    # all count col
    for population in CELL_COLS:
        result_df[population] = df[population]
    
    # all percentage col
    for population in CELL_COLS:
        result_df[f'{population}_percent'] = df[f'{population}_percent']
    
    result_df.to_csv(output_file, index=False)
    print(f"Processed data saved to {output_file}")
    
    return result_df

def create_boxplots(df, output_dir=PLOT_DIR):
    """
    Create boxplots comparing responders vs nonresponders for tr1 treatment
    
    Parameters:
    df (pd.DataFrame): input data with cell count data
    output_dir (str): directory to save plots
    
    Returns: None
    """
    os.makedirs(output_dir, exist_ok=True)

    filtered_df = get_filtered_data(df)
    filtered_df = calculate_percentages(filtered_df)
    
    filtered_df.loc[:, 'response_label'] = filtered_df['response'].map(RESPONSE_MAP)
    
    # combined plot
    melted_df = pd.melt(filtered_df, 
                        id_vars=['sample', 'response_label'],
                        value_vars=[f'{col}_percent' for col in CELL_COLS],
                        var_name='cell_type', 
                        value_name='percentage')
    
    
    melted_df.loc[:, 'cell_type'] = melted_df['cell_type'].str.replace('_percent', '')
    
    
    plt.figure(figsize=(12, 8))
    sns.boxplot(x='cell_type', y='percentage', hue='response_label', data=melted_df)
    plt.title('Cell Population Percentages: Responders vs Non-responders')
    plt.xlabel('Cell Type')
    plt.ylabel('Percentage (%)')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/all_populations_boxplot.png')
    plt.close()
    
    # individual plots
    for col in CELL_COLS:
        plt.figure(figsize=(8, 6))
        sns.boxplot(x='response_label', y=f'{col}_percent', data=filtered_df)
        plt.title(f'{col.replace("_", " ").title()} Percentage: Responders vs Non-responders')
        plt.xlabel('Response Status')
        plt.ylabel('Percentage (%)')
        plt.tight_layout()
        plt.savefig(f'{output_dir}/{col}_boxplot.png')
        plt.close()
    
    print(f"Boxplots saved to {output_dir}")

def perform_statistical_analysis(df, output_file=f'{OUTPUT_DIR}/statistical_results.csv'):
    """
    Perform statistical analysis to identify significant differences
    between responders and non-responders.
    
    Parameters:
    df (pd.DataFrame): input data with cell count
    output_file (str): file to csv output
    
    Returns:
    pd.DataFrame: data with statistical test results
    """
   
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    filtered_df = get_filtered_data(df)
    filtered_df = calculate_percentages(filtered_df)
    
    # group by response
    responders = filtered_df[filtered_df['response'] == 'y']
    non_responders = filtered_df[filtered_df['response'] == 'n']
    
    # perform t-tests
    results = []
    for col in CELL_COLS:
        percent_col = f'{col}_percent'
        
        resp_values = responders[percent_col].values
        nonresp_values = non_responders[percent_col].values
        
        t_stat, p_value = stats.ttest_ind(resp_values, nonresp_values, equal_var=False)
        
        resp_mean = round(responders[percent_col].mean(), 2)
        nonresp_mean = round(non_responders[percent_col].mean(), 2)
        resp_std = round(responders[percent_col].std(), 2)
        nonresp_std = round(non_responders[percent_col].std(), 2)
        
        t_stat = round(t_stat, 4)
        p_value = round(p_value, 4)
        
        results.append({
            'population': col,
            'responder_mean': resp_mean,
            'responder_std': resp_std,
            'non_responder_mean': nonresp_mean,
            'non_responder_std': nonresp_std,
            't_statistic': t_stat,
            'p_value': p_value,
            'significant': p_value < 0.05
        })
    
    result_df = pd.DataFrame(results)
    
    print("\nStatistical Analysis Results:")
    print("=============================")
    for _, row in result_df.iterrows():
        pop = row['population'].replace('_', ' ').title()
        sig_str = "Significant" if row['significant'] else "Not significant"
        
        print(f"{pop}:")
        print(f"  Responders: {row['responder_mean']:.2f}% ± {row['responder_std']:.2f}%")
        print(f"  Non-Responders: {row['non_responder_mean']:.2f}% ± {row['non_responder_std']:.2f}%")
        print(f"  T-statistic: {row['t_statistic']:.4f}, p-value: {row['p_value']:.4f} ({sig_str})")
        print()
    
    result_df.to_csv(output_file, index=False)
    print(f"Statistical results saved to {output_file}")
    
    return result_df

def main():
    # Part 1: process cell counts and generate output CSV
    process_cell_counts()
    
    # part 2
    df = pd.read_csv(INPUT_FILE)
    
    # Calculate total counts and percentages
    df = calculate_percentages(df)
    
    # Part 2a: create boxplots comparing responders vs non-responders
    create_boxplots(df)
    
    # part 2b: perform statistical analysis
    perform_statistical_analysis(df)
    
    print("\nAnalysis complete.")

if __name__ == "__main__":
    main()