/*
===============================================================================
DBMS MINI PROJECT - DDL SCRIPT
===============================================================================
Team No.      : 7
Project Title : Smart Campus Maintenance, Technician Allocation & SLA
                Management System

Team Members:
1. PES2UG24CS368 - Pratham Kumar
2. PES2UG24CS348 - Karthik P

Database      : PostgreSQL
Purpose       : Task 4 - Preparation and Execution of DDL Statements
===============================================================================
*/

-- ---------------------------------------------------------------------------
-- DATABASE
-- ---------------------------------------------------------------------------
-- Create the database separately if it does not already exist:
-- CREATE DATABASE smart_campus_maintenance;
--
-- After creating it, connect to:
-- smart_campus_maintenance
--
-- The statements below create the project tables in the public schema.

-- ---------------------------------------------------------------------------
-- 1. CAMPUS
-- ---------------------------------------------------------------------------
CREATE TABLE campus (
    campus_id       INTEGER GENERATED ALWAYS AS IDENTITY,
    campus_name     VARCHAR(100) NOT NULL,
    location        VARCHAR(150) NOT NULL,
    address         VARCHAR(250) NOT NULL,
    contact_number  VARCHAR(20),
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_campus PRIMARY KEY (campus_id),
    CONSTRAINT chk_campus_status
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- ---------------------------------------------------------------------------
-- 2. BUILDING
-- ---------------------------------------------------------------------------
CREATE TABLE building (
    building_id     INTEGER GENERATED ALWAYS AS IDENTITY,
    campus_id       INTEGER NOT NULL,
    building_name   VARCHAR(120) NOT NULL,
    building_code   VARCHAR(30) NOT NULL,
    building_type   VARCHAR(50) NOT NULL,
    no_of_floors    INTEGER NOT NULL,
    status          VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_building PRIMARY KEY (building_id),
    CONSTRAINT uq_building_code UNIQUE (building_code),
    CONSTRAINT chk_building_floors CHECK (no_of_floors > 0),
    CONSTRAINT chk_building_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE')),
    CONSTRAINT fk_building_campus
        FOREIGN KEY (campus_id)
        REFERENCES campus(campus_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_building_campus ON building(campus_id);

-- ---------------------------------------------------------------------------
-- 3. ROOM
-- ---------------------------------------------------------------------------
CREATE TABLE room (
    room_id        INTEGER GENERATED ALWAYS AS IDENTITY,
    building_id    INTEGER NOT NULL,
    room_number    VARCHAR(30) NOT NULL,
    floor          INTEGER NOT NULL,
    room_type      VARCHAR(50) NOT NULL,
    capacity       INTEGER,
    status         VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_room PRIMARY KEY (room_id),
    CONSTRAINT uq_room_building_number UNIQUE (building_id, room_number),
    CONSTRAINT chk_room_capacity
        CHECK (capacity IS NULL OR capacity > 0),
    CONSTRAINT chk_room_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE')),
    CONSTRAINT fk_room_building
        FOREIGN KEY (building_id)
        REFERENCES building(building_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_room_building ON room(building_id);

-- ---------------------------------------------------------------------------
-- 4. ASSET_CATEGORY
-- ---------------------------------------------------------------------------
CREATE TABLE asset_category (
    category_id         INTEGER GENERATED ALWAYS AS IDENTITY,
    category_name       VARCHAR(100) NOT NULL,
    description         TEXT,
    default_criticality VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',

    CONSTRAINT pk_asset_category PRIMARY KEY (category_id),
    CONSTRAINT uq_asset_category_name UNIQUE (category_name),
    CONSTRAINT chk_asset_category_criticality
        CHECK (default_criticality IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

-- ---------------------------------------------------------------------------
-- 5. ASSET
-- ---------------------------------------------------------------------------
CREATE TABLE asset (
    asset_id            INTEGER GENERATED ALWAYS AS IDENTITY,
    room_id             INTEGER NOT NULL,
    category_id         INTEGER NOT NULL,
    asset_code          VARCHAR(50) NOT NULL,
    asset_name          VARCHAR(150) NOT NULL,
    serial_number       VARCHAR(100),
    manufacturer        VARCHAR(100),
    model               VARCHAR(100),
    purchase_date       DATE,
    installation_date   DATE,
    warranty_expiry     DATE,
    criticality_level   VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    asset_status        VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    last_service_date   DATE,

    CONSTRAINT pk_asset PRIMARY KEY (asset_id),
    CONSTRAINT uq_asset_code UNIQUE (asset_code),
    CONSTRAINT uq_asset_serial_number UNIQUE (serial_number),
    CONSTRAINT chk_asset_criticality
        CHECK (criticality_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_asset_status
        CHECK (asset_status IN ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE')),
    CONSTRAINT chk_asset_dates
        CHECK (
            installation_date IS NULL
            OR purchase_date IS NULL
            OR installation_date >= purchase_date
        ),
    CONSTRAINT fk_asset_room
        FOREIGN KEY (room_id)
        REFERENCES room(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_asset_category
        FOREIGN KEY (category_id)
        REFERENCES asset_category(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_asset_room ON asset(room_id);
CREATE INDEX idx_asset_category ON asset(category_id);

-- ---------------------------------------------------------------------------
-- 6. USER
-- ---------------------------------------------------------------------------
CREATE TABLE "user" (
    user_id         INTEGER GENERATED ALWAYS AS IDENTITY,
    user_name       VARCHAR(100) NOT NULL,
    first_name      VARCHAR(50) NOT NULL,
    middle_name     VARCHAR(50),
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(150) NOT NULL,
    phone_number    VARCHAR(20),
    role            VARCHAR(30) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT chk_user_role
        CHECK (role IN ('ADMIN', 'STUDENT', 'FACULTY', 'STAFF', 'TECHNICIAN')),
    CONSTRAINT chk_user_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

-- ---------------------------------------------------------------------------
-- 7. TECHNICIAN
-- ---------------------------------------------------------------------------
CREATE TABLE technician (
    technician_id       INTEGER GENERATED ALWAYS AS IDENTITY,
    user_id             INTEGER NOT NULL,
    employee_code       VARCHAR(30) NOT NULL,
    employment_type     VARCHAR(30) NOT NULL,
    experience_years    NUMERIC(4,1) NOT NULL DEFAULT 0,
    availability_status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    service_area        VARCHAR(150) NOT NULL,
    rating              NUMERIC(3,2),
    status              VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_technician PRIMARY KEY (technician_id),
    CONSTRAINT uq_technician_employee_code UNIQUE (employee_code),
    CONSTRAINT uq_technician_user UNIQUE (user_id),
    CONSTRAINT chk_technician_availability
        CHECK (availability_status IN ('AVAILABLE', 'BUSY', 'ON_LEAVE', 'OFFLINE')),
    CONSTRAINT chk_technician_experience
        CHECK (experience_years >= 0),
    CONSTRAINT chk_technician_rating
        CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5)),
    CONSTRAINT chk_technician_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    CONSTRAINT fk_technician_user
        FOREIGN KEY (user_id)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------------
-- 8. SKILL
-- ---------------------------------------------------------------------------
CREATE TABLE skill (
    skill_id    INTEGER GENERATED ALWAYS AS IDENTITY,
    skill_name  VARCHAR(100) NOT NULL,
    description TEXT,

    CONSTRAINT pk_skill PRIMARY KEY (skill_id),
    CONSTRAINT uq_skill_name UNIQUE (skill_name)
);

-- ---------------------------------------------------------------------------
-- 9. TECHNICIAN_SKILL
-- ---------------------------------------------------------------------------
CREATE TABLE technician_skill (
    technician_id       INTEGER NOT NULL,
    skill_id            INTEGER NOT NULL,
    proficiency_level   VARCHAR(100) NOT NULL,
    certification       VARCHAR(150),
    certification_expiry DATE,

    CONSTRAINT pk_technician_skill PRIMARY KEY (technician_id, skill_id),
    CONSTRAINT fk_technician_skill_technician
        FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_technician_skill_skill
        FOREIGN KEY (skill_id)
        REFERENCES skill(skill_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------------
-- 10. MAINTENANCE_CATEGORY
-- ---------------------------------------------------------------------------
CREATE TABLE maintenance_category (
    maintenance_category_id INTEGER GENERATED ALWAYS AS IDENTITY,
    category_name           VARCHAR(100) NOT NULL,
    description             TEXT,
    default_priority        VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',

    CONSTRAINT pk_maintenance_category PRIMARY KEY (maintenance_category_id),
    CONSTRAINT uq_maintenance_category_name UNIQUE (category_name),
    CONSTRAINT chk_maintenance_category_priority
        CHECK (default_priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

-- ---------------------------------------------------------------------------
-- 11. VENDOR
-- ---------------------------------------------------------------------------
CREATE TABLE vendor (
    vendor_id           INTEGER GENERATED ALWAYS AS IDENTITY,
    vendor_name         VARCHAR(150) NOT NULL,
    contact_person      VARCHAR(100) NOT NULL,
    phone               VARCHAR(20),
    email               VARCHAR(150),
    address             VARCHAR(250),
    service_type        VARCHAR(100),
    contract_start_date DATE,
    contract_end_date   DATE,
    contract_value      NUMERIC(12,2),
    rating              NUMERIC(3,2),
    status              VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_vendor PRIMARY KEY (vendor_id),
    CONSTRAINT chk_vendor_dates
        CHECK (
            contract_end_date IS NULL
            OR contract_start_date IS NULL
            OR contract_end_date >= contract_start_date
        ),
    CONSTRAINT chk_vendor_rating
        CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5)),
    CONSTRAINT chk_vendor_value
        CHECK (contract_value IS NULL OR contract_value >= 0),
    CONSTRAINT chk_vendor_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

-- ---------------------------------------------------------------------------
-- 12. MAINTENANCE_REQUEST
-- ---------------------------------------------------------------------------
CREATE TABLE maintenance_request (
    request_id              INTEGER GENERATED ALWAYS AS IDENTITY,
    reported_by             INTEGER NOT NULL,
    asset_id                INTEGER NOT NULL,
    room_id                 INTEGER NOT NULL,
    maintenance_category_id INTEGER NOT NULL,
    vendor_id               INTEGER,
    title                   VARCHAR(200) NOT NULL,
    description             TEXT NOT NULL,
    priority                VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    severity                VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    reported_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    required_by             TIMESTAMP,
    current_status          VARCHAR(30) NOT NULL DEFAULT 'REPORTED',
    resolved_at             TIMESTAMP,
    closed_at               TIMESTAMP,
    resolution_summary      TEXT,

    CONSTRAINT pk_maintenance_request PRIMARY KEY (request_id),
    CONSTRAINT chk_request_priority
        CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_request_severity
        CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_request_status
        CHECK (
            current_status IN
            ('REPORTED', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD', 'RESOLVED', 'CLOSED', 'CANCELLED')
        ),
    CONSTRAINT chk_request_required_by
        CHECK (required_by IS NULL OR required_by >= reported_at),
    CONSTRAINT chk_request_resolved
        CHECK (resolved_at IS NULL OR resolved_at >= reported_at),
    CONSTRAINT chk_request_closed
        CHECK (closed_at IS NULL OR resolved_at IS NULL OR closed_at >= resolved_at),
    CONSTRAINT fk_request_user
        FOREIGN KEY (reported_by)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_request_asset
        FOREIGN KEY (asset_id)
        REFERENCES asset(asset_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_request_room
        FOREIGN KEY (room_id)
        REFERENCES room(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_request_category
        FOREIGN KEY (maintenance_category_id)
        REFERENCES maintenance_category(maintenance_category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_request_vendor
        FOREIGN KEY (vendor_id)
        REFERENCES vendor(vendor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE INDEX idx_request_reported_by ON maintenance_request(reported_by);
CREATE INDEX idx_request_asset ON maintenance_request(asset_id);
CREATE INDEX idx_request_room ON maintenance_request(room_id);
CREATE INDEX idx_request_vendor ON maintenance_request(vendor_id);

-- ---------------------------------------------------------------------------
-- 13. WORK_ASSIGNMENT
-- ---------------------------------------------------------------------------
CREATE TABLE work_assignment (
    assignment_id     INTEGER GENERATED ALWAYS AS IDENTITY,
    request_id        INTEGER NOT NULL,
    technician_id     INTEGER NOT NULL,
    assigned_by       INTEGER NOT NULL,
    assigned_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accepted_at       TIMESTAMP,
    started_at        TIMESTAMP,
    completed_at      TIMESTAMP,
    assignment_status VARCHAR(30) NOT NULL DEFAULT 'ASSIGNED',
    assignment_notes  TEXT,

    CONSTRAINT pk_work_assignment PRIMARY KEY (assignment_id),
    CONSTRAINT chk_assignment_status
        CHECK (
            assignment_status IN
            ('ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'REASSIGNED', 'CANCELLED')
        ),
    CONSTRAINT chk_assignment_times
        CHECK (
            accepted_at IS NULL OR accepted_at >= assigned_at
        ),
    CONSTRAINT chk_assignment_start
        CHECK (
            started_at IS NULL OR accepted_at IS NULL OR started_at >= accepted_at
        ),
    CONSTRAINT chk_assignment_completion
        CHECK (
            completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at
        ),
    CONSTRAINT fk_assignment_request
        FOREIGN KEY (request_id)
        REFERENCES maintenance_request(request_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_assignment_technician
        FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_assignment_user
        FOREIGN KEY (assigned_by)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_assignment_request ON work_assignment(request_id);
CREATE INDEX idx_assignment_technician ON work_assignment(technician_id);

-- ---------------------------------------------------------------------------
-- 14. MAINTENANCE_ACTIVITY
-- ---------------------------------------------------------------------------
CREATE TABLE maintenance_activity (
    activity_id          INTEGER GENERATED ALWAYS AS IDENTITY,
    assignment_id        INTEGER NOT NULL,
    user_id              INTEGER NOT NULL,
    technician_id        INTEGER,
    activity_type        VARCHAR(50) NOT NULL,
    activity_description TEXT,
    old_status           VARCHAR(30),
    new_status           VARCHAR(30),
    start_time           TIMESTAMP,
    end_time             TIMESTAMP,
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_maintenance_activity PRIMARY KEY (activity_id),
    CONSTRAINT chk_activity_time
        CHECK (end_time IS NULL OR start_time IS NULL OR end_time >= start_time),
    CONSTRAINT fk_activity_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES work_assignment(assignment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_activity_user
        FOREIGN KEY (user_id)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_activity_technician
        FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE INDEX idx_activity_assignment ON maintenance_activity(assignment_id);

-- ---------------------------------------------------------------------------
-- 15. SLA_POLICY
-- ---------------------------------------------------------------------------
CREATE TABLE sla_policy (
    sla_id                   INTEGER GENERATED ALWAYS AS IDENTITY,
    sla_name                 VARCHAR(120) NOT NULL,
    priority                 VARCHAR(20) NOT NULL,
    severity                 VARCHAR(20) NOT NULL,
    response_time_minutes    INTEGER NOT NULL,
    resolution_time_minutes INTEGER NOT NULL,
    grace_period_minutes     INTEGER NOT NULL DEFAULT 0,
    business_hours_only      BOOLEAN NOT NULL DEFAULT FALSE,
    status                   VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_sla_policy PRIMARY KEY (sla_id),
    CONSTRAINT chk_sla_priority
        CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_sla_severity
        CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_sla_response_time
        CHECK (response_time_minutes > 0),
    CONSTRAINT chk_sla_resolution_time
        CHECK (resolution_time_minutes > 0),
    CONSTRAINT chk_sla_grace
        CHECK (grace_period_minutes >= 0),
    CONSTRAINT chk_sla_status
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- ---------------------------------------------------------------------------
-- 16. SLA_TRACKING
-- ---------------------------------------------------------------------------
CREATE TABLE sla_tracking (
    sla_tracking_id        INTEGER GENERATED ALWAYS AS IDENTITY,
    request_id             INTEGER NOT NULL,
    sla_id                 INTEGER NOT NULL,
    start_time             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    response_deadline      TIMESTAMP NOT NULL,
    resolution_deadline   TIMESTAMP NOT NULL,
    actual_response_time   TIMESTAMP,
    actual_resolution_time TIMESTAMP,
    response_breached      BOOLEAN NOT NULL DEFAULT FALSE,
    resolution_breached    BOOLEAN NOT NULL DEFAULT FALSE,
    breach_time            TIMESTAMP,
    sla_status             VARCHAR(30) NOT NULL DEFAULT 'WITHIN_SLA',
    escalation_level       INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT pk_sla_tracking PRIMARY KEY (sla_tracking_id),
    CONSTRAINT uq_sla_tracking_request UNIQUE (request_id),
    CONSTRAINT chk_sla_tracking_deadlines
        CHECK (resolution_deadline >= response_deadline),
    CONSTRAINT chk_sla_tracking_escalation
        CHECK (escalation_level >= 0),
    CONSTRAINT chk_sla_tracking_status
        CHECK (sla_status IN ('WITHIN_SLA', 'AT_RISK', 'BREACHED', 'COMPLETED')),
    CONSTRAINT fk_sla_tracking_request
        FOREIGN KEY (request_id)
        REFERENCES maintenance_request(request_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_sla_tracking_policy
        FOREIGN KEY (sla_id)
        REFERENCES sla_policy(sla_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_sla_tracking_policy ON sla_tracking(sla_id);

-- ---------------------------------------------------------------------------
-- 17. INVENTORY_ITEM
-- ---------------------------------------------------------------------------
CREATE TABLE inventory_item (
    item_id             INTEGER GENERATED ALWAYS AS IDENTITY,
    item_code           VARCHAR(50) NOT NULL,
    item_name           VARCHAR(150) NOT NULL,
    item_type           VARCHAR(50) NOT NULL,
    description         TEXT,
    unit                VARCHAR(30) NOT NULL,
    unit_cost           NUMERIC(12,2) NOT NULL,
    quantity_available  NUMERIC(12,2) NOT NULL DEFAULT 0,
    quantity_reserved   NUMERIC(12,2) NOT NULL DEFAULT 0,
    reorder_level       NUMERIC(12,2) NOT NULL DEFAULT 0,
    storage_location    VARCHAR(150),
    status              VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',

    CONSTRAINT pk_inventory_item PRIMARY KEY (item_id),
    CONSTRAINT uq_inventory_item_code UNIQUE (item_code),
    CONSTRAINT chk_inventory_cost CHECK (unit_cost >= 0),
    CONSTRAINT chk_inventory_quantity CHECK (quantity_available >= 0),
    CONSTRAINT chk_inventory_reserved CHECK (quantity_reserved >= 0),
    CONSTRAINT chk_inventory_reorder CHECK (reorder_level >= 0),
    CONSTRAINT chk_inventory_status
        CHECK (status IN ('AVAILABLE', 'LOW_STOCK', 'OUT_OF_STOCK', 'INACTIVE'))
);

-- ---------------------------------------------------------------------------
-- 18. PART_USAGE
-- ---------------------------------------------------------------------------
CREATE TABLE part_usage (
    usage_id       INTEGER GENERATED ALWAYS AS IDENTITY,
    assignment_id  INTEGER NOT NULL,
    item_id        INTEGER NOT NULL,
    quantity_used  NUMERIC(12,2) NOT NULL,
    unit_cost      NUMERIC(12,2) NOT NULL,
    used_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_part_usage PRIMARY KEY (usage_id),
    CONSTRAINT chk_part_usage_quantity CHECK (quantity_used > 0),
    CONSTRAINT chk_part_usage_cost CHECK (unit_cost >= 0),
    CONSTRAINT fk_part_usage_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES work_assignment(assignment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_part_usage_item
        FOREIGN KEY (item_id)
        REFERENCES inventory_item(item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_part_usage_assignment ON part_usage(assignment_id);
CREATE INDEX idx_part_usage_item ON part_usage(item_id);

-- ---------------------------------------------------------------------------
-- 19. PREVENTIVE_MAINTENANCE
-- ---------------------------------------------------------------------------
CREATE TABLE preventive_maintenance (
    preventive_id           INTEGER GENERATED ALWAYS AS IDENTITY,
    asset_id                INTEGER NOT NULL,
    technician_id           INTEGER,
    maintenance_category_id INTEGER NOT NULL,
    frequency               VARCHAR(50) NOT NULL,
    last_service_date       DATE,
    next_due_date           DATE NOT NULL,
    estimated_duration      INTEGER,
    required_skill          VARCHAR(100),
    instructions            TEXT,
    status                   VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED',

    CONSTRAINT pk_preventive_maintenance PRIMARY KEY (preventive_id),
    CONSTRAINT chk_pm_duration
        CHECK (estimated_duration IS NULL OR estimated_duration > 0),
    CONSTRAINT chk_pm_status
        CHECK (
            status IN
            ('SCHEDULED', 'DUE', 'COMPLETED', 'OVERDUE', 'CANCELLED')
        ),
    CONSTRAINT fk_pm_asset
        FOREIGN KEY (asset_id)
        REFERENCES asset(asset_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pm_technician
        FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_pm_category
        FOREIGN KEY (maintenance_category_id)
        REFERENCES maintenance_category(maintenance_category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_pm_asset ON preventive_maintenance(asset_id);
CREATE INDEX idx_pm_technician ON preventive_maintenance(technician_id);

-- ---------------------------------------------------------------------------
-- 20. AUDIT_LOG
-- ---------------------------------------------------------------------------
CREATE TABLE audit_log (
    audit_id     BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id      INTEGER,
    entity_name  VARCHAR(100) NOT NULL,
    record_id    VARCHAR(100) NOT NULL,
    action       VARCHAR(50) NOT NULL,
    old_value    TEXT,
    new_value    TEXT,
    timestamp    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_audit_log PRIMARY KEY (audit_id),
    CONSTRAINT fk_audit_log_user
        FOREIGN KEY (user_id)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE INDEX idx_audit_log_user ON audit_log(user_id);

-- ---------------------------------------------------------------------------
-- 21. USER_PHONE
-- ---------------------------------------------------------------------------
CREATE TABLE user_phone (
    user_id       INTEGER NOT NULL,
    phone_number  VARCHAR(20) NOT NULL,

    CONSTRAINT pk_user_phone PRIMARY KEY (user_id, phone_number),
    CONSTRAINT fk_user_phone_user
        FOREIGN KEY (user_id)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- FINAL VERIFICATION QUERIES
-- ---------------------------------------------------------------------------
-- Verify that all 21 required tables have been created:
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

-- List all project tables:
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- End of DDL script
