-- ============================================================
-- SQL Hospital Patient Management Database
-- HIPAA-Aware Schema Design
-- Author: Bhoomi Bhavsar
-- ============================================================
-- NOTE: In a real HIPAA-compliant system, PHI (Protected Health
-- Information) would be encrypted at rest, access would be
-- role-based, and all queries would be audit-logged.
-- ============================================================

-- Drop tables if re-running (safe for dev environment)
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS departments;


-- ============================================================
-- DEPARTMENTS
-- ============================================================
CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    floor           INT,
    phone_ext       VARCHAR(10)
);

INSERT INTO departments (name, floor, phone_ext) VALUES
    ('Emergency',           1, '1001'),
    ('Cardiology',          2, '1002'),
    ('Neurology',           3, '1003'),
    ('Orthopedics',         3, '1004'),
    ('Pediatrics',          4, '1005'),
    ('Radiology',           1, '1006'),
    ('General Surgery',     2, '1007'),
    ('Oncology',            5, '1008');


-- ============================================================
-- STAFF
-- ============================================================
CREATE TABLE staff (
    staff_id        SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    role            VARCHAR(50)  NOT NULL,   -- e.g. Doctor, Nurse, Admin
    department_id   INT REFERENCES departments(department_id),
    email           VARCHAR(100) UNIQUE,
    hire_date       DATE         NOT NULL,
    is_active       BOOLEAN      DEFAULT TRUE
);

INSERT INTO staff (first_name, last_name, role, department_id, email, hire_date) VALUES
    ('Sarah',   'Patel',    'Doctor',           2, 's.patel@hospital.com',     '2018-03-15'),
    ('James',   'Rivera',   'Doctor',           1, 'j.rivera@hospital.com',    '2016-07-01'),
    ('Nina',    'Chen',     'Nurse',            5, 'n.chen@hospital.com',      '2020-01-20'),
    ('Robert',  'Kim',      'Doctor',           3, 'r.kim@hospital.com',       '2019-09-10'),
    ('Maria',   'Lopez',    'Nurse',            1, 'm.lopez@hospital.com',     '2021-05-05'),
    ('David',   'Smith',    'Admin',            NULL,'d.smith@hospital.com',   '2022-02-14'),
    ('Priya',   'Sharma',   'Doctor',           8, 'p.sharma@hospital.com',    '2015-11-30'),
    ('Tom',     'Brooks',   'Doctor',           7, 't.brooks@hospital.com',    '2017-06-22');


-- ============================================================
-- PATIENTS
-- (PHI fields marked — would be encrypted in production)
-- ============================================================
CREATE TABLE patients (
    patient_id      SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,        -- PHI
    last_name       VARCHAR(50)  NOT NULL,        -- PHI
    date_of_birth   DATE         NOT NULL,        -- PHI
    gender          VARCHAR(10),
    phone           VARCHAR(15),                  -- PHI
    email           VARCHAR(100),                 -- PHI
    address         TEXT,                         -- PHI
    insurance_id    VARCHAR(50),
    blood_type      VARCHAR(5),
    registered_on   TIMESTAMP    DEFAULT NOW(),
    is_active       BOOLEAN      DEFAULT TRUE
);

INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, blood_type, insurance_id) VALUES
    ('Alice',   'Johnson',  '1985-04-12', 'Female', '732-555-0101', 'A+',  'INS001'),
    ('Brian',   'Williams', '1972-09-03', 'Male',   '732-555-0102', 'O+',  'INS002'),
    ('Carla',   'Martinez', '1990-01-25', 'Female', '732-555-0103', 'B-',  'INS003'),
    ('Derek',   'Thompson', '1965-11-08', 'Male',   '732-555-0104', 'AB+', 'INS004'),
    ('Evelyn',  'Nguyen',   '2010-07-17', 'Female', '732-555-0105', 'O-',  'INS005'),
    ('Frank',   'Adams',    '1958-03-30', 'Male',   '732-555-0106', 'A-',  'INS006'),
    ('Grace',   'Lee',      '1995-06-14', 'Female', '732-555-0107', 'B+',  'INS007'),
    ('Henry',   'Clark',    '1980-12-01', 'Male',   '732-555-0108', 'AB-', 'INS008');


-- ============================================================
-- APPOINTMENTS
-- ============================================================
CREATE TABLE appointments (
    appointment_id  SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    staff_id        INT REFERENCES staff(staff_id),
    department_id   INT REFERENCES departments(department_id),
    scheduled_at    TIMESTAMP    NOT NULL,
    duration_mins   INT          DEFAULT 30,
    status          VARCHAR(20)  DEFAULT 'Scheduled',  -- Scheduled, Completed, Cancelled, No-Show
    reason          TEXT,
    notes           TEXT
);

INSERT INTO appointments (patient_id, staff_id, department_id, scheduled_at, status, reason) VALUES
    (1, 1, 2, '2024-06-01 09:00', 'Completed',  'Annual cardiac checkup'),
    (2, 2, 1, '2024-06-01 10:30', 'Completed',  'Chest pain evaluation'),
    (3, 4, 3, '2024-06-02 14:00', 'Completed',  'Migraine follow-up'),
    (4, 8, 7, '2024-06-03 11:00', 'Completed',  'Post-op review'),
    (5, 3, 5, '2024-06-04 09:30', 'Completed',  'Routine pediatric exam'),
    (6, 7, 8, '2024-06-05 13:00', 'Cancelled',  'Oncology consultation'),
    (7, 1, 2, '2024-06-06 10:00', 'No-Show',    'EKG review'),
    (8, 2, 1, '2024-06-07 15:00', 'Scheduled',  'Blood pressure monitoring'),
    (1, 1, 2, '2024-07-01 09:00', 'Scheduled',  '3-month cardiac follow-up'),
    (3, 4, 3, '2024-07-10 14:00', 'Scheduled',  'Neurology follow-up');


-- ============================================================
-- MEDICAL RECORDS
-- ============================================================
CREATE TABLE medical_records (
    record_id       SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    appointment_id  INT REFERENCES appointments(appointment_id),
    staff_id        INT REFERENCES staff(staff_id),
    diagnosis       TEXT,                         -- PHI
    treatment       TEXT,                         -- PHI
    prescription    TEXT,                         -- PHI
    created_at      TIMESTAMP    DEFAULT NOW(),
    updated_at      TIMESTAMP    DEFAULT NOW()
);

INSERT INTO medical_records (patient_id, appointment_id, staff_id, diagnosis, treatment, prescription) VALUES
    (1, 1, 1, 'Mild hypertension',         'Lifestyle changes recommended',      'Lisinopril 10mg daily'),
    (2, 2, 2, 'Stable angina',             'Stress test scheduled',              'Aspirin 81mg daily'),
    (3, 3, 4, 'Chronic migraine',          'Trigger avoidance counseling',       'Sumatriptan 50mg as needed'),
    (4, 4, 8, 'Appendectomy recovery',     'Wound healing well, cleared',        'Ibuprofen 400mg as needed'),
    (5, 5, 3, 'Healthy development',       'Vaccines up to date',                'Vitamin D supplement');


-- ============================================================
-- AUDIT LOG (HIPAA requirement simulation)
-- ============================================================
CREATE TABLE audit_log (
    log_id          SERIAL PRIMARY KEY,
    staff_id        INT REFERENCES staff(staff_id),
    action          VARCHAR(50),    -- e.g. VIEW, UPDATE, DELETE
    table_accessed  VARCHAR(50),
    record_id       INT,
    accessed_at     TIMESTAMP DEFAULT NOW(),
    ip_address      VARCHAR(45)
);
