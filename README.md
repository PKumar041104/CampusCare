# CampusCare – Smart Campus Maintenance, Technician Allocation & SLA Management System

A Database Management Systems (DBMS) Mini Project developed as part of the B.Tech Computer Science and Engineering curriculum at PES University.

---

## Academic Project Details

| Particular | Details |
|---|---|
| **Project Title** | Smart Campus Maintenance, Technician Allocation & SLA Management System |
| **Project Name** | CampusCare |
| **Course** | Database Management Systems (DBMS) |
| **Programme** | Bachelor of Technology (B.Tech) |
| **Department** | Computer Science and Engineering |
| **Semester** | V Semester |
| **Academic Institution** | PES University |
| **Campus** | Electronic City Campus, Bengaluru |
| **Academic Year** | 2026–2027 |

### Project Team

| Student Name | SRN |
|---|---|
| Pratham Kumar | PES2UG24CS368 |
| Karthik P | PES2UG24CS348 |

### Faculty Supervisor

**Prof. Sheela Devi M.**  
PES University, Department of Computer Science and Engineering.

---

## 1. Project Overview

CampusCare is a web-based Smart Campus Maintenance Management System designed to digitize and streamline maintenance operations within a university campus.

The system provides a centralized platform for reporting maintenance issues, verifying requests, allocating technicians, tracking work progress, managing inventory, and monitoring Service Level Agreements (SLAs).

It implements role-based workflows for students, faculty members, administrators, and technicians, ensuring transparency, accountability, and efficient coordination throughout the maintenance lifecycle.

The project demonstrates the practical application of database management concepts through relational database design, ER modelling, relational mapping, SQL queries, stored procedures, functions, triggers, and transaction management.

## 2. Key Features

- **Student Portal:** Submit maintenance requests, track request status, and provide feedback.
- **Faculty Portal:** Review, approve, or reject maintenance requests.
- **Administrator Portal:** Manage users, campus infrastructure, technicians, vendors, inventory, and maintenance assignments.
- **Technician Portal:** View assigned work orders, update progress, record maintenance activities, and report completion.
- **SLA Management:** Monitor maintenance response and resolution timelines.
- **Inventory Management:** Maintain spare-part records, stock availability, and part usage.
- **Preventive Maintenance:** Manage scheduled maintenance activities.
- **Audit Management:** Maintain activity records for traceability and accountability.
- **Role-Based Access Control:** Provide role-specific access to system functionalities.

## 3. Technology Stack

| Component | Technology |
|---|---|
| Frontend | Next.js 14, React, TypeScript |
| Backend | Next.js API Routes |
| Primary Database | MySQL 8.0 |
| Supplementary Database | MongoDB |
| Programming Language | TypeScript, JavaScript |
| Styling | CSS |
| Runtime Environment | Node.js |
| Version Control | Git and GitHub |

**Database Design:** MySQL serves as the primary relational database, while MongoDB is available as an optional supplementary database for operational event records.

## 4. Database Implementation

The database design covers 27 relational tables supporting campus infrastructure, users, departments, technicians, maintenance requests, approvals, work assignments, SLA tracking, inventory, preventive maintenance, and audit records.

The implementation demonstrates:

- Entity-Relationship (ER) modelling.
- ER-to-relational mapping.
- Primary key and foreign key constraints.
- Data Definition Language (DDL).
- Data Manipulation Language (DML).
- Aggregate functions and GROUP BY queries.
- Nested and correlated queries.
- UPDATE and DELETE operations.
- Stored procedures and user-defined functions.
- Database triggers.
- Transaction management.
- Referential integrity.

## 5. Repository Structure

```text
CampusCare/
│
├── app/                    # Frontend pages and API routes
├── components/             # Reusable React components
├── database/
│   ├── mysql/              # Schema, seed data, queries and routines
│   └── mongodb/            # MongoDB collection configuration
├── docs/                   # Technical documentation and diagrams
├── lib/                    # Database, authentication and workflow logic
├── scripts/                # Database initialization scripts
├── report/                 # Academic project reports
│
├── .env.example            # Environment configuration template
├── .gitignore
├── package.json
├── package-lock.json
├── README.md
└── tsconfig.json
```

## 6. Local Setup and Execution

### Prerequisites

- Node.js 20 or later.
- npm.
- MySQL Server 8.0.
- MongoDB Community Server (optional).

### Installation

1. Clone the repository:

```bash
git clone https://github.com/PKumar041104/CampusCare.git
```

2. Navigate to the project directory:

```bash
cd CampusCare
```

3. Install dependencies:

```bash
npm install
```

4. Create a local environment configuration file:

```bash
copy .env.example .env.local
```

5. Update the MySQL credentials and database configuration in `.env.local`.

6. Initialize the database:

```bash
npm run db:init
```

7. Start the development server:

```bash
npm run dev
```

8. Open the application:

```text
http://localhost:3000
```

**Note:** MongoDB is optional. It can be disabled through the environment configuration if it is not installed.

Never commit `.env.local` or actual database credentials to GitHub.

## 7. Project Documentation

The `docs/` directory contains technical documentation, including:

- ER Diagram.
- Relational Schema.
- Report Outline.
- Demonstration Runbook.

The `report/` directory is reserved for academic project reports and related documentation.

## 8. Project Objective

The primary objective of CampusCare is to demonstrate how database-driven web applications can improve campus maintenance operations through structured data management, role-based workflows, automated database operations, and transparent service tracking.

The project integrates theoretical DBMS concepts with a practical full-stack implementation.

---

## 9. Repository Information

**GitHub Repository:**  
https://github.com/PKumar041104/CampusCare

**Project:** CampusCare – Smart Campus Maintenance Management System

**Developed by:**  
Pratham Kumar and Karthik P

**Institution:** PES University, Bengaluru

**Course:** Database Management Systems (DBMS)

---

*Academic Mini Project – B.Tech Computer Science and Engineering, V Semester, PES University.*
