USE smart_campus_maintenance;

-- Joined request register with requester, category and physical location.
SELECT r.request_id, CONCAT('CC-',LPAD(r.request_id,6,'0')) AS ticket,
       r.title, u.email, mc.category_name, b.building_name, rm.room_number,
       r.priority, r.current_status
FROM maintenance_request r
JOIN \`user\` u ON u.user_id=r.reported_by
JOIN maintenance_category mc ON mc.maintenance_category_id=r.maintenance_category_id
JOIN room rm ON rm.room_id=r.room_id
JOIN building b ON b.building_id=rm.building_id
ORDER BY r.reported_at DESC;

-- Aggregate, GROUP BY and HAVING example for the project report.
SELECT priority, COUNT(*) AS request_count
FROM maintenance_request GROUP BY priority HAVING COUNT(*) >= 1 ORDER BY request_count DESC;

-- Nested query: assets with at least one unresolved maintenance request.
SELECT asset_id, asset_name FROM asset
WHERE asset_id IN (SELECT asset_id FROM maintenance_request WHERE asset_id IS NOT NULL
  AND current_status NOT IN ('RESOLVED','CLOSED','CANCELLED','REJECTED'));

-- Correlated query: most recent assignment for each request.
SELECT r.request_id, r.title
FROM maintenance_request r
WHERE EXISTS (SELECT 1 FROM work_assignment wa WHERE wa.request_id=r.request_id
  AND wa.assigned_at=(SELECT MAX(w2.assigned_at) FROM work_assignment w2 WHERE w2.request_id=r.request_id));

-- Update operation: explicitly restock one known demo item.
UPDATE inventory_item SET quantity_available=quantity_available+5,status='AVAILABLE' WHERE item_code='HDMI-2M';

-- Delete operation: remove one disposable contact row only.
DELETE FROM user_phone WHERE phone_number='0000000000';

-- Transaction example for reserving a part.
START TRANSACTION;
UPDATE inventory_item SET quantity_reserved=quantity_reserved+1 WHERE item_id=1 AND quantity_available>=1;
COMMIT;

SELECT OpenRequestCount() AS open_requests;
