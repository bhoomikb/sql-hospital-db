# 🏥 SQL Hospital Patient Management Database

A comprehensive hospital database project built with **PostgreSQL**, designed with **HIPAA data privacy principles** in mind. Covers patient records, appointments, staff management, and medical records — with a query collection that demonstrates advanced SQL skills.

---

## 🔐 HIPAA Awareness

This project demonstrates awareness of Protected Health Information (PHI) handling:

- PHI fields (name, DOB, phone, address) are clearly marked in the schema
- An **audit log table** is included to track who accessed what records and when
- In a real production system, PHI fields would be **encrypted at rest**, access would be **role-based**, and all queries would be **logged for compliance**

> This background comes from real-world exposure to HIPAA compliance in a healthcare environment.

---

## 📊 Database Schema

```
departments
    └── staff (many-to-one)
    └── appointments (many-to-one)

patients
    └── appointments (one-to-many)
        └── medical_records (one-to-one)

audit_log
    └── staff (many-to-one)
```

**Tables:** `departments`, `staff`, `patients`, `appointments`, `medical_records`, `audit_log`

---

## 📂 Project Structure

```
sql-hospital-db/
├── schema.sql         # Full database schema with sample data
├── queries.sql        # Query collection (basic → advanced)
└── README.md
```

---

## ⚙️ Setup & Run

```bash
# 1. Make sure PostgreSQL is installed
psql --version

# 2. Create the database
createdb hospital_db

# 3. Load the schema and data
psql -d hospital_db -f schema.sql

# 4. Run the queries
psql -d hospital_db -f queries.sql
```

---

## 🔍 Query Highlights

| Query | Concept |
|---|---|
| Today's scheduled appointments | JOIN across 4 tables |
| Patient full history | LEFT JOIN + ORDER BY |
| Patients with no recent visits | GROUP BY + HAVING + date math |
| Busiest departments | Conditional aggregation |
| Doctor workload this month | DATE_TRUNC + GROUP BY |
| Frequent visitor report | CTE (Common Table Expression) |
| Rank doctors by dept | Window function (RANK + PARTITION) |
| No-show rate per doctor | Percentage calculation |

---

## 💡 Key SQL Concepts Demonstrated

- ✅ Multi-table JOINs (INNER, LEFT)
- ✅ Aggregation (COUNT, SUM, ROUND)
- ✅ Conditional aggregation (CASE WHEN)
- ✅ CTEs (WITH clause)
- ✅ Window functions (RANK, PARTITION BY)
- ✅ Date filtering and truncation
- ✅ HIPAA-aware schema design

---

## 👩‍💻 Author

**Bhoomi Bhavsar** — CS Graduate | Manual QA Tester | Anthropic AI Certified  
Healthcare background: Patient Transporter at Community Medical Center (HIPAA trained)  
[LinkedIn](https://www.linkedin.com/in/bhoomi-bhavsar)
