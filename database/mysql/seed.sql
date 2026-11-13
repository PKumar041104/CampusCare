USE smart_campus_maintenance;
INSERT IGNORE INTO campus(campus_id,campus_name,location,address,contact_number) VALUES(1,'PES Electronic City','Bengaluru','Electronic City, Bengaluru','080-00000000');
INSERT IGNORE INTO building(building_id,campus_id,building_name,building_code,building_type,no_of_floors) VALUES
(1,1,'Academic Block A','ACA','ACADEMIC',6),(2,1,'Library','LIB','LIBRARY',4);
INSERT IGNORE INTO room(room_id,building_id,room_number,floor,room_type,capacity) VALUES
(1,1,'401',4,'CLASSROOM',60),(2,2,'201',2,'READING_ROOM',40);
INSERT IGNORE INTO asset_category(category_id,category_name,description,default_criticality) VALUES
(1,'AV Equipment','Projectors and classroom AV','HIGH'),(2,'Electrical','Electrical infrastructure','CRITICAL');
INSERT IGNORE INTO asset(asset_id,room_id,category_id,asset_code,asset_name,manufacturer,model,criticality_level) VALUES
(1,1,1,'PRJ-ACA-401','Classroom Projector','Epson','EB-X06','HIGH'),(2,2,2,'LGT-LIB-201','Reading Room Lighting','Philips','LED Panel','MEDIUM');
INSERT IGNORE INTO `user`(user_id,user_name,first_name,last_name,email,role,password_hash) VALUES
(1,'admin','Campus','Administrator','admin@campus.local','ADMIN','PENDING_HASH'),
(2,'staff','Demo','Staff','staff@campus.local','STAFF','PENDING_HASH'),(3,'faculty','Campus','Reviewer','faculty@campus.local','FACULTY','PENDING_HASH');
INSERT IGNORE INTO maintenance_category(maintenance_category_id,category_name,description,default_priority) VALUES
(1,'Electrical','Electrical repairs','HIGH'),(2,'Equipment','Equipment repair','MEDIUM'),(3,'Plumbing','Plumbing maintenance','HIGH');
INSERT IGNORE INTO sla_policy(sla_id,sla_name,priority,severity,response_time_minutes,resolution_time_minutes) VALUES
(1,'Critical SLA','CRITICAL','CRITICAL',15,240),(2,'High SLA','HIGH','HIGH',60,480),(3,'Standard SLA','MEDIUM','MEDIUM',240,1440),(4,'Low SLA','LOW','LOW',480,4320);
INSERT IGNORE INTO skill(skill_id,skill_name,description) VALUES(1,'Electrical','Electrical maintenance'),(2,'AV Systems','Projector and audio visual systems'),(3,'Plumbing','Water and drainage systems');
INSERT IGNORE INTO inventory_item(item_id,item_code,item_name,item_type,unit,unit_cost,quantity_available,reorder_level) VALUES
(1,'HDMI-2M','HDMI Cable 2m','ELECTRONIC','piece',350,20,5),(2,'LED-9W','LED Bulb 9W','ELECTRICAL','piece',120,50,10);
INSERT IGNORE INTO vendor(vendor_id,vendor_name,contact_person,service_type,status) VALUES(1,'Campus Electrical Services','Ravi Kumar','Electrical','ACTIVE');

-- Expanded campus, departments, workforce and operational inventory
INSERT IGNORE INTO building(building_id,campus_id,building_name,building_code,building_type,no_of_floors) VALUES(3,1,'Engineering Block Main','ENG','ACADEMIC',6);
INSERT IGNORE INTO department(department_id,department_code,department_name,description,contact_email) VALUES
(1,'ELEC','Electrical','Campus Electrical operations','elec@campus.local'),
(2,'SAN','Sanitation & Plumbing','Campus Sanitation & Plumbing operations','san@campus.local'),
(3,'STAT','Stationery','Campus Stationery operations','stat@campus.local'),
(4,'IT','IT Support','Campus IT Support operations','it@campus.local'),
(5,'ACCT','Accounting','Campus Accounting operations','acct@campus.local'),
(6,'INFRA','Infrastructure','Campus Infrastructure operations','infra@campus.local');
INSERT IGNORE INTO room(building_id,room_number,floor,room_type,capacity) VALUES
(3,'101',1,'CLASSROOM',60),
(3,'102',1,'CLASSROOM',60),
(3,'103',1,'CLASSROOM',60),
(3,'104',1,'CLASSROOM',60),
(3,'105',1,'CLASSROOM',60),
(3,'106',1,'CLASSROOM',60),
(3,'107',1,'CLASSROOM',60),
(3,'108',1,'CLASSROOM',60),
(3,'109',1,'CLASSROOM',60),
(3,'110',1,'CLASSROOM',60),
(3,'111',1,'FACULTY_ROOM',4),
(3,'112',1,'FACULTY_ROOM',4),
(3,'113',1,'FACULTY_ROOM',4),
(3,'114',1,'FACULTY_ROOM',4),
(3,'115',1,'FACULTY_ROOM',4),
(3,'116',1,'FACULTY_ROOM',4),
(3,'117',1,'FACULTY_ROOM',4),
(3,'118',1,'FACULTY_ROOM',4),
(3,'119',1,'FACULTY_ROOM',4),
(3,'120',1,'FACULTY_ROOM',4),
(3,'121',1,'CONFERENCE_ROOM',24),
(3,'122',1,'SEMINAR_HALL',100),
(3,'123',1,'SEMINAR_HALL',100),
(3,'201',2,'CLASSROOM',60),
(3,'202',2,'CLASSROOM',60),
(3,'203',2,'CLASSROOM',60),
(3,'204',2,'CLASSROOM',60),
(3,'205',2,'CLASSROOM',60),
(3,'206',2,'CLASSROOM',60),
(3,'207',2,'CLASSROOM',60),
(3,'208',2,'CLASSROOM',60),
(3,'209',2,'CLASSROOM',60),
(3,'210',2,'CLASSROOM',60),
(3,'211',2,'FACULTY_ROOM',4),
(3,'212',2,'FACULTY_ROOM',4),
(3,'213',2,'FACULTY_ROOM',4),
(3,'214',2,'FACULTY_ROOM',4),
(3,'215',2,'FACULTY_ROOM',4),
(3,'216',2,'FACULTY_ROOM',4),
(3,'217',2,'FACULTY_ROOM',4),
(3,'218',2,'FACULTY_ROOM',4),
(3,'219',2,'FACULTY_ROOM',4),
(3,'220',2,'FACULTY_ROOM',4),
(3,'221',2,'CONFERENCE_ROOM',24),
(3,'222',2,'SEMINAR_HALL',100),
(3,'223',2,'SEMINAR_HALL',100),
(3,'301',3,'CLASSROOM',60),
(3,'302',3,'CLASSROOM',60),
(3,'303',3,'CLASSROOM',60),
(3,'304',3,'CLASSROOM',60),
(3,'305',3,'CLASSROOM',60),
(3,'306',3,'CLASSROOM',60),
(3,'307',3,'CLASSROOM',60),
(3,'308',3,'CLASSROOM',60),
(3,'309',3,'CLASSROOM',60),
(3,'310',3,'CLASSROOM',60),
(3,'311',3,'FACULTY_ROOM',4),
(3,'312',3,'FACULTY_ROOM',4),
(3,'313',3,'FACULTY_ROOM',4),
(3,'314',3,'FACULTY_ROOM',4),
(3,'315',3,'FACULTY_ROOM',4),
(3,'316',3,'FACULTY_ROOM',4),
(3,'317',3,'FACULTY_ROOM',4),
(3,'318',3,'FACULTY_ROOM',4),
(3,'319',3,'FACULTY_ROOM',4),
(3,'320',3,'FACULTY_ROOM',4),
(3,'321',3,'CONFERENCE_ROOM',24),
(3,'322',3,'COMPUTER_LAB',40),
(3,'323',3,'COMPUTER_LAB',40),
(3,'401',4,'CLASSROOM',60),
(3,'402',4,'CLASSROOM',60),
(3,'403',4,'CLASSROOM',60),
(3,'404',4,'CLASSROOM',60),
(3,'405',4,'CLASSROOM',60),
(3,'406',4,'CLASSROOM',60),
(3,'407',4,'CLASSROOM',60),
(3,'408',4,'CLASSROOM',60),
(3,'409',4,'CLASSROOM',60),
(3,'410',4,'CLASSROOM',60),
(3,'411',4,'FACULTY_ROOM',4),
(3,'412',4,'FACULTY_ROOM',4),
(3,'413',4,'FACULTY_ROOM',4),
(3,'414',4,'FACULTY_ROOM',4),
(3,'415',4,'FACULTY_ROOM',4),
(3,'416',4,'FACULTY_ROOM',4),
(3,'417',4,'FACULTY_ROOM',4),
(3,'418',4,'FACULTY_ROOM',4),
(3,'419',4,'FACULTY_ROOM',4),
(3,'420',4,'FACULTY_ROOM',4),
(3,'421',4,'CONFERENCE_ROOM',24),
(3,'422',4,'COMPUTER_LAB',40),
(3,'423',4,'COMPUTER_LAB',40),
(3,'501',5,'CLASSROOM',60),
(3,'502',5,'CLASSROOM',60),
(3,'503',5,'CLASSROOM',60),
(3,'504',5,'CLASSROOM',60),
(3,'505',5,'CLASSROOM',60),
(3,'506',5,'CLASSROOM',60),
(3,'507',5,'CLASSROOM',60),
(3,'508',5,'CLASSROOM',60),
(3,'509',5,'CLASSROOM',60),
(3,'510',5,'CLASSROOM',60),
(3,'511',5,'FACULTY_ROOM',4),
(3,'512',5,'FACULTY_ROOM',4),
(3,'513',5,'FACULTY_ROOM',4),
(3,'514',5,'FACULTY_ROOM',4),
(3,'515',5,'FACULTY_ROOM',4),
(3,'516',5,'FACULTY_ROOM',4),
(3,'517',5,'FACULTY_ROOM',4),
(3,'518',5,'FACULTY_ROOM',4),
(3,'519',5,'FACULTY_ROOM',4),
(3,'520',5,'FACULTY_ROOM',4),
(3,'521',5,'CONFERENCE_ROOM',24),
(3,'522',5,'COMPUTER_LAB',40),
(3,'523',5,'COMPUTER_LAB',40),
(3,'601',6,'CLASSROOM',60),
(3,'602',6,'CLASSROOM',60),
(3,'603',6,'CLASSROOM',60),
(3,'604',6,'CLASSROOM',60),
(3,'605',6,'CLASSROOM',60),
(3,'606',6,'CLASSROOM',60),
(3,'607',6,'CLASSROOM',60),
(3,'608',6,'CLASSROOM',60),
(3,'609',6,'CLASSROOM',60),
(3,'610',6,'CLASSROOM',60),
(3,'611',6,'FACULTY_ROOM',4),
(3,'612',6,'FACULTY_ROOM',4),
(3,'613',6,'FACULTY_ROOM',4),
(3,'614',6,'FACULTY_ROOM',4),
(3,'615',6,'FACULTY_ROOM',4),
(3,'616',6,'FACULTY_ROOM',4),
(3,'617',6,'FACULTY_ROOM',4),
(3,'618',6,'FACULTY_ROOM',4),
(3,'619',6,'FACULTY_ROOM',4),
(3,'620',6,'FACULTY_ROOM',4),
(3,'621',6,'CONFERENCE_ROOM',24),
(3,'622',6,'COMPUTER_LAB',40),
(3,'623',6,'COMPUTER_LAB',40);
INSERT IGNORE INTO `user`(user_id,user_name,first_name,last_name,email,role,password_hash) VALUES
(1001,'electech01','Aarav','Sharma','elec.tech01@campus.local','TECHNICIAN','PENDING_HASH'),
(1002,'electech02','Ananya','Reddy','elec.tech02@campus.local','TECHNICIAN','PENDING_HASH'),
(1003,'electech03','Rohan','Kumar','elec.tech03@campus.local','TECHNICIAN','PENDING_HASH'),
(1004,'electech04','Isha','Patel','elec.tech04@campus.local','TECHNICIAN','PENDING_HASH'),
(1005,'electech05','Vikram','Singh','elec.tech05@campus.local','TECHNICIAN','PENDING_HASH'),
(1006,'electech06','Meera','Nair','elec.tech06@campus.local','TECHNICIAN','PENDING_HASH'),
(1007,'electech07','Karan','Das','elec.tech07@campus.local','TECHNICIAN','PENDING_HASH'),
(1008,'electech08','Diya','Iyer','elec.tech08@campus.local','TECHNICIAN','PENDING_HASH'),
(1009,'electech09','Arjun','Joshi','elec.tech09@campus.local','TECHNICIAN','PENDING_HASH'),
(1010,'electech10','Nisha','Rao','elec.tech10@campus.local','TECHNICIAN','PENDING_HASH'),
(1011,'electech11','Rahul','Gupta','elec.tech11@campus.local','TECHNICIAN','PENDING_HASH'),
(1012,'electech12','Sana','Menon','elec.tech12@campus.local','TECHNICIAN','PENDING_HASH'),
(1013,'santech01','Aarav','Sharma','san.tech01@campus.local','TECHNICIAN','PENDING_HASH'),
(1014,'santech02','Ananya','Reddy','san.tech02@campus.local','TECHNICIAN','PENDING_HASH'),
(1015,'santech03','Rohan','Kumar','san.tech03@campus.local','TECHNICIAN','PENDING_HASH'),
(1016,'santech04','Isha','Patel','san.tech04@campus.local','TECHNICIAN','PENDING_HASH'),
(1017,'santech05','Vikram','Singh','san.tech05@campus.local','TECHNICIAN','PENDING_HASH'),
(1018,'santech06','Meera','Nair','san.tech06@campus.local','TECHNICIAN','PENDING_HASH'),
(1019,'santech07','Karan','Das','san.tech07@campus.local','TECHNICIAN','PENDING_HASH'),
(1020,'santech08','Diya','Iyer','san.tech08@campus.local','TECHNICIAN','PENDING_HASH'),
(1021,'santech09','Arjun','Joshi','san.tech09@campus.local','TECHNICIAN','PENDING_HASH'),
(1022,'santech10','Nisha','Rao','san.tech10@campus.local','TECHNICIAN','PENDING_HASH'),
(1023,'santech11','Rahul','Gupta','san.tech11@campus.local','TECHNICIAN','PENDING_HASH'),
(1024,'santech12','Sana','Menon','san.tech12@campus.local','TECHNICIAN','PENDING_HASH'),
(1025,'stattech01','Aarav','Sharma','stat.tech01@campus.local','TECHNICIAN','PENDING_HASH'),
(1026,'stattech02','Ananya','Reddy','stat.tech02@campus.local','TECHNICIAN','PENDING_HASH'),
(1027,'stattech03','Rohan','Kumar','stat.tech03@campus.local','TECHNICIAN','PENDING_HASH'),
(1028,'stattech04','Isha','Patel','stat.tech04@campus.local','TECHNICIAN','PENDING_HASH'),
(1029,'stattech05','Vikram','Singh','stat.tech05@campus.local','TECHNICIAN','PENDING_HASH'),
(1030,'stattech06','Meera','Nair','stat.tech06@campus.local','TECHNICIAN','PENDING_HASH'),
(1031,'stattech07','Karan','Das','stat.tech07@campus.local','TECHNICIAN','PENDING_HASH'),
(1032,'stattech08','Diya','Iyer','stat.tech08@campus.local','TECHNICIAN','PENDING_HASH'),
(1033,'stattech09','Arjun','Joshi','stat.tech09@campus.local','TECHNICIAN','PENDING_HASH'),
(1034,'stattech10','Nisha','Rao','stat.tech10@campus.local','TECHNICIAN','PENDING_HASH'),
(1035,'stattech11','Rahul','Gupta','stat.tech11@campus.local','TECHNICIAN','PENDING_HASH'),
(1036,'stattech12','Sana','Menon','stat.tech12@campus.local','TECHNICIAN','PENDING_HASH'),
(1037,'ittech01','Aarav','Sharma','it.tech01@campus.local','TECHNICIAN','PENDING_HASH'),
(1038,'ittech02','Ananya','Reddy','it.tech02@campus.local','TECHNICIAN','PENDING_HASH'),
(1039,'ittech03','Rohan','Kumar','it.tech03@campus.local','TECHNICIAN','PENDING_HASH'),
(1040,'ittech04','Isha','Patel','it.tech04@campus.local','TECHNICIAN','PENDING_HASH'),
(1041,'ittech05','Vikram','Singh','it.tech05@campus.local','TECHNICIAN','PENDING_HASH'),
(1042,'ittech06','Meera','Nair','it.tech06@campus.local','TECHNICIAN','PENDING_HASH'),
(1043,'ittech07','Karan','Das','it.tech07@campus.local','TECHNICIAN','PENDING_HASH'),
(1044,'ittech08','Diya','Iyer','it.tech08@campus.local','TECHNICIAN','PENDING_HASH'),
(1045,'ittech09','Arjun','Joshi','it.tech09@campus.local','TECHNICIAN','PENDING_HASH'),
(1046,'ittech10','Nisha','Rao','it.tech10@campus.local','TECHNICIAN','PENDING_HASH'),
(1047,'ittech11','Rahul','Gupta','it.tech11@campus.local','TECHNICIAN','PENDING_HASH'),
(1048,'ittech12','Sana','Menon','it.tech12@campus.local','TECHNICIAN','PENDING_HASH'),
(1049,'accttech01','Aarav','Sharma','acct.tech01@campus.local','TECHNICIAN','PENDING_HASH'),
(1050,'accttech02','Ananya','Reddy','acct.tech02@campus.local','TECHNICIAN','PENDING_HASH'),
(1051,'accttech03','Rohan','Kumar','acct.tech03@campus.local','TECHNICIAN','PENDING_HASH'),
(1052,'accttech04','Isha','Patel','acct.tech04@campus.local','TECHNICIAN','PENDING_HASH'),
(1053,'accttech05','Vikram','Singh','acct.tech05@campus.local','TECHNICIAN','PENDING_HASH'),
(1054,'accttech06','Meera','Nair','acct.tech06@campus.local','TECHNICIAN','PENDING_HASH'),
(1055,'accttech07','Karan','Das','acct.tech07@campus.local','TECHNICIAN','PENDING_HASH'),
(1056,'accttech08','Diya','Iyer','acct.tech08@campus.local','TECHNICIAN','PENDING_HASH'),
(1057,'accttech09','Arjun','Joshi','acct.tech09@campus.local','TECHNICIAN','PENDING_HASH'),
(1058,'accttech10','Nisha','Rao','acct.tech10@campus.local','TECHNICIAN','PENDING_HASH'),
(1059,'accttech11','Rahul','Gupta','acct.tech11@campus.local','TECHNICIAN','PENDING_HASH'),
(1060,'accttech12','Sana','Menon','acct.tech12@campus.local','TECHNICIAN','PENDING_HASH'),
(1061,'infratech01','Aarav','Sharma','infra.tech01@campus.local','TECHNICIAN','PENDING_HASH'),
(1062,'infratech02','Ananya','Reddy','infra.tech02@campus.local','TECHNICIAN','PENDING_HASH'),
(1063,'infratech03','Rohan','Kumar','infra.tech03@campus.local','TECHNICIAN','PENDING_HASH'),
(1064,'infratech04','Isha','Patel','infra.tech04@campus.local','TECHNICIAN','PENDING_HASH'),
(1065,'infratech05','Vikram','Singh','infra.tech05@campus.local','TECHNICIAN','PENDING_HASH'),
(1066,'infratech06','Meera','Nair','infra.tech06@campus.local','TECHNICIAN','PENDING_HASH'),
(1067,'infratech07','Karan','Das','infra.tech07@campus.local','TECHNICIAN','PENDING_HASH'),
(1068,'infratech08','Diya','Iyer','infra.tech08@campus.local','TECHNICIAN','PENDING_HASH'),
(1069,'infratech09','Arjun','Joshi','infra.tech09@campus.local','TECHNICIAN','PENDING_HASH'),
(1070,'infratech10','Nisha','Rao','infra.tech10@campus.local','TECHNICIAN','PENDING_HASH'),
(1071,'infratech11','Rahul','Gupta','infra.tech11@campus.local','TECHNICIAN','PENDING_HASH'),
(1072,'infratech12','Sana','Menon','infra.tech12@campus.local','TECHNICIAN','PENDING_HASH');
INSERT IGNORE INTO technician(technician_id,user_id,department_id,employee_code,employment_type,experience_years,availability_status,service_area,rating,status) VALUES
(1,1001,1,'ELEC-T01','FULL_TIME',2,'AVAILABLE','Electrical',4.1,'ACTIVE'),
(2,1002,1,'ELEC-T02','FULL_TIME',3,'AVAILABLE','Electrical',4.2,'ACTIVE'),
(3,1003,1,'ELEC-T03','FULL_TIME',4,'AVAILABLE','Electrical',4.3,'ACTIVE'),
(4,1004,1,'ELEC-T04','FULL_TIME',5,'AVAILABLE','Electrical',4.4,'ACTIVE'),
(5,1005,1,'ELEC-T05','FULL_TIME',6,'AVAILABLE','Electrical',4.5,'ACTIVE'),
(6,1006,1,'ELEC-T06','FULL_TIME',7,'AVAILABLE','Electrical',4.6,'ACTIVE'),
(7,1007,1,'ELEC-T07','FULL_TIME',8,'AVAILABLE','Electrical',4.7,'ACTIVE'),
(8,1008,1,'ELEC-T08','FULL_TIME',9,'AVAILABLE','Electrical',4.8,'ACTIVE'),
(9,1009,1,'ELEC-T09','FULL_TIME',10,'AVAILABLE','Electrical',4.9,'ACTIVE'),
(10,1010,1,'ELEC-T10','FULL_TIME',11,'AVAILABLE','Electrical',4.0,'ACTIVE'),
(11,1011,1,'ELEC-T11','FULL_TIME',12,'AVAILABLE','Electrical',4.1,'ACTIVE'),
(12,1012,1,'ELEC-T12','FULL_TIME',13,'AVAILABLE','Electrical',4.2,'ACTIVE'),
(13,1013,2,'SAN-T01','FULL_TIME',2,'AVAILABLE','Sanitation & Plumbing',4.1,'ACTIVE'),
(14,1014,2,'SAN-T02','FULL_TIME',3,'AVAILABLE','Sanitation & Plumbing',4.2,'ACTIVE'),
(15,1015,2,'SAN-T03','FULL_TIME',4,'AVAILABLE','Sanitation & Plumbing',4.3,'ACTIVE'),
(16,1016,2,'SAN-T04','FULL_TIME',5,'AVAILABLE','Sanitation & Plumbing',4.4,'ACTIVE'),
(17,1017,2,'SAN-T05','FULL_TIME',6,'AVAILABLE','Sanitation & Plumbing',4.5,'ACTIVE'),
(18,1018,2,'SAN-T06','FULL_TIME',7,'AVAILABLE','Sanitation & Plumbing',4.6,'ACTIVE'),
(19,1019,2,'SAN-T07','FULL_TIME',8,'AVAILABLE','Sanitation & Plumbing',4.7,'ACTIVE'),
(20,1020,2,'SAN-T08','FULL_TIME',9,'AVAILABLE','Sanitation & Plumbing',4.8,'ACTIVE'),
(21,1021,2,'SAN-T09','FULL_TIME',10,'AVAILABLE','Sanitation & Plumbing',4.9,'ACTIVE'),
(22,1022,2,'SAN-T10','FULL_TIME',11,'AVAILABLE','Sanitation & Plumbing',4.0,'ACTIVE'),
(23,1023,2,'SAN-T11','FULL_TIME',12,'AVAILABLE','Sanitation & Plumbing',4.1,'ACTIVE'),
(24,1024,2,'SAN-T12','FULL_TIME',13,'AVAILABLE','Sanitation & Plumbing',4.2,'ACTIVE'),
(25,1025,3,'STAT-T01','FULL_TIME',2,'AVAILABLE','Stationery',4.1,'ACTIVE'),
(26,1026,3,'STAT-T02','FULL_TIME',3,'AVAILABLE','Stationery',4.2,'ACTIVE'),
(27,1027,3,'STAT-T03','FULL_TIME',4,'AVAILABLE','Stationery',4.3,'ACTIVE'),
(28,1028,3,'STAT-T04','FULL_TIME',5,'AVAILABLE','Stationery',4.4,'ACTIVE'),
(29,1029,3,'STAT-T05','FULL_TIME',6,'AVAILABLE','Stationery',4.5,'ACTIVE'),
(30,1030,3,'STAT-T06','FULL_TIME',7,'AVAILABLE','Stationery',4.6,'ACTIVE'),
(31,1031,3,'STAT-T07','FULL_TIME',8,'AVAILABLE','Stationery',4.7,'ACTIVE'),
(32,1032,3,'STAT-T08','FULL_TIME',9,'AVAILABLE','Stationery',4.8,'ACTIVE'),
(33,1033,3,'STAT-T09','FULL_TIME',10,'AVAILABLE','Stationery',4.9,'ACTIVE'),
(34,1034,3,'STAT-T10','FULL_TIME',11,'AVAILABLE','Stationery',4.0,'ACTIVE'),
(35,1035,3,'STAT-T11','FULL_TIME',12,'AVAILABLE','Stationery',4.1,'ACTIVE'),
(36,1036,3,'STAT-T12','FULL_TIME',13,'AVAILABLE','Stationery',4.2,'ACTIVE'),
(37,1037,4,'IT-T01','FULL_TIME',2,'AVAILABLE','IT Support',4.1,'ACTIVE'),
(38,1038,4,'IT-T02','FULL_TIME',3,'AVAILABLE','IT Support',4.2,'ACTIVE'),
(39,1039,4,'IT-T03','FULL_TIME',4,'AVAILABLE','IT Support',4.3,'ACTIVE'),
(40,1040,4,'IT-T04','FULL_TIME',5,'AVAILABLE','IT Support',4.4,'ACTIVE'),
(41,1041,4,'IT-T05','FULL_TIME',6,'AVAILABLE','IT Support',4.5,'ACTIVE'),
(42,1042,4,'IT-T06','FULL_TIME',7,'AVAILABLE','IT Support',4.6,'ACTIVE'),
(43,1043,4,'IT-T07','FULL_TIME',8,'AVAILABLE','IT Support',4.7,'ACTIVE'),
(44,1044,4,'IT-T08','FULL_TIME',9,'AVAILABLE','IT Support',4.8,'ACTIVE'),
(45,1045,4,'IT-T09','FULL_TIME',10,'AVAILABLE','IT Support',4.9,'ACTIVE'),
(46,1046,4,'IT-T10','FULL_TIME',11,'AVAILABLE','IT Support',4.0,'ACTIVE'),
(47,1047,4,'IT-T11','FULL_TIME',12,'AVAILABLE','IT Support',4.1,'ACTIVE'),
(48,1048,4,'IT-T12','FULL_TIME',13,'AVAILABLE','IT Support',4.2,'ACTIVE'),
(49,1049,5,'ACCT-T01','FULL_TIME',2,'AVAILABLE','Accounting',4.1,'ACTIVE'),
(50,1050,5,'ACCT-T02','FULL_TIME',3,'AVAILABLE','Accounting',4.2,'ACTIVE'),
(51,1051,5,'ACCT-T03','FULL_TIME',4,'AVAILABLE','Accounting',4.3,'ACTIVE'),
(52,1052,5,'ACCT-T04','FULL_TIME',5,'AVAILABLE','Accounting',4.4,'ACTIVE'),
(53,1053,5,'ACCT-T05','FULL_TIME',6,'AVAILABLE','Accounting',4.5,'ACTIVE'),
(54,1054,5,'ACCT-T06','FULL_TIME',7,'AVAILABLE','Accounting',4.6,'ACTIVE'),
(55,1055,5,'ACCT-T07','FULL_TIME',8,'AVAILABLE','Accounting',4.7,'ACTIVE'),
(56,1056,5,'ACCT-T08','FULL_TIME',9,'AVAILABLE','Accounting',4.8,'ACTIVE'),
(57,1057,5,'ACCT-T09','FULL_TIME',10,'AVAILABLE','Accounting',4.9,'ACTIVE'),
(58,1058,5,'ACCT-T10','FULL_TIME',11,'AVAILABLE','Accounting',4.0,'ACTIVE'),
(59,1059,5,'ACCT-T11','FULL_TIME',12,'AVAILABLE','Accounting',4.1,'ACTIVE'),
(60,1060,5,'ACCT-T12','FULL_TIME',13,'AVAILABLE','Accounting',4.2,'ACTIVE'),
(61,1061,6,'INFRA-T01','FULL_TIME',2,'AVAILABLE','Infrastructure',4.1,'ACTIVE'),
(62,1062,6,'INFRA-T02','FULL_TIME',3,'AVAILABLE','Infrastructure',4.2,'ACTIVE'),
(63,1063,6,'INFRA-T03','FULL_TIME',4,'AVAILABLE','Infrastructure',4.3,'ACTIVE'),
(64,1064,6,'INFRA-T04','FULL_TIME',5,'AVAILABLE','Infrastructure',4.4,'ACTIVE'),
(65,1065,6,'INFRA-T05','FULL_TIME',6,'AVAILABLE','Infrastructure',4.5,'ACTIVE'),
(66,1066,6,'INFRA-T06','FULL_TIME',7,'AVAILABLE','Infrastructure',4.6,'ACTIVE'),
(67,1067,6,'INFRA-T07','FULL_TIME',8,'AVAILABLE','Infrastructure',4.7,'ACTIVE'),
(68,1068,6,'INFRA-T08','FULL_TIME',9,'AVAILABLE','Infrastructure',4.8,'ACTIVE'),
(69,1069,6,'INFRA-T09','FULL_TIME',10,'AVAILABLE','Infrastructure',4.9,'ACTIVE'),
(70,1070,6,'INFRA-T10','FULL_TIME',11,'AVAILABLE','Infrastructure',4.0,'ACTIVE'),
(71,1071,6,'INFRA-T11','FULL_TIME',12,'AVAILABLE','Infrastructure',4.1,'ACTIVE'),
(72,1072,6,'INFRA-T12','FULL_TIME',13,'AVAILABLE','Infrastructure',4.2,'ACTIVE');
INSERT IGNORE INTO asset_category(category_id,category_name,description,default_criticality) VALUES (3,'IT & Computing','Computers, networking and IT infrastructure','HIGH'),(4,'HVAC','Heating, ventilation and air conditioning','HIGH'),(5,'Plumbing','Water and sanitary systems','MEDIUM'),(6,'Furniture','Campus furniture and fixtures','LOW');
INSERT IGNORE INTO asset(room_id,category_id,asset_code,asset_name,manufacturer,model,criticality_level) SELECT rm.room_id, CASE WHEN rm.room_type IN ('COMPUTER_LAB') THEN 3 WHEN rm.room_type IN ('SEMINAR_HALL','CLASSROOM','CONFERENCE_ROOM') THEN 1 WHEN rm.room_type='FACULTY_ROOM' THEN 6 ELSE 5 END, CONCAT('ENG-',rm.room_number,'-A01'), CASE WHEN rm.room_type='COMPUTER_LAB' THEN 'Computer Lab Workstation Set' WHEN rm.room_type='SEMINAR_HALL' THEN 'Seminar Hall AV System' WHEN rm.room_type='CLASSROOM' THEN 'Classroom Projector' WHEN rm.room_type='CONFERENCE_ROOM' THEN 'Conference AV System' WHEN rm.room_type='FACULTY_ROOM' THEN 'Faculty Room Furniture' ELSE 'Room Maintenance Asset' END, 'CampusCare','Standard', CASE WHEN rm.room_type IN ('COMPUTER_LAB','CLASSROOM','SEMINAR_HALL') THEN 'HIGH' ELSE 'MEDIUM' END FROM room rm WHERE rm.building_id=3;

-- Skills, preventive schedules, and extra stock for a richer local demonstration.
INSERT IGNORE INTO skill(skill_id,skill_name,description) VALUES
(4,'IT Support','Computer and network maintenance'),(5,'HVAC','Heating and ventilation'),
(6,'Facilities Operations','General campus facilities'),(7,'Office Equipment','Office and stationery equipment');
INSERT IGNORE INTO technician_skill(technician_id,skill_id,proficiency_level)
SELECT t.technician_id,s.skill_id,'PROFICIENT' FROM technician t
JOIN department d ON d.department_id=t.department_id
JOIN skill s ON s.skill_name=CASE d.department_code
  WHEN 'ELEC' THEN 'Electrical' WHEN 'SAN' THEN 'Plumbing'
  WHEN 'IT' THEN 'IT Support' WHEN 'INFRA' THEN 'Facilities Operations'
  WHEN 'STAT' THEN 'Office Equipment' ELSE 'Electrical' END;
INSERT IGNORE INTO inventory_item(item_code,item_name,item_type,unit,unit_cost,quantity_available,reorder_level,status) VALUES
('LED-9W','LED Bulb 9W','ELECTRICAL','piece',120,50,10,'AVAILABLE'),
('WASHER-SET','Tap Washer Set','PLUMBING','set',45,30,5,'AVAILABLE'),
('CAT6-5M','Cat6 Network Cable 5m','IT','piece',280,24,6,'AVAILABLE'),
('FILTER-HVAC','HVAC Filter','HVAC','piece',650,12,3,'AVAILABLE');
INSERT IGNORE INTO inventory_item(item_code,item_name,item_type,unit,unit_cost,quantity_available,reorder_level,status) VALUES
('ELEC-MCB-16A','16A Miniature Circuit Breaker','ELECTRICAL','piece',420,18,4,'AVAILABLE'),
('ELEC-SOCKET-6A','6A Electrical Socket','ELECTRICAL','piece',95,35,8,'AVAILABLE'),
('ELEC-SWITCH-6A','6A Modular Switch','ELECTRICAL','piece',65,40,10,'AVAILABLE'),
('ELEC-INS-TAPE','Insulation Tape Roll','ELECTRICAL','roll',55,42,10,'AVAILABLE'),
('ELEC-CABLE-TIE','Cable Tie Pack','ELECTRICAL','pack',90,25,6,'AVAILABLE'),
('ELEC-LED-TUBE','20W LED Tube Light','ELECTRICAL','piece',260,20,5,'AVAILABLE'),
('ELEC-FAN-CAP','Ceiling Fan Capacitor 2.5uF','ELECTRICAL','piece',110,16,4,'AVAILABLE'),
('HDMI-5M','HDMI Cable 5m','ELECTRONIC','piece',520,12,3,'AVAILABLE'),
('PROJ-REMOTE','Universal Projector Remote','AV','piece',850,8,2,'AVAILABLE'),
('PROJ-LAMP','Projector Replacement Lamp','AV','piece',4800,4,1,'AVAILABLE'),
('CAT6-10M','Cat6 Network Cable 10m','IT','piece',480,20,5,'AVAILABLE'),
('RJ45-50','RJ45 Connector Pack of 50','IT','pack',320,18,4,'AVAILABLE'),
('USB-KEYBOARD','USB Keyboard','IT','piece',550,10,3,'AVAILABLE'),
('USB-MOUSE','USB Optical Mouse','IT','piece',280,14,4,'AVAILABLE'),
('PVC-PIPE-1M','PVC Pipe 1m','PLUMBING','piece',180,24,6,'AVAILABLE'),
('PVC-ELBOW-1','PVC Elbow Joint 1 inch','PLUMBING','piece',35,35,8,'AVAILABLE'),
('TEFLON-TAPE','PTFE Thread Seal Tape','PLUMBING','roll',30,36,8,'AVAILABLE'),
('ANGLE-VALVE','Angle Valve','PLUMBING','piece',260,14,4,'AVAILABLE'),
('TAP-WASHER-SET','Tap Washer Set - assorted','PLUMBING','set',45,30,6,'AVAILABLE'),
('FLUSH-VALVE','Toilet Flush Valve','PLUMBING','piece',620,8,2,'AVAILABLE'),
('SOAP-1L','Liquid Hand Soap 1L','CLEANING','bottle',145,25,6,'AVAILABLE'),
('DISINFECTANT-5L','Surface Disinfectant 5L','CLEANING','can',680,10,3,'AVAILABLE'),
('MOP-HEAD','Replacement Mop Head','CLEANING','piece',190,18,5,'AVAILABLE'),
('DOOR-HINGE','Stainless Door Hinge','FACILITIES','piece',150,20,5,'AVAILABLE'),
('SCREW-SS-100','Stainless Screw Pack of 100','FACILITIES','pack',125,16,4,'AVAILABLE');
INSERT IGNORE INTO preventive_maintenance(asset_id,technician_id,maintenance_category_id,frequency,next_due_date,estimated_duration,required_skill,instructions,status)
SELECT a.asset_id,t.technician_id,1,'QUARTERLY',DATE_ADD(CURRENT_DATE,INTERVAL 30 DAY),60,'Electrical','Inspect connection, clean contacts, record condition.','SCHEDULED'
FROM asset a JOIN technician t ON t.department_id=1
WHERE a.criticality_level IN ('HIGH','CRITICAL') ORDER BY a.asset_id LIMIT 8;

INSERT IGNORE INTO `user`(user_name,first_name,last_name,email,role,password_hash,student_number,semester)
VALUES('demo.student','Aarav','Demo Student','student@campus.local','STUDENT','PENDING_HASH','STU-DEMO-001',5);

INSERT INTO maintenance_request(reported_by,asset_id,room_id,maintenance_category_id,title,description,priority,severity,current_status,reported_at)
SELECT s.user_id,(SELECT a.asset_id FROM asset a WHERE a.room_id=rm.room_id ORDER BY a.asset_id LIMIT 1),rm.room_id,c.maintenance_category_id,d.title,d.description,d.priority,d.severity,d.current_status,DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 15 MINUTE)
FROM (
 SELECT '[DEMO] Projector image flickers during lectures' title,'Projector image intermittently flickers, inspect cable and lamp.' description,'ENG' building_code,'104' room_number,'Equipment' category_name,'HIGH' priority,'HIGH' severity,'PENDING_APPROVAL' current_status
 UNION ALL SELECT '[DEMO] Water leak beneath laboratory sink','Water is pooling under the sink, inspect pipe joints and seal.','ENG','322','Plumbing','CRITICAL','CRITICAL','PENDING_APPROVAL'
 UNION ALL SELECT '[DEMO] Library Wi-Fi access point offline','Wireless access point near the reading area is not responding.','LIB','201','Equipment','HIGH','HIGH','PENDING_APPROVAL'
 UNION ALL SELECT '[DEMO] Ceiling fan making loud noise','Fan rattles while running, inspect mount and capacitor.','ENG','205','Electrical','MEDIUM','MEDIUM','PENDING_APPROVAL'
 UNION ALL SELECT '[DEMO] Corridor lights not working','Several lights near the seminar hall entrance are not working.','ENG','223','Electrical','HIGH','HIGH','PENDING_APPROVAL'
 UNION ALL SELECT '[DEMO] Replace damaged laboratory keyboard','A computer lab keyboard has missing keys and should be replaced.','ENG','323','Equipment','MEDIUM','MEDIUM','APPROVED'
 UNION ALL SELECT '[DEMO] Seminar display cable damaged','The display cable at the front desk is loose and loses signal.','ENG','122','Equipment','HIGH','HIGH','APPROVED'
 UNION ALL SELECT '[DEMO] Washroom tap valve leaking','Tap valve continues to drip, replace washer or valve.','ENG','112','Plumbing','HIGH','HIGH','APPROVED'
 UNION ALL SELECT '[DEMO] Loose electrical outlet near office','Wall outlet is loose and the connection drops when cable moves.','ENG','113','Electrical','MEDIUM','MEDIUM','ASSIGNED'
 UNION ALL SELECT '[DEMO] Drain odor near wash area','Drain needs inspection and cleaning, odor affects nearby rooms.','ENG','214','Plumbing','HIGH','HIGH','IN_PROGRESS'
 UNION ALL SELECT '[DEMO] Door hinge needs adjustment','The classroom door hinge is loose and needs adjustment.','ENG','111','Electrical','LOW','LOW','ON_HOLD'
 UNION ALL SELECT '[DEMO] Projector power connector request','Request to replace the projector connector was declined pending review.','ACA','401','Equipment','HIGH','HIGH','REJECTED'
) d JOIN `user` s ON s.email='student@campus.local'
JOIN building b ON b.building_code=d.building_code
JOIN room rm ON rm.building_id=b.building_id AND rm.room_number=d.room_number
JOIN maintenance_category c ON c.category_name=d.category_name
WHERE NOT EXISTS(SELECT 1 FROM maintenance_request old WHERE old.title=d.title);

INSERT INTO request_approval(request_id,reviewer_id,decision,review_notes,reviewed_at)
SELECT r.request_id,IF(r.current_status='PENDING_APPROVAL',NULL,staff.user_id),CASE r.current_status WHEN 'PENDING_APPROVAL' THEN 'PENDING' WHEN 'REJECTED' THEN 'REJECTED' ELSE 'APPROVED' END,IF(r.current_status='PENDING_APPROVAL',NULL,'Seeded workflow demonstration'),IF(r.current_status='PENDING_APPROVAL',NULL,DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 10 MINUTE))
FROM maintenance_request r JOIN `user` staff ON staff.email='staff@campus.local'
WHERE r.title LIKE '[DEMO] %' AND NOT EXISTS(SELECT 1 FROM request_approval a WHERE a.request_id=r.request_id);

INSERT INTO sla_tracking(request_id,sla_id,response_deadline,resolution_deadline)
SELECT r.request_id,p.sla_id,DATE_ADD(r.reported_at,INTERVAL p.response_time_minutes MINUTE),DATE_ADD(r.reported_at,INTERVAL p.resolution_time_minutes MINUTE)
FROM maintenance_request r JOIN sla_policy p ON p.priority=r.priority AND p.severity=r.severity AND p.status='ACTIVE'
WHERE r.title LIKE '[DEMO] %' AND NOT EXISTS(SELECT 1 FROM sla_tracking x WHERE x.request_id=r.request_id);

INSERT INTO work_assignment(request_id,technician_id,assigned_by,assigned_at,accepted_at,started_at,assignment_status,assignment_notes)
SELECT r.request_id,t.technician_id,admin.user_id,DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 8 MINUTE),IF(r.current_status='ASSIGNED',NULL,DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 7 MINUTE)),IF(r.current_status='ASSIGNED',NULL,DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 6 MINUTE)),IF(r.current_status='ASSIGNED','ASSIGNED','IN_PROGRESS'),'Seeded demonstration assignment'
FROM maintenance_request r JOIN `user` admin ON admin.email='admin@campus.local'
JOIN `user` techuser ON techuser.email=CASE r.title WHEN '[DEMO] Loose electrical outlet near office' THEN 'elec.tech03@campus.local' WHEN '[DEMO] Drain odor near wash area' THEN 'san.tech04@campus.local' WHEN '[DEMO] Door hinge needs adjustment' THEN 'infra.tech04@campus.local' ELSE '' END
JOIN technician t ON t.user_id=techuser.user_id
WHERE r.title IN ('[DEMO] Loose electrical outlet near office','[DEMO] Drain odor near wash area','[DEMO] Door hinge needs adjustment')
AND NOT EXISTS(SELECT 1 FROM work_assignment wa WHERE wa.request_id=r.request_id);

UPDATE technician t SET availability_status='BUSY'
WHERE EXISTS(SELECT 1 FROM work_assignment wa WHERE wa.technician_id=t.technician_id AND wa.assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS'));

INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note,created_at)
SELECT r.request_id,r.reported_by,'REQUEST_SUBMITTED',NULL,'PENDING_APPROVAL','Demonstration request for project walkthrough',r.reported_at FROM maintenance_request r
WHERE r.title LIKE '[DEMO] %' AND NOT EXISTS(SELECT 1 FROM request_event e WHERE e.request_id=r.request_id AND e.event_type='REQUEST_SUBMITTED');
INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note,created_at)
SELECT r.request_id,a.reviewer_id,IF(a.decision='REJECTED','FACULTY_REJECTED','FACULTY_APPROVED'),'PENDING_APPROVAL',a.decision,'Demonstration review decision',a.reviewed_at FROM maintenance_request r JOIN request_approval a ON a.request_id=r.request_id
WHERE r.title LIKE '[DEMO] %' AND a.decision<>'PENDING' AND NOT EXISTS(SELECT 1 FROM request_event e WHERE e.request_id=r.request_id AND e.event_type IN ('FACULTY_APPROVED','FACULTY_REJECTED'));
INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note,created_at)
SELECT r.request_id,wa.assigned_by,'TECHNICIAN_ASSIGNED','APPROVED','ASSIGNED','Demonstration technician assignment',wa.assigned_at FROM maintenance_request r JOIN work_assignment wa ON wa.request_id=r.request_id
WHERE r.title LIKE '[DEMO] %' AND NOT EXISTS(SELECT 1 FROM request_event e WHERE e.request_id=r.request_id AND e.event_type='TECHNICIAN_ASSIGNED');
INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note,created_at)
SELECT r.request_id,t.user_id,'TECHNICIAN_STATUS_CHANGE','ASSIGNED',r.current_status,'Demonstration work status',wa.started_at FROM maintenance_request r JOIN work_assignment wa ON wa.request_id=r.request_id JOIN technician t ON t.technician_id=wa.technician_id
WHERE r.title LIKE '[DEMO] %' AND r.current_status IN ('IN_PROGRESS','ON_HOLD') AND NOT EXISTS(SELECT 1 FROM request_event e WHERE e.request_id=r.request_id AND e.event_type='TECHNICIAN_STATUS_CHANGE');



