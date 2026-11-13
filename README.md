# CampusCare - Smart Campus Maintenance Management System

CampusCare is a role-based campus maintenance portal built as a DBMS mini-project. MySQL 8 is the source of truth for users, campus locations, assets, requests, approvals, technician assignments, SLAs, inventory, audit history, and feedback. MongoDB is an optional mirror for operational event records.

## Features

- Student and faculty registration, secure login, database-backed sessions, and role-specific navigation.
- Students create categorized requests with campus location, asset, severity, priority, and description; they can track status and rate resolved service.
- Faculty and staff review requests, approve or reject with remarks, and create their own service requests.
- Administrators assign or reassign available technicians, manage users and campus locations, and review assets, inventory, preventive maintenance, vendors, reports, and audit history.
- Technicians view assigned jobs, record progress, block or resolve work, and record inventory parts. Stock movement and request history are persisted.
- Responsive dashboard interface with request timelines and KPI cards.

## Local Windows setup

Requirements: Node.js 20 LTS or newer and npm, MySQL Server 8.0. MongoDB Community Server is optional.

1. Extract the ZIP and open the extracted project folder in PowerShell.
2. Copy .env.example to .env.local.
3. Edit .env.local and set your MySQL username and password. Keep the database name as smart_campus_maintenance.
4. If MongoDB is not installed, set MONGODB_ENABLED=false. Otherwise use the example URI or your MongoDB URI.
5. Run these commands from the project folder:

    npm install
    npm run db:init
    npm run dev

6. Open http://localhost:3000.

The initializer creates or updates the schema, loads repeatable demonstration data, applies views, procedures, functions, and triggers, and creates MongoDB indexes when enabled. It preserves existing records and does not drop the database.

## Demonstration accounts

| Role | Email | Password |
|---|---|---|
| Administrator | admin@campus.local | Admin123! |
| Staff | staff@campus.local | Staff123! |
| Faculty reviewer | faculty@campus.local | Faculty123! |
| Technician | elec.tech01@campus.local | Tech123! |

Students and faculty can also register in the application. The initializer restores the demo passwords listed above for seeded accounts.

## Seed data

- PES Electronic City campus with three buildings and an expanded 138-room Engineering Block.
- Six departments and 72 technicians, with skills, experience, availability, and ratings.
- Sample assets, maintenance categories, SLA policies, inventory, vendors, and preventive maintenance schedules.

## Database and report materials

- database/mysql/schema.sql: normalized relational tables, constraints, and indexes.
- database/mysql/seed.sql: repeatable campus and demo data.
- database/mysql/advanced.sql: operational view, stored procedure, function, and audit / inventory triggers.
- database/mysql/queries.sql: reporting and relational query examples.
- database/mongodb/collections.js: MongoDB event collection and index setup.
- docs/ER_DIAGRAM.md: ER diagram and relationship notes.
- docs/RELATIONAL_SCHEMA.md: relational schema and normalization notes.
- docs/REPORT_OUTLINE.md: report outline aligned to the implementation.

## Validation

npm run lint and npm run build completed successfully for this source package. Database initialization could not be run in the packaging environment because no MySQL root password was configured. Enter your local MySQL credentials in .env.local, then run npm run db:init.

## Expanded demonstration data

- Demo student account: student@campus.local / Student123!.
- 12 repeatable walkthrough requests span pending, approved, rejected, assigned, in-progress, and on-hold stages.
- The seeded catalog contains 30 active inventory items.

