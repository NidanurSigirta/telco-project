# 📡 Telco Project — Telecom Database Engineering & Analytics

> **i2i Systems Internship Project** — Enterprise-grade telecom data modeling and SQL analytics on Oracle XE.

---

## About the Project

This Project is a structured database engineering project developed within the scope of the i2i Systems internship program. The project simulates a real-world telecom operator environment where raw customer, tariff, and usage data is ingested into a relational Oracle database and analyzed through advanced SQL queries to derive meaningful business insights.

From schema design to data migration, a complete data lifecycle has been implemented, including the development of complex multi-table queries.

---

##  Key Features

- **Relational Schema Design:** Three interconnected tables with primary keys, foreign key constraints, and appropriate data types modeled from raw CSV datasets.
- **Docker-Powered Environment:** Oracle XE 21c runs inside a Docker container, ensuring a fully reproducible and portable development setup.
- **End-to-End Data Pipeline:** Raw CSV files are imported into Oracle XE via DBeaver, preserving referential integrity across all tables.
- **Advanced SQL Analytics:** Multi-table JOIN queries, subqueries, aggregation functions, and date arithmetic used to answer real business questions.
- **Missing Data Detection:** Customers with absent monthly records are identified using LEFT JOIN and NULL filtering techniques.
- **Payment & Usage Intelligence:** Full breakdown of payment statuses (PAID / UNPAID / LATE) and data consumption rates across all tariff plans.

---

## 📊 Dataset Overview

| Table | Records | Description |
|---|---|---|
| `TARIFFS` | 4 | Tariff plans with data, minute and SMS limits |
| `CUSTOMERS` | 10,000 | Customer profiles with city and signup information |
| `MONTHLY_STATS` | 9,950 | Monthly usage statistics and payment statuses |

> ⚠️ The 50-record discrepancy between CUSTOMERS and MONTHLY_STATS is intentional — identifying these missing records is part of the analytical requirements.

---

## 🗄️ Database Schema

```
TARIFFS
├── TARIFF_ID     NUMBER (PK)
├── NAME          VARCHAR2(100)
├── MONTHLY_FEE   NUMBER(10,2)
├── DATA_LIMIT    NUMBER
├── MINUTE_LIMIT  NUMBER
└── SMS_LIMIT     NUMBER
        │
        └──────────────────────┐
                               ▼
CUSTOMERS                 (FK: TARIFF_ID)
├── CUSTOMER_ID   NUMBER (PK)
├── NAME          VARCHAR2(100)
├── CITY          VARCHAR2(100)
├── SIGNUP_DATE   VARCHAR2(20)
└── TARIFF_ID     NUMBER (FK → TARIFFS)
        │
        └──────────────────────┐
                               ▼
MONTHLY_STATS             (FK: CUSTOMER_ID)
├── ID             NUMBER (PK)
├── CUSTOMER_ID    NUMBER (FK → CUSTOMERS)
├── DATA_USAGE     NUMBER(10,2)
├── MINUTE_USAGE   NUMBER
├── SMS_USAGE      NUMBER
└── PAYMENT_STATUS VARCHAR2(20)
```

---

## 🔍 Analytical Queries Solved

| # | Query | Method |
|---|---|---|
| 1.1 | Customers subscribed to 'Kobiye Destek' | JOIN + WHERE filter |
| 1.2 | Most recent subscriber to this tariff | Subquery + MAX + TO_DATE |
| 2.1 | Tariff distribution across all customers | GROUP BY + COUNT |
| 3.1 | Earliest registered customers | Subquery + MIN + TO_DATE |
| 3.2 | City distribution of earliest customers | GROUP BY + COUNT |
| 4.1 | Customers with missing monthly records | LEFT JOIN + IS NULL |
| 4.2 | City distribution of missing records | LEFT JOIN + GROUP BY |
| 5.1 | Customers using ≥75% of data limit | Arithmetic ratio + WHERE |
| 5.2 | Customers who exhausted all limits | Multi-condition AND filter |
| 6.1 | Customers with unpaid fees | WHERE PAYMENT_STATUS filter |
| 6.2 | Payment status distribution by tariff | GROUP BY two columns |

---

## 🔎 Key Findings

- **50 missing records** were detected in MONTHLY_STATS due to a simulated insertion error — identified using LEFT JOIN with NULL filtering across 39 distinct cities.
- **Kurumsal SMS** is the most subscribed tariff with **2,577 customers**, while **Çalışan GB** has the lowest count at **2,413**.
- The **earliest registrations** date back to **07/04/2025**, with **35 customers** signing up on that single day across multiple cities.
- All tariffs show a consistent split across **PAID**, **UNPAID**, and **LATE** payment statuses, suggesting payment behavior is independent of tariff type.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Oracle XE 21c | Core relational database engine |
| Docker | Containerized and reproducible database environment |
| Docker Compose | Single-command environment setup |
| DBeaver | Visual database client for connection and data import |
| SQL (Oracle dialect) | Schema design, data querying and analytics |

---

## 🚀 Installation & Setup

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [DBeaver Community](https://dbeaver.io/)

---

### 1. Start Oracle XE via Docker Compose

```bash
docker-compose up -d
```

Monitor the startup logs until the database is ready:

```bash
docker logs oracle-xe
```

Wait for the confirmation message:

```
DATABASE IS READY TO USE!
```

---

### 2. Connect via DBeaver

Create a new connection in DBeaver with the following parameters:

| Field | Value |
|---|---|
| Connection Type | Service Name |
| Host | `localhost` |
| Port | `1521` |
| Service Name | `XEPDB1` |
| Username | `system` |
| Password | `Sifreniz123` |

---

### 3. Create the telco User

Open a new SQL script under the `system` connection and execute:

```sql
CREATE USER telco IDENTIFIED BY "Sifreniz123";
GRANT CONNECT, RESOURCE, DBA TO telco;
```

Then create a new DBeaver connection using the `telco` credentials.

---

### 4. Create Tables

Connect as `telco` and run `TABLE_CREATION_SCRIPTS.sql` to initialize the schema.

---

### 5. Import CSV Data

Using DBeaver's Import Data wizard, load the CSV files **in this exact order**:

1. `TARIFFS.csv` → `TARIFFS`
2. `CUSTOMERS.csv` → `CUSTOMERS`
3. `MONTHLY_STATS.csv` → `MONTHLY_STATS`

Verify the import:

```sql
SELECT COUNT(*) FROM TARIFFS;        -- Expected: 4
SELECT COUNT(*) FROM CUSTOMERS;      -- Expected: 10000
SELECT COUNT(*) FROM MONTHLY_STATS;  -- Expected: 9950
```

---

### 6. Run the Queries

Open `SOLUTIONS.sql` in DBeaver under the `telco` connection and execute the queries.

---

## 📂 Project Structure

```
telco-project/
├── CUSTOMERS.csv                # 10,000 customer records
├── MONTHLY_STATS.csv            # Monthly usage and payment data
├── TARIFFS.csv                  # 4 tariff plan definitions
├── TABLE_CREATION_SCRIPTS.sql   # Schema definition with constraints
├── SOLUTIONS.sql                # All analytical SQL queries with comments
├── docker-compose.yml           # One-command Oracle XE environment
└── README.md                    # Project documentation
```

---

## ✒️ Development Team

**Nidanur Sigirta** — Database Engineer & SQL Analyst

---

##  License

© 2026 Telco. All rights reserved. 
