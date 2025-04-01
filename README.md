# Cell Count Analysis Project

This project analyzes immune cell counts from patient samples, focusing on comparing responders and non-responders to treatment `tr1` in melanoma patients. The project includes Python scripts for data processing and visualization, as well as a database schema design for scalable data management.

## Project Structure

```
cell-count-analysis/
├── README.md                  
├── data/
│   └── cellcount.csv          # Input data file
├── src/
│   ├── process_cell_counts.py # Main Python script
│   └── db_schema.sql          # Database schema design
├── output/
│   ├── cell_percentages.csv   # Processed cell count data
│   └── statistical_results.csv # Statistical analysis results
└── plots/
    ├── all_populations_boxplot.png       
    ├── b_cell_boxplot.png                
    ├── cd8_t_cell_boxplot.png
    ├── cd4_t_cell_boxplot.png
    ├── nk_cell_boxplot.png
    └── monocyte_boxplot.png
```

## Requirements

- Python 3.8 or higher
- Required Python packages:
  - pandas
  - numpy
  - matplotlib
  - seaborn
  - scipy

You can install the required packages using:

```bash
pip install -r requirements.txt
```

## How to Run

1. Clone the repository:

```bash
git clone https://github.com/ycChu711/cell-count-analysis.git
cd cell-count-analysis
```

2. Ensure the input data file `cell-count.csv` is in the `data/` directory.

3. Run the analysis script:

```bash
python src/process_cell_counts.py
```

This will:
- Process the cell count data
- Generate the output CSV file with cell percentages
- Create boxplot visualizations
- Perform statistical analysis
- Save results to the appropriate output files

## Data Processing Details

The script performs the following operations:

1. **Cell Count to Percentage Conversion**:
   - Reads the input CSV file
   - Calculates total cell count for each sample
   - Computes the percentage of each cell population
   - Outputs a CSV file with sample, total count, population, count, and percentage

2. **Boxplot Visualization**:
   - Filters data for treatment `tr1`, melanoma condition, and PBMC samples
   - Creates boxplots comparing responders vs. non-responders for each cell population
   - Saves individual boxplots for each cell type and a combined visualization

3. **Statistical Analysis**:
   - Performs t-tests to identify significant differences between responders and non-responders
   - Calculates mean and standard deviation for each group
   - Outputs results to a CSV file

## Database Schema

The database schema provided in `db_schema.sql` is designed for scalability with:

- Normalized tables for projects, subjects, samples, and cell counts
- Junction tables for many-to-many relationships
- Indexes for optimized queries
- Views for common analysis patterns

### Schema Structure:
- **Projects Table**: Stores project metadata
- **Subjects Table**: Stores subject demographic information
- **Conditions Table**: Stores disease conditions
- **Treatments Table**: Stores treatment information
- **Samples Table**: Stores sample metadata
- **Cell Types Table**: Stores cell type definitions
- **Cell Counts Table**: Stores individual cell counts per sample and cell type

### Database Advantages:
1. **Data Integrity**: Enforces relationships between entities
2. **Scalability**: Handles large volumes of data from multiple projects
3. **Efficiency**: Optimized for complex queries with indexes
4. **Flexibility**: Supports different analysis types and data dimensions
5. **Reproducibility**: Preserves data provenance and analysis parameters
6. **Collaboration**: Enables concurrent access for multiple researchers

## Query Examples

The project includes SQL queries for:
1. Counting subjects per condition
2. Finding melanoma PBMC baseline samples with treatment `tr1`
3. Breaking down samples by project, response status, and gender

## Statistical Findings

The statistical analysis reveals significant differences in cell population frequencies between responders and non-responders, particularly in:

- CD4+ T cells: Higher in responders
- Monocytes: Higher in non-responders

These findings suggest potential biomarkers for predicting response to treatment `tr1` in melanoma patients.

## License

[MIT License](LICENSE)