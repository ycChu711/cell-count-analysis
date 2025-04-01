-- projects table
CREATE TABLE projects (
    project_id VARCHAR(20) PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- subjects table
CREATE TABLE subjects (
    subject_id VARCHAR(20) PRIMARY KEY,
    external_id VARCHAR(50),  -- External identifier if needed
    age INTEGER,
    sex CHAR(1) CHECK (sex IN ('M', 'F', 'O')),  -- M=Male, F=Female, O=Other
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- conditions table
CREATE TABLE conditions (
    condition_id SERIAL PRIMARY KEY,
    condition_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- treatments table
CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    treatment_code VARCHAR(20) UNIQUE NOT NULL,
    treatment_name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- cubject_conditions table
CREATE TABLE subject_conditions (
    subject_condition_id SERIAL PRIMARY KEY,
    subject_id VARCHAR(20) REFERENCES subjects(subject_id),
    condition_id INTEGER REFERENCES conditions(condition_id),
    diagnosis_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(subject_id, condition_id)
);

-- subject_projects table
CREATE TABLE subject_projects (
    subject_project_id SERIAL PRIMARY KEY,
    subject_id VARCHAR(20) REFERENCES subjects(subject_id),
    project_id VARCHAR(20) REFERENCES projects(project_id),
    enrollment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(subject_id, project_id)
);

-- treatment_Courses Table
CREATE TABLE treatment_courses (
    treatment_course_id SERIAL PRIMARY KEY,
    subject_id VARCHAR(20) REFERENCES subjects(subject_id),
    treatment_id INTEGER REFERENCES treatments(treatment_id),
    start_date DATE,
    end_date DATE,
    response CHAR(1) CHECK (response IN ('y', 'n', 'u')),  -- y=responding, n=non-responding, u=unknown
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Sample_Types Table
CREATE TABLE sample_types (
    sample_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(20) UNIQUE NOT NULL,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Samples Table
CREATE TABLE samples (
    sample_id VARCHAR(20) PRIMARY KEY,
    subject_id VARCHAR(20) REFERENCES subjects(subject_id),
    project_id VARCHAR(20) REFERENCES projects(project_id),
    treatment_course_id INTEGER REFERENCES treatment_courses(treatment_course_id),
    sample_type_id INTEGER REFERENCES sample_types(sample_type_id),
    collection_date DATE,
    time_from_treatment_start FLOAT,  -- in days or appropriate units
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Cell_Types Table
CREATE TABLE cell_types (
    cell_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Cell_Counts Table
CREATE TABLE cell_counts (
    cell_count_id SERIAL PRIMARY KEY,
    sample_id VARCHAR(20) REFERENCES samples(sample_id),
    cell_type_id INTEGER REFERENCES cell_types(cell_type_id),
    count INTEGER NOT NULL,
    percentage FLOAT,  -- Optional pre-calculated percentage
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sample_id, cell_type_id)
);

-- 12. Analysis_Types Table
CREATE TABLE analysis_types (
    analysis_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. Analyses Table
CREATE TABLE analyses (
    analysis_id SERIAL PRIMARY KEY,
    analysis_type_id INTEGER REFERENCES analysis_types(analysis_type_id),
    project_id VARCHAR(20) REFERENCES projects(project_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parameters JSONB,  -- Stores analysis-specific parameters
    results JSONB,     -- Stores analysis results in JSON format
    performed_by VARCHAR(100),
    performed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. Sample_Analyses Table (junction table)
CREATE TABLE sample_analyses (
    sample_analysis_id SERIAL PRIMARY KEY,
    sample_id VARCHAR(20) REFERENCES samples(sample_id),
    analysis_id INTEGER REFERENCES analyses(analysis_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sample_id, analysis_id)
);

-- Indexes for optimization
CREATE INDEX idx_samples_project_id ON samples(project_id);
CREATE INDEX idx_samples_subject_id ON samples(subject_id);
CREATE INDEX idx_samples_treatment_course_id ON samples(treatment_course_id);
CREATE INDEX idx_samples_sample_type_id ON samples(sample_type_id);
CREATE INDEX idx_cell_counts_sample_id ON cell_counts(sample_id);
CREATE INDEX idx_cell_counts_cell_type_id ON cell_counts(cell_type_id);

-- Views for Common Queries

-- View: Complete Sample Data
CREATE VIEW vw_complete_sample_data AS
SELECT 
    p.project_id,
    s.subject_id,
    cond.condition_name AS condition,
    s.age,
    s.sex,
    t.treatment_code AS treatment,
    tc.response,
    sa.sample_id,
    st.type_code AS sample_type,
    sa.time_from_treatment_start,
    ct.type_code AS cell_type,
    cc.count,
    cc.percentage
FROM samples sa
JOIN subjects s ON sa.subject_id = s.subject_id
JOIN projects p ON sa.project_id = p.project_id
JOIN sample_types st ON sa.sample_type_id = st.sample_type_id
JOIN treatment_courses tc ON sa.treatment_course_id = tc.treatment_course_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions cond ON sc.condition_id = cond.condition_id
JOIN cell_counts cc ON sa.sample_id = cc.sample_id
JOIN cell_types ct ON cc.cell_type_id = ct.cell_type_id;

-- View: Response Analysis
CREATE VIEW vw_response_analysis AS
SELECT 
    p.project_id,
    cond.condition_name AS condition,
    t.treatment_code AS treatment,
    tc.response,
    st.type_code AS sample_type,
    ct.type_code AS cell_type,
    AVG(cc.percentage) AS avg_percentage,
    STDDEV(cc.percentage) AS std_percentage,
    COUNT(DISTINCT s.subject_id) AS subject_count
FROM samples sa
JOIN subjects s ON sa.subject_id = s.subject_id
JOIN projects p ON sa.project_id = p.project_id
JOIN sample_types st ON sa.sample_type_id = st.sample_type_id
JOIN treatment_courses tc ON sa.treatment_course_id = tc.treatment_course_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions cond ON sc.condition_id = cond.condition_id
JOIN cell_counts cc ON sa.sample_id = cc.sample_id
JOIN cell_types ct ON cc.cell_type_id = ct.cell_type_id
GROUP BY p.project_id, cond.condition_name, t.treatment_code, tc.response, st.type_code, ct.type_code;

-- QUERY 1: Count of subjects per condition
SELECT 
    c.condition_name,
    COUNT(DISTINCT sc.subject_id) AS subject_count
FROM conditions c
JOIN subject_conditions sc ON c.condition_id = sc.condition_id
GROUP BY c.condition_name
ORDER BY subject_count DESC;

-- QUERY 2: Melanoma PBMC samples at baseline from patients with tr1 treatment
SELECT 
    s.sample_id,
    s.subject_id,
    p.project_id,
    st.type_code AS sample_type,
    sa.time_from_treatment_start,
    t.treatment_code AS treatment
FROM samples s
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_courses tc ON s.treatment_course_id = tc.treatment_course_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
JOIN projects p ON s.project_id = p.project_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0;

-- QUERY 3a: Sample count per project for melanoma tr1 PBMC baseline samples
SELECT 
    p.project_id,
    COUNT(s.sample_id) AS sample_count
FROM samples s
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_courses tc ON s.treatment_course_id = tc.treatment_course_id
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

-- QUERY 3b: Responder count for melanoma tr1 PBMC baseline samples
SELECT 
    tc.response,
    COUNT(s.sample_id) AS sample_count
FROM samples s
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_courses tc ON s.treatment_course_id = tc.treatment_course_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0
GROUP BY tc.response;

-- QUERY 3c: Gender count for melanoma tr1 PBMC baseline samples
SELECT 
    sub.sex,
    COUNT(s.sample_id) AS sample_count
FROM samples s
JOIN subjects sub ON s.subject_id = sub.subject_id
JOIN sample_types st ON s.sample_type_id = st.sample_type_id
JOIN treatment_courses tc ON s.treatment_course_id = tc.treatment_course_id
JOIN treatments t ON tc.treatment_id = t.treatment_id
JOIN subject_conditions sc ON s.subject_id = sc.subject_id
JOIN conditions c ON sc.condition_id = c.condition_id
WHERE 
    c.condition_name = 'melanoma' AND
    st.type_code = 'PBMC' AND
    t.treatment_code = 'tr1' AND
    s.time_from_treatment_start = 0
GROUP BY sub.sex;