-- ============================================================
-- SQL Hospital Database — Query Collection
-- Author: Bhoomi Bhavsar
-- ============================================================
-- Demonstrates: JOINs, aggregations, subqueries, CTEs,
-- window functions, date filtering, and HIPAA-aware access.
-- ============================================================


-- ============================================================
-- SECTION 1: BASIC LOOKUPS
-- ============================================================

-- 1a. List all active patients (alphabetically)
SELECT patient_id, first_name, last_name, date_of_birth, blood_type
FROM patients
WHERE is_active = TRUE
ORDER BY last_name, first_name;


-- 1b. List all doctors and their departments
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
    d.name AS department
FROM staff s
JOIN departments d ON s.department_id = d.department_id
WHERE s.role = 'Doctor' AND s.is_active = TRUE
ORDER BY d.name;


-- 1c. Today's scheduled appointments
SELECT 
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
    d.name AS department,
    a.scheduled_at,
    a.reason
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN staff s ON a.staff_id = s.staff_id
JOIN departments d ON a.department_id = d.department_id
WHERE DATE(a.scheduled_at) = CURRENT_DATE
  AND a.status = 'Scheduled'
ORDER BY a.scheduled_at;


-- ============================================================
-- SECTION 2: PATIENT HISTORY
-- ============================================================

-- 2a. Full appointment history for a specific patient
SELECT 
    a.scheduled_at,
    a.status,
    a.reason,
    d.name AS department,
    CONCAT(s.first_name, ' ', s.last_name) AS seen_by,
    mr.diagnosis,
    mr.treatment,
    mr.prescription
FROM appointments a
JOIN departments d ON a.department_id = d.department_id
JOIN staff s ON a.staff_id = s.staff_id
LEFT JOIN medical_records mr ON mr.appointment_id = a.appointment_id
WHERE a.patient_id = 1   -- Change to desired patient_id
ORDER BY a.scheduled_at DESC;


-- 2b. Patients with no appointments in the last 6 months (outreach candidates)
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone,
    MAX(a.scheduled_at) AS last_visit
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
WHERE p.is_active = TRUE
GROUP BY p.patient_id, p.first_name, p.last_name, p.phone
HAVING MAX(a.scheduled_at) < NOW() - INTERVAL '6 months'
    OR MAX(a.scheduled_at) IS NULL
ORDER BY last_visit NULLS FIRST;


-- ============================================================
-- SECTION 3: DEPARTMENT & STAFF ANALYTICS
-- ============================================================

-- 3a. Appointment count by department (busiest departments)
SELECT 
    d.name AS department,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN a.status = 'No-Show'   THEN 1 ELSE 0 END) AS no_shows
FROM departments d
LEFT JOIN appointments a ON d.department_id = a.department_id
GROUP BY d.name
ORDER BY total_appointments DESC;


-- 3b. Doctor workload — appointments per doctor this month
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
    d.name AS department,
    COUNT(a.appointment_id) AS appointments_this_month
FROM staff s
JOIN departments d ON s.department_id = d.department_id
LEFT JOIN appointments a 
    ON s.staff_id = a.staff_id
    AND DATE_TRUNC('month', a.scheduled_at) = DATE_TRUNC('month', CURRENT_DATE)
WHERE s.role = 'Doctor'
GROUP BY s.staff_id, s.first_name, s.last_name, d.name
ORDER BY appointments_this_month DESC;


-- ============================================================
-- SECTION 4: ADVANCED QUERIES
-- ============================================================

-- 4a. CTE: Patients with more than 2 appointments (frequent visitors)
WITH visit_counts AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_visits
    FROM appointments
    WHERE status = 'Completed'
    GROUP BY patient_id
)
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    vc.total_visits
FROM visit_counts vc
JOIN patients p ON vc.patient_id = p.patient_id
WHERE vc.total_visits >= 2
ORDER BY vc.total_visits DESC;


-- 4b. Window function: Rank doctors by appointments within each department
SELECT 
    d.name AS department,
    CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
    COUNT(a.appointment_id) AS total_appointments,
    RANK() OVER (
        PARTITION BY d.name 
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS rank_in_dept
FROM staff s
JOIN departments d ON s.department_id = d.department_id
LEFT JOIN appointments a ON s.staff_id = a.staff_id
WHERE s.role = 'Doctor'
GROUP BY d.name, s.staff_id, s.first_name, s.last_name
ORDER BY d.name, rank_in_dept;


-- 4c. No-show rate per doctor (important for scheduling efficiency)
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
    COUNT(*) AS total,
    SUM(CASE WHEN a.status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        100.0 * SUM(CASE WHEN a.status = 'No-Show' THEN 1 ELSE 0 END) / COUNT(*), 
        1
    ) AS no_show_rate_pct
FROM appointments a
JOIN staff s ON a.staff_id = s.staff_id
WHERE s.role = 'Doctor'
GROUP BY s.staff_id, s.first_name, s.last_name
HAVING COUNT(*) > 0
ORDER BY no_show_rate_pct DESC;
