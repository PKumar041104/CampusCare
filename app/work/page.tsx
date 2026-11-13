import Link from "next/link";
import Shell from "../../components/Shell";
import StatusBadge from "../../components/StatusBadge";
import {requirePageUser} from "../../lib/auth";
import {pool} from "../../lib/db";

export default async function WorkPage({searchParams}:{searchParams:{q?:string,status?:string}}){
 const user=await requirePageUser(["TECHNICIAN"]),techId=user.technicianId||0;
 const status=String(searchParams?.status||""),q=String(searchParams?.q||"").trim().slice(0,80);
 const where=["wa.technician_id=?","wa.assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS','COMPLETED')"],args:any[]=[techId];
 if(["ASSIGNED","IN_PROGRESS","ON_HOLD","RESOLVED","CLOSED"].includes(status)){where.push("r.current_status=?");args.push(status);}
 if(q){where.push("(r.title LIKE ? OR b.building_name LIKE ? OR rm.room_number LIKE ? OR CAST(r.request_id AS CHAR) LIKE ?)");args.push("%"+q+"%","%"+q+"%","%"+q+"%","%"+q+"%");}
 const [rows]:any=await pool.query("SELECT r.request_id,r.title,r.priority,r.current_status,r.reported_at,mc.category_name,b.building_name,rm.room_number,wa.assigned_at,wa.assignment_status FROM work_assignment wa JOIN maintenance_request r ON r.request_id=wa.request_id JOIN maintenance_category mc ON mc.maintenance_category_id=r.maintenance_category_id JOIN room rm ON rm.room_id=r.room_id JOIN building b ON b.building_id=rm.building_id WHERE "+where.join(" AND ")+" ORDER BY FIELD(r.current_status,'ASSIGNED','IN_PROGRESS','ON_HOLD','RESOLVED','CLOSED'),wa.assigned_at DESC LIMIT 200",args);
 return <Shell user={user}><div className="page-title-row"><div><div className="eyebrow">TECHNICIAN WORKSPACE</div><h1 className="page-title">My work orders</h1><p className="page-subtitle">Only work assigned to your technician profile is shown here.</p></div></div>
  <section className="panel"><form className="filters" method="get"><input className="input" name="q" defaultValue={q} placeholder="Search issue, ticket or location"/><select className="select" name="status" defaultValue={status}><option value="">All stages</option>{["ASSIGNED","IN_PROGRESS","ON_HOLD","RESOLVED","CLOSED"].map(s=><option key={s}>{s}</option>)}</select><button className="btn secondary small">Filter jobs</button></form>
  {rows.length?<div className="table-wrap"><table className="table"><thead><tr><th>Ticket / issue</th><th>Location</th><th>Category</th><th>Priority</th><th>Current stage</th><th>Assigned</th></tr></thead><tbody>{rows.map((r:any)=><tr key={r.request_id}><td><Link className="table-title" href={"/requests/"+r.request_id}>CC-{String(r.request_id).padStart(6,"0")}<span className="table-sub">{r.title}</span></Link></td><td>{r.building_name}<span className="table-sub">Room {r.room_number}</span></td><td>{r.category_name}</td><td><StatusBadge value={r.priority}/></td><td><StatusBadge value={r.current_status}/></td><td>{new Date(r.assigned_at).toLocaleDateString("en-IN")}</td></tr>)}</tbody></table></div>:<div className="empty-state"><strong>Your work list is clear</strong>New jobs will appear after an administrator assigns them.</div>}</section>
 </Shell>;
}
