# Cell Count Analysis Project - Documentation

## Project Questions and Answers

### Python Analysis

#### Question 1: Cell Count Conversion
The program successfully converts cell counts to relative frequencies. The implementation in `process_cell_counts.py` calculates the total count for each sample and then computes percentages for each cell population.

Key implementation details:
- Total cell count calculation: `df.loc[:, 'total_count'] = df[cell_columns].sum(axis=1)`
- Percentage calculation: `df.loc[:, f'{col}_percent'] = ((df[col] / df['total_count']) * 100).round(2)`
- Output file creation with required columns in `process_cell_counts()` function

#### Question 2a: Boxplot Comparisons
The program generates boxplots comparing responders vs. non-responders for each cell population. Visualization is implemented in the `create_boxplots()` function, which:
- Filters data for treatment tr1, melanoma condition, and PBMC samples
- Creates both individual boxplots for each cell type and a combined visualization
- Uses seaborn for enhanced visualization aesthetics

#### Question 2b: Statistical Analysis
Statistical analysis is performed in the `perform_statistical_analysis()` function, which:
- Compares responder and non-responder groups using t-tests
- Calculates mean and standard deviation for each group
- Outputs results to a CSV file for reference

Findings:
- CD4+ T cells show a statistically significant difference (p=0.0095) between responders (36.33%) and non-responders (26.33%)
- Other cell populations (B cells, CD8+ T cells, NK cells, monocytes) did not show statistically significant differences
- Monocytes appear to be higher in non-responders (22.67% vs 8.00% in responders) but the difference is not statistically significant (p=0.1998)

### Database Design

#### Question 1: Database Schema Design
The database schema design in `db_schema.sql` is comprehensive and normalized. It includes:

- **Core Tables**:
  - `projects`: Stores project metadata
  - `subjects`: Stores subject demographic information
  - `conditions`: Stores disease conditions
  - `treatments`: Stores treatment information
  - `samples`: Stores sample metadata
  - `cell_types`: Stores cell type definitions
  - `cell_counts`: Stores individual cell counts per sample and cell type

- **Junction Tables**:
  - `subject_conditions`: Maps subjects to conditions
  - `subject_projects`: Maps subjects to projects
  - `treatment_subjects`: Maps subjects to treatments

The schema supports the capture of all information in cell-count.csv and allows for scalability to hundreds of projects and thousands of samples.

#### Question 2: Database Advantages
The advantages of using a database for this data include:

1. **Data Integrity**: Enforces relationships between entities (foreign keys)
2. **Scalability**: Can handle large volumes of data from multiple projects
3. **Efficient Queries**: Optimized for complex queries with indexes
4. **Flexibility**: Supports different types of analyses and data dimensions
5. **Reproducibility**: Preserves data provenance and analysis parameters
6. **Collaboration**: Enables concurrent access for multiple researchers
7. **Standardization**: Enforces consistent data structure and terminology

#### Question 3: Query for Subjects per Condition
The query to summarize the number of subjects available for each condition is:

```sql
SELECT 
    c.condition_name,
    COUNT(DISTINCT sc.subject_id) AS subject_count
FROM conditions c
JOIN subject_conditions sc ON c.condition_id = sc.condition_id
GROUP BY c.condition_name
ORDER BY subject_count DESC;
```

#### Question 4: Query for Melanoma PBMC Samples
The query to return all melanoma PBMC samples at baseline from patients who have treatment tr1 is:

```sql
SELECT 
    s.sample_id,
    s.subject_id,
    p.project_id,
    st.type_code AS sample_type,
    sa.time_from_treatment_start,
    t.treatment_code AS treatment
FROM samples s
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_subjects tc ON s.treatment_subjects_id = tc.treatment_subjects_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
JOIN projects p ON s.project_id = p.project_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0;
```

#### Question 5: Breakdown Queries
The queries for further breakdowns are:

a. **Samples from each project**:
```sql
SELECT 
    p.project_id,
    COUNT(s.sample_id) AS sample_count
FROM samples s
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_subjects tc ON s.treatment_subjects_id = tc.treatment_subjects_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
JOIN projects p ON s.project_id = p.project_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0
GROUP BY p.project_id;
```

b. **Responders/non-responders**:
```sql
SELECT 
    tc.response,
    COUNT(s.sample_id) AS sample_count
FROM samples s
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_subjects tc ON s.treatment_subjects_id = tc.treatment_subjects_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0
GROUP BY tc.response;
```

c. **Males/females**:
```sql
SELECT 
    sub.sex,
    COUNT(s.sample_id) AS sample_count
FROM samples s
JOIN subjects sub ON s.subject_id = sub.subject_id
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_subjects tc ON s.treatment_subjects_id = tc.treatment_subjects_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0
GROUP BY sub.sex;
```

## Conclusion

The cell count analysis project successfully implements all required functionality for processing, visualizing, and analyzing immune cell count data. The statistical analysis reveals significant differences in CD4+ T cell frequencies between responders and non-responders, which could serve as a potential biomarker for predicting response to treatment tr1 in melanoma patients.

The database schema design provides a robust foundation for scalable data management, supporting hundreds of projects and thousands of samples while maintaining data integrity and enabling efficient complex queries.