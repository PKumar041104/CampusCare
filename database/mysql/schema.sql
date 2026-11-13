-- CampusCare relational schema for MySQL 8. Existing records are preserved by the initializer.
CREATE DATABASE IF NOT EXISTS smart_campus_maintenance CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE smart_campus_maintenance;

CREATE TABLE IF NOT EXISTS campus (
  campus_id INT AUTO_INCREMENT PRIMARY KEY,
  campus_name VARCHAR(100) NOT NULL,
  location VARCHAR(150) NOT NULL,
  address VARCHAR(250) NOT NULL,
  contact_number VARCHAR(20),
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS building (
  building_id INT AUTO_INCREMENT PRIMARY KEY,
  campus_id INT NOT NULL,
  building_name VARCHAR(120) NOT NULL,
  building_code VARCHAR(30) NOT NULL UNIQUE,
  building_type VARCHAR(50) NOT NULL,
  no_of_floors INT NOT NULL CHECK(no_of_floors > 0),
  status ENUM('ACTIVE','INACTIVE','UNDER_MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_building_campus FOREIGN KEY(campus_id) REFERENCES campus(campus_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_building_campus(campus_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS room (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  building_id INT NOT NULL,
  room_number VARCHAR(30) NOT NULL,
  floor INT NOT NULL,
  room_type VARCHAR(50) NOT NULL,
  capacity INT NULL CHECK(capacity IS NULL OR capacity > 0),
  status ENUM('ACTIVE','INACTIVE','UNDER_MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
  UNIQUE KEY uq_room_building_number(building_id, room_number),
  CONSTRAINT fk_room_building FOREIGN KEY(building_id) REFERENCES building(building_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_room_building_floor(building_id, floor)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS asset_category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  default_criticality ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'MEDIUM'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS asset (
  asset_id INT AUTO_INCREMENT PRIMARY KEY,
  room_id INT NOT NULL,
  category_id INT NOT NULL,
  asset_code VARCHAR(50) NOT NULL UNIQUE,
  asset_name VARCHAR(150) NOT NULL,
  serial_number VARCHAR(100) UNIQUE,
  manufacturer VARCHAR(100),
  model VARCHAR(100),
  purchase_date DATE,
  installation_date DATE,
  warranty_expiry DATE,
  criticality_level ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'MEDIUM',
  asset_status ENUM('ACTIVE','INACTIVE','UNDER_MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
  last_service_date DATE,
  CHECK(installation_date IS NULL OR purchase_date IS NULL OR installation_date >= purchase_date),
  CONSTRAINT fk_asset_room FOREIGN KEY(room_id) REFERENCES room(room_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_asset_category FOREIGN KEY(category_id) REFERENCES asset_category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_asset_room(room_id),
  INDEX idx_asset_category(category_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `user` (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  user_name VARCHAR(100) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50),
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  role ENUM('ADMIN','STUDENT','FACULTY','STAFF','TECHNICIAN') NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
  student_number VARCHAR(40) NULL UNIQUE,
  employee_number VARCHAR(40) NULL UNIQUE,
  department_name VARCHAR(120) NULL,
  semester TINYINT NULL CHECK(semester IS NULL OR semester BETWEEN 1 AND 8),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_role_status(role,status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS department (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  department_code VARCHAR(20) NOT NULL UNIQUE,
  department_name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255),
  contact_email VARCHAR(150),
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS technician (
  technician_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  department_id INT NULL,
  employee_code VARCHAR(30) NOT NULL UNIQUE,
  employment_type VARCHAR(30) NOT NULL,
  experience_years DECIMAL(4,1) NOT NULL DEFAULT 0 CHECK(experience_years >= 0),
  availability_status ENUM('AVAILABLE','BUSY','ON_LEAVE','OFFLINE') NOT NULL DEFAULT 'AVAILABLE',
  service_area VARCHAR(150) NOT NULL,
  rating DECIMAL(3,2) NULL CHECK(rating IS NULL OR rating BETWEEN 0 AND 5),
  status ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_technician_user FOREIGN KEY(user_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_technician_department FOREIGN KEY(department_id) REFERENCES department(department_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_technician_department(department_id),
  INDEX idx_technician_availability(status,availability_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS skill (
  skill_id INT AUTO_INCREMENT PRIMARY KEY,
  skill_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS technician_skill (
  technician_id INT NOT NULL,
  skill_id INT NOT NULL,
  proficiency_level VARCHAR(100) NOT NULL,
  certification VARCHAR(150),
  certification_expiry DATE,
  PRIMARY KEY(technician_id,skill_id),
  CONSTRAINT fk_technician_skill_technician FOREIGN KEY(technician_id) REFERENCES technician(technician_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_technician_skill_skill FOREIGN KEY(skill_id) REFERENCES skill(skill_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS maintenance_category (
  maintenance_category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  default_priority ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'MEDIUM'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vendor (
  vendor_id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_name VARCHAR(150) NOT NULL,
  contact_person VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(150),
  address VARCHAR(250),
  service_type VARCHAR(100),
  contract_start_date DATE,
  contract_end_date DATE,
  contract_value DECIMAL(12,2),
  rating DECIMAL(3,2),
  status ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
  CHECK(contract_end_date IS NULL OR contract_start_date IS NULL OR contract_end_date >= contract_start_date),
  CHECK(rating IS NULL OR rating BETWEEN 0 AND 5),
  CHECK(contract_value IS NULL OR contract_value >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS maintenance_request (
  request_id INT AUTO_INCREMENT PRIMARY KEY,
  reported_by INT NOT NULL,
  asset_id INT NULL,
  room_id INT NOT NULL,
  maintenance_category_id INT NOT NULL,
  vendor_id INT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  priority ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'MEDIUM',
  severity ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'MEDIUM',
  reported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  required_by TIMESTAMP NULL,
  current_status ENUM('PENDING_APPROVAL','APPROVED','REJECTED','REPORTED','ASSIGNED','IN_PROGRESS','ON_HOLD','RESOLVED','CLOSED','CANCELLED') NOT NULL DEFAULT 'PENDING_APPROVAL',
  resolved_at TIMESTAMP NULL,
  closed_at TIMESTAMP NULL,
  resolution_summary TEXT,
  CHECK(required_by IS NULL OR required_by >= reported_at),
  CHECK(resolved_at IS NULL OR resolved_at >= reported_at),
  CHECK(closed_at IS NULL OR resolved_at IS NULL OR closed_at >= resolved_at),
  CONSTRAINT fk_request_user FOREIGN KEY(reported_by) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_request_asset FOREIGN KEY(asset_id) REFERENCES asset(asset_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_request_room FOREIGN KEY(room_id) REFERENCES room(room_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_request_category FOREIGN KEY(maintenance_category_id) REFERENCES maintenance_category(maintenance_category_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_request_vendor FOREIGN KEY(vendor_id) REFERENCES vendor(vendor_id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_request_owner_date(reported_by,reported_at),
  INDEX idx_request_status_date(current_status,reported_at),
  INDEX idx_request_priority_status(priority,current_status),
  INDEX idx_request_room(room_id),
  INDEX idx_request_category(maintenance_category_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS request_approval (
  approval_id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL,
  reviewer_id INT NULL,
  decision ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  review_notes TEXT,
  reviewed_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_approval_request FOREIGN KEY(request_id) REFERENCES maintenance_request(request_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_approval_reviewer FOREIGN KEY(reviewer_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_approval_request(request_id,decision),
  INDEX idx_approval_reviewer(reviewer_id,decision)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS work_assignment (
  assignment_id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL,
  technician_id INT NOT NULL,
  assigned_by INT NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accepted_at TIMESTAMP NULL,
  started_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  assignment_status ENUM('ASSIGNED','ACCEPTED','IN_PROGRESS','COMPLETED','REASSIGNED','CANCELLED') NOT NULL DEFAULT 'ASSIGNED',
  assignment_notes TEXT,
  CONSTRAINT fk_assignment_request FOREIGN KEY(request_id) REFERENCES maintenance_request(request_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_assignment_technician FOREIGN KEY(technician_id) REFERENCES technician(technician_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_assignment_user FOREIGN KEY(assigned_by) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CHECK(accepted_at IS NULL OR accepted_at >= assigned_at),
  CHECK(started_at IS NULL OR accepted_at IS NULL OR started_at >= accepted_at),
  CHECK(completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at),
  INDEX idx_assignment_request(request_id,assigned_at),
  INDEX idx_assignment_technician_status(technician_id,assignment_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS maintenance_activity (
  activity_id INT AUTO_INCREMENT PRIMARY KEY,
  assignment_id INT NOT NULL,
  user_id INT NOT NULL,
  technician_id INT NULL,
  activity_type VARCHAR(50) NOT NULL,
  activity_description TEXT,
  old_status VARCHAR(30),
  new_status VARCHAR(30),
  start_time TIMESTAMP NULL,
  end_time TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK(end_time IS NULL OR start_time IS NULL OR end_time >= start_time),
  CONSTRAINT fk_activity_assignment FOREIGN KEY(assignment_id) REFERENCES work_assignment(assignment_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_activity_user FOREIGN KEY(user_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_activity_technician FOREIGN KEY(technician_id) REFERENCES technician(technician_id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_activity_assignment(assignment_id,created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS request_event (
  event_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL,
  user_id INT NULL,
  event_type VARCHAR(50) NOT NULL,
  old_status VARCHAR(30),
  new_status VARCHAR(30),
  note TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_request_event_request FOREIGN KEY(request_id) REFERENCES maintenance_request(request_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_request_event_user FOREIGN KEY(user_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_request_event_timeline(request_id,created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sla_policy (
  sla_id INT AUTO_INCREMENT PRIMARY KEY,
  sla_name VARCHAR(120) NOT NULL,
  priority ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
  severity ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
  response_time_minutes INT NOT NULL CHECK(response_time_minutes > 0),
  resolution_time_minutes INT NOT NULL CHECK(resolution_time_minutes > 0),
  grace_period_minutes INT NOT NULL DEFAULT 0 CHECK(grace_period_minutes >= 0),
  business_hours_only BOOLEAN NOT NULL DEFAULT FALSE,
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  UNIQUE KEY uq_sla_priority_severity(priority,severity,status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sla_tracking (
  sla_tracking_id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL UNIQUE,
  sla_id INT NOT NULL,
  start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  response_deadline TIMESTAMP NOT NULL,
  resolution_deadline TIMESTAMP NOT NULL,
  actual_response_time TIMESTAMP NULL,
  actual_resolution_time TIMESTAMP NULL,
  response_breached BOOLEAN NOT NULL DEFAULT FALSE,
  resolution_breached BOOLEAN NOT NULL DEFAULT FALSE,
  breach_time TIMESTAMP NULL,
  sla_status ENUM('WITHIN_SLA','AT_RISK','BREACHED','COMPLETED') NOT NULL DEFAULT 'WITHIN_SLA',
  escalation_level INT NOT NULL DEFAULT 0 CHECK(escalation_level >= 0),
  CHECK(resolution_deadline >= response_deadline),
  CONSTRAINT fk_sla_tracking_request FOREIGN KEY(request_id) REFERENCES maintenance_request(request_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_sla_tracking_policy FOREIGN KEY(sla_id) REFERENCES sla_policy(sla_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_sla_tracking_policy(sla_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_item (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  item_code VARCHAR(50) NOT NULL UNIQUE,
  item_name VARCHAR(150) NOT NULL,
  item_type VARCHAR(50) NOT NULL,
  description TEXT,
  unit VARCHAR(30) NOT NULL,
  unit_cost DECIMAL(12,2) NOT NULL CHECK(unit_cost >= 0),
  quantity_available DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK(quantity_available >= 0),
  quantity_reserved DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK(quantity_reserved >= 0),
  reorder_level DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK(reorder_level >= 0),
  storage_location VARCHAR(150),
  status ENUM('AVAILABLE','LOW_STOCK','OUT_OF_STOCK','INACTIVE') NOT NULL DEFAULT 'AVAILABLE',
  INDEX idx_inventory_status(status,item_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS part_usage (
  usage_id INT AUTO_INCREMENT PRIMARY KEY,
  assignment_id INT NOT NULL,
  item_id INT NOT NULL,
  quantity_used DECIMAL(12,2) NOT NULL CHECK(quantity_used > 0),
  unit_cost DECIMAL(12,2) NOT NULL CHECK(unit_cost >= 0),
  used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_part_usage_assignment FOREIGN KEY(assignment_id) REFERENCES work_assignment(assignment_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_part_usage_item FOREIGN KEY(item_id) REFERENCES inventory_item(item_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_part_usage_assignment(assignment_id),
  INDEX idx_part_usage_item(item_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_movement (
  movement_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id INT NOT NULL,
  actor_id INT NULL,
  movement_type ENUM('RESTOCK','USE','ADJUSTMENT') NOT NULL,
  quantity DECIMAL(12,2) NOT NULL CHECK(quantity > 0),
  reference_id VARCHAR(80),
  note VARCHAR(500),
  occurred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_inventory_movement_item FOREIGN KEY(item_id) REFERENCES inventory_item(item_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_inventory_movement_actor FOREIGN KEY(actor_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_inventory_movement_item(item_id,occurred_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS preventive_maintenance (
  preventive_id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT NOT NULL,
  technician_id INT NULL,
  maintenance_category_id INT NOT NULL,
  frequency VARCHAR(50) NOT NULL,
  last_service_date DATE,
  next_due_date DATE NOT NULL,
  estimated_duration INT NULL CHECK(estimated_duration IS NULL OR estimated_duration > 0),
  required_skill VARCHAR(100),
  instructions TEXT,
  status ENUM('SCHEDULED','DUE','COMPLETED','OVERDUE','CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
  CONSTRAINT fk_pm_asset FOREIGN KEY(asset_id) REFERENCES asset(asset_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pm_technician FOREIGN KEY(technician_id) REFERENCES technician(technician_id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_pm_category FOREIGN KEY(maintenance_category_id) REFERENCES maintenance_category(maintenance_category_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_pm_asset_due(asset_id,next_due_date),
  INDEX idx_pm_technician_due(technician_id,next_due_date),
  UNIQUE KEY uq_pm_asset_category_frequency(asset_id,maintenance_category_id,frequency)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS request_feedback (
  feedback_id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL,
  submitted_by INT NOT NULL,
  rating TINYINT NOT NULL CHECK(rating BETWEEN 1 AND 5),
  comments TEXT,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_feedback_request FOREIGN KEY(request_id) REFERENCES maintenance_request(request_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_feedback_user FOREIGN KEY(submitted_by) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY uq_feedback_request_user(request_id,submitted_by)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_log (
  audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  entity_name VARCHAR(100) NOT NULL,
  record_id VARCHAR(100) NOT NULL,
  action VARCHAR(50) NOT NULL,
  old_value TEXT,
  new_value TEXT,
  timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_log_user FOREIGN KEY(user_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_audit_log_user(user_id,timestamp),
  INDEX idx_audit_log_entity(entity_name,record_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_phone (
  user_id INT NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  PRIMARY KEY(user_id,phone_number),
  CONSTRAINT fk_user_phone_user FOREIGN KEY(user_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_session (
  session_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  token_hash CHAR(64) NOT NULL UNIQUE,
  user_id INT NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  revoked_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_session_user FOREIGN KEY(user_id) REFERENCES `user`(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_session_user_expiry(user_id,expires_at,revoked_at)
) ENGINE=InnoDB;


