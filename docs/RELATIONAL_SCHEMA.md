# Relational schema and design notes

## Core relations

- `campus(campus_id PK, campus_name, location, address, contact_number, status)`
- `building(building_id PK, campus_id FK, building_name, building_code UNIQUE, building_type, no_of_floors, status)`
- `room(room_id PK, building_id FK, room_number, floor, room_type, capacity, status, UNIQUE(building_id, room_number))`
- `asset_category(category_id PK, category_name UNIQUE, description, default_criticality)`
- `asset(asset_id PK, room_id FK, category_id FK, asset_code UNIQUE, serial_number UNIQUE, asset attributes...)`
- `user(user_id PK, user_name, name fields, email UNIQUE, role, password_hash, status)`
- `department(department_id PK, department_code UNIQUE, department_name UNIQUE, description, contact_email, status)`
- `technician(technician_id PK, user_id FK UNIQUE, department_id FK, employee_code UNIQUE, employment, experience, availability, service_area, rating, status)`
- `maintenance_request(request_id PK, reported_by FK, asset_id FK, room_id FK, maintenance_category_id FK, vendor_id FK, title, description, priority, severity, status, timestamps)`
- `request_approval(approval_id PK, request_id FK, reviewer_id FK, decision, notes, reviewed_at)`
- `work_assignment(assignment_id PK, request_id FK, technician_id FK, assigned_by FK, timestamps, status, notes)`
- `maintenance_activity(activity_id PK, assignment_id FK, user_id FK, technician_id FK, activity fields)`
- `sla_policy(sla_id PK, priority, severity, response/resolution targets)` and `sla_tracking(sla_tracking_id PK, request_id FK UNIQUE, sla_id FK, deadlines, breach state)`
- `inventory_item(item_id PK, item_code UNIQUE, stock/cost fields)` and `part_usage(usage_id PK, assignment_id FK, item_id FK, quantity, unit_cost)`
- `request_feedback(feedback_id PK, request_id FK, submitted_by FK, rating, comments, UNIQUE(request_id, submitted_by))`
- `preventive_maintenance(preventive_id PK, asset_id FK, technician_id FK, maintenance_category_id FK, schedule fields)`
- `vendor`, `skill`, `technician_skill`, `audit_log`, and `user_phone` support procurement, capability mapping, and audit/contact history.

## Integrity and normalization

The design separates entities and repeating relationships (e.g. technician skills, assignments, activities, part usage) into relations, uses surrogate primary keys, and applies unique constraints to natural identifiers such as email, asset code, employee code, and building/room number. Foreign keys enforce referential integrity. Domain checks constrain ratings, quantities, durations, and dates. This structure is intended to satisfy 3NF for the operational entities: attributes depend on the key, the whole key, and not on non-key attributes. Department data is stored once and referenced by technicians rather than duplicated in every technician record.
