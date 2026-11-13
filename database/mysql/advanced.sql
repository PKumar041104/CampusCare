USE smart_campus_maintenance;

CREATE OR REPLACE VIEW v_open_maintenance_requests AS
SELECT r.request_id, CONCAT('CC-', LPAD(r.request_id, 6, '0')) AS ticket_code,
       r.title, r.priority, r.severity, r.current_status, r.reported_at,
       u.first_name, u.last_name, mc.category_name, rm.room_number, b.building_name
FROM maintenance_request r
JOIN `user` u ON u.user_id = r.reported_by
JOIN maintenance_category mc ON mc.maintenance_category_id = r.maintenance_category_id
JOIN room rm ON rm.room_id = r.room_id
JOIN building b ON b.building_id = rm.building_id
WHERE r.current_status NOT IN ('RESOLVED','CLOSED','CANCELLED','REJECTED');

DROP FUNCTION IF EXISTS OpenRequestCount;
DELIMITER $$
CREATE FUNCTION OpenRequestCount() RETURNS INT READS SQL DATA
BEGIN
  DECLARE v_count INT DEFAULT 0;
  SELECT COUNT(*) INTO v_count
  FROM maintenance_request
  WHERE current_status NOT IN ('RESOLVED','CLOSED','CANCELLED','REJECTED');
  RETURN v_count;
END$$

DROP PROCEDURE IF EXISTS AssignTechnician$$
CREATE PROCEDURE AssignTechnician(IN p_request_id INT, IN p_technician_id INT, IN p_assigned_by INT)
BEGIN
  DECLARE v_request_status VARCHAR(30);
  DECLARE v_tech_status VARCHAR(20);
  DECLARE v_availability VARCHAR(20);
  DECLARE v_old_technician INT DEFAULT NULL;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT current_status INTO v_request_status
  FROM maintenance_request WHERE request_id = p_request_id FOR UPDATE;
  IF v_request_status IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Request was not found';
  END IF;
  IF v_request_status NOT IN ('APPROVED','ASSIGNED') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only approved requests can be assigned';
  END IF;

  SELECT status, availability_status INTO v_tech_status, v_availability
  FROM technician WHERE technician_id = p_technician_id FOR UPDATE;
  IF v_tech_status IS NULL OR v_tech_status <> 'ACTIVE' OR v_availability <> 'AVAILABLE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Technician is not available';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM `user` WHERE user_id = p_assigned_by AND role = 'ADMIN' AND status = 'ACTIVE') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An active administrator is required';
  END IF;

  SELECT technician_id INTO v_old_technician
  FROM work_assignment
  WHERE request_id = p_request_id AND assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS')
  ORDER BY assigned_at DESC LIMIT 1 FOR UPDATE;

  SET @campuscare_actor_id = p_assigned_by;
  UPDATE work_assignment
    SET assignment_status = 'REASSIGNED', assignment_notes = 'Reassigned by administrator'
    WHERE request_id = p_request_id AND assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS');
  IF v_old_technician IS NOT NULL THEN
    UPDATE technician t SET availability_status = CASE
      WHEN EXISTS (
        SELECT 1 FROM work_assignment wa
        WHERE wa.technician_id = v_old_technician
          AND wa.assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS')
      ) THEN 'BUSY' ELSE 'AVAILABLE' END
    WHERE t.technician_id = v_old_technician;
  END IF;

  INSERT INTO work_assignment(request_id, technician_id, assigned_by, assignment_status)
    VALUES(p_request_id, p_technician_id, p_assigned_by, 'ASSIGNED');
  UPDATE maintenance_request SET current_status = 'ASSIGNED' WHERE request_id = p_request_id;
  UPDATE technician SET availability_status = 'BUSY' WHERE technician_id = p_technician_id;
  INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note)
    VALUES(p_request_id,p_assigned_by,'TECHNICIAN_ASSIGNED',v_request_status,'ASSIGNED',
           CONCAT('Assigned to technician #',p_technician_id));
  COMMIT;
END$$

DROP TRIGGER IF EXISTS trg_request_audit$$
CREATE TRIGGER trg_request_audit AFTER UPDATE ON maintenance_request FOR EACH ROW
BEGIN
  IF OLD.current_status <> NEW.current_status THEN
    INSERT INTO audit_log(user_id,entity_name,record_id,action,old_value,new_value)
    VALUES(NULLIF(@campuscare_actor_id,0),'maintenance_request',CAST(NEW.request_id AS CHAR),
           'STATUS_CHANGE',OLD.current_status,NEW.current_status);
  END IF;
END$$

DROP TRIGGER IF EXISTS trg_part_usage_check$$
CREATE TRIGGER trg_part_usage_check BEFORE INSERT ON part_usage FOR EACH ROW
BEGIN
  DECLARE v_available DECIMAL(12,2);
  DECLARE v_status VARCHAR(20);
  SELECT quantity_available,status INTO v_available,v_status
  FROM inventory_item WHERE item_id=NEW.item_id FOR UPDATE;
  IF v_available IS NULL OR v_status='INACTIVE' OR v_available < NEW.quantity_used THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Insufficient available inventory';
  END IF;
END$$

DROP TRIGGER IF EXISTS trg_part_usage_stock$$
CREATE TRIGGER trg_part_usage_stock AFTER INSERT ON part_usage FOR EACH ROW
BEGIN
  UPDATE inventory_item
  SET quantity_available=quantity_available-NEW.quantity_used,
      status=CASE
        WHEN quantity_available-NEW.quantity_used <= 0 THEN 'OUT_OF_STOCK'
        WHEN quantity_available-NEW.quantity_used <= reorder_level THEN 'LOW_STOCK'
        ELSE 'AVAILABLE' END
  WHERE item_id=NEW.item_id;
  INSERT INTO inventory_movement(item_id,actor_id,movement_type,quantity,reference_id,note)
  VALUES(NEW.item_id,NULLIF(@campuscare_actor_id,0),'USE',NEW.quantity_used,
         CAST(NEW.assignment_id AS CHAR),'Parts recorded on technician work order');
END$$
DELIMITER ;

