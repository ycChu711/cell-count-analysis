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
├── plots/
│   ├── all_populations_boxplot.png       
│   ├── b_cell_boxplot.png                
│   ├── cd8_t_cell_boxplot.png
│   ├── cd4_t_cell_boxplot.png
│   ├── nk_cell_boxplot.png
│   └── monocyte_boxplot.png
└── documentation/
    └── project_documentation.md # Detailed project analysis and answers
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

## Project Documentation

For detailed information about this project, including:
- Answers to project questions
- Analysis of cell population differences
- Database schema explanation and advantages
- SQL query examples and results

Please refer to the [Project Documentation](doc/project_doc.md).

## Key Findings

The statistical analysis reveals significant differences in cell population frequencies between responders and non-responders, particularly in:

- CD4+ T cells: Higher in responders (36.33% vs 26.33%, p=0.0095)
- Monocytes: Higher in non-responders (not statistically significant)

These findings suggest potential biomarkers for predicting response to treatment `tr1` in melanoma patients.

## Database Schema

The database schema provided in `db_schema.sql` is designed for scalability with:

- Normalized tables for projects, subjects, samples, and cell counts
- Junction tables for many-to-many relationships
- Indexes for optimized queries
- Views for common analysis patterns

## License

[MIT License](LICENSE)