const bcrypt=require("bcryptjs"),fs=require("fs"),path=require("path"),mysql=require("mysql2/promise");
const {MongoClient}=require("mongodb");
const {ensureCampusCareCollections}=require("../database/mongodb/collections");
const quote=String.fromCharCode(96),userTable=quote+"user"+quote;

function loadEnv(){
  for(const name of [".env",".env.local"]){
    const file=path.join(process.cwd(),name);
    if(!fs.existsSync(file)) continue;
    for(const line of fs.readFileSync(file,"utf8").split(/\r?\n/)){
      const match=line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
      if(!match||process.env[match[1]]!==undefined) continue;
      let value=match[2].trim();
      if((value.startsWith('"')&&value.endsWith('"'))||(value.startsWith("'")&&value.endsWith("'"))) value=value.slice(1,-1);
      process.env[match[1]]=value;
    }
  }
}
function splitSql(source){
  let delimiter=";",buffer="",out=[];
  for(const line of source.replace(/^\uFEFF/,"").split(/\r?\n/)){
    const directive=line.trim().match(/^DELIMITER\s+(\S+)$/i);
    if(directive){delimiter=directive[1];continue;}
    if(/^\s*--/.test(line)||/^\s*#/.test(line)) continue;
    buffer+=line+"\n";
    let at;
    while((at=buffer.indexOf(delimiter))!==-1){
      const statement=buffer.slice(0,at).trim();if(statement)out.push(statement);
      buffer=buffer.slice(at+delimiter.length);
    }
  }
  if(buffer.trim())out.push(buffer.trim());
  return out;
}
async function hasColumn(db,table,column){
  const [rows]=await db.query("SELECT COUNT(*) total FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",[table,column]);
  return Number(rows[0].total)>0;
}
async function ensureColumn(db,table,column,definition){
  if(!(await hasColumn(db,table,column))) await db.query("ALTER TABLE "+quote+table+quote+" ADD COLUMN "+quote+column+quote+" "+definition);
}
async function migrate(db){
  await db.query("CREATE TABLE IF NOT EXISTS schema_migrations(version VARCHAR(40) PRIMARY KEY,applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB");
  for(const [column,definition] of [["student_number","VARCHAR(40) NULL UNIQUE"],["employee_number","VARCHAR(40) NULL UNIQUE"],["department_name","VARCHAR(120) NULL"],["semester","TINYINT NULL"]]) await ensureColumn(db,"user",column,definition);
  await db.query("ALTER TABLE maintenance_request MODIFY current_status ENUM('PENDING_APPROVAL','APPROVED','REJECTED','REPORTED','ASSIGNED','IN_PROGRESS','ON_HOLD','RESOLVED','CLOSED','CANCELLED') NOT NULL DEFAULT 'PENDING_APPROVAL'");
  await db.query("ALTER TABLE maintenance_request MODIFY asset_id INT NULL");
  await db.query("ALTER TABLE request_approval MODIFY reviewer_id INT NULL");
  await db.query("UPDATE maintenance_request SET current_status='PENDING_APPROVAL' WHERE current_status='REPORTED'");
  await db.query("INSERT INTO request_approval(request_id,reviewer_id,decision) SELECT r.request_id,NULL,'PENDING' FROM maintenance_request r LEFT JOIN request_approval a ON a.request_id=r.request_id AND a.decision='PENDING' WHERE r.current_status='PENDING_APPROVAL' AND a.approval_id IS NULL");
  await db.query("UPDATE "+userTable+" SET password_hash='PENDING_HASH' WHERE email IN ('admin@campus.local','staff@campus.local') AND password_hash='$2a$10$2b2VQXyX0j6B8R1xj5lZ9e6xvVqk3bqzX7n1ZfY8g1x0wJ3eQ4h2K'");
  const [pmIndex]=await db.query("SELECT COUNT(*) total FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='preventive_maintenance' AND INDEX_NAME='uq_pm_asset_category_frequency'");
  if(Number(pmIndex[0].total)===0)await db.query("ALTER TABLE preventive_maintenance ADD UNIQUE KEY uq_pm_asset_category_frequency(asset_id,maintenance_category_id,frequency)");  await db.query("INSERT IGNORE INTO schema_migrations(version) VALUES('001-role-workflow-and-sessions')");
}
async function main(){
  loadEnv();
  const db=await mysql.createConnection({host:process.env.MYSQL_HOST||"127.0.0.1",port:Number(process.env.MYSQL_PORT||3306),user:process.env.MYSQL_USER||"root",password:process.env.MYSQL_PASSWORD||"",multipleStatements:false});
  try{
    for(const file of ["schema.sql","seed.sql","advanced.sql"]){
      const sql=fs.readFileSync(path.join(__dirname,"../database/mysql",file),"utf8");
      for(const statement of splitSql(sql)) await db.query(statement);
      console.log("Applied "+file);
      if(file==="schema.sql") await migrate(db);
    }
    for(const [email,password] of [["admin@campus.local","Admin123!"],["staff@campus.local","Staff123!"],["faculty@campus.local","Faculty123!"],["student@campus.local","Student123!"]]){
      await db.query("UPDATE "+userTable+" SET password_hash=? WHERE email=? AND password_hash='PENDING_HASH'",[await bcrypt.hash(password,12),email]);
    }
    await db.query("UPDATE "+userTable+" SET password_hash=? WHERE role='TECHNICIAN' AND password_hash='PENDING_HASH'",[await bcrypt.hash("Tech123!",12)]);
  }finally{await db.end();}
  if(process.env.MONGODB_ENABLED!=="false"){
    const mongo=new MongoClient(process.env.MONGODB_URI||"mongodb://127.0.0.1:27017",{serverSelectionTimeoutMS:4000});
    try{await mongo.connect();await ensureCampusCareCollections(mongo.db(process.env.MONGODB_DATABASE||"smart_campus_events"));console.log("MongoDB event indexes are ready");}
    finally{await mongo.close();}
  }else console.log("MongoDB setup skipped because MONGODB_ENABLED=false");
  console.log("Database setup complete; existing project records were preserved.");
}
main().catch(error=>{console.error("Database setup failed:",error.message||error);process.exitCode=1;});



