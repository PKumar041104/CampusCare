import Link from "next/link";
import Shell from "../../components/Shell";
import StatusBadge from "../../components/StatusBadge";
import {requirePageUser} from "../../lib/auth";
import {pool} from "../../lib/db";

export default async function ApprovalsPage(){
 const user=await requirePageUser(["FACULTY","STAFF"]),qt=String.fromCharCode(96)+"user"+String.fromCharCode(96);
 const [pending]:any=await pool.query("SELECT r.request_id,r.title,r.priority,r.reported_at,u.first_name,u.last_name,mc.category_name,b.building_name,rm.room_number FROM maintenance_request r JOIN "+qt+" u ON u.user_id=r.reported_by JOIN maintenance_category mc ON mc.maintenance_category_id=r.maintenance_category_id JOIN room rm ON rm.room_id=r.room_id JOIN building b ON b.building_id=rm.building_id WHERE r.current_status='PENDING_APPROVAL' AND r.reported_by<>? ORDER BY FIELD(r.priority,'CRITICAL','HIGH','MEDIUM','LOW'),r.reported_at",[user.id]);
 const [reviewed]:any=await pool.query("SELECT a.decision,a.review_notes,a.reviewed_at,r.request_id,r.title,r.priority,u.first_name,u.last_name FROM request_approval a JOIN maintenance_request r ON r.request_id=a.request_id JOIN "+qt+" u ON u.user_id=r.reported_by WHERE a.reviewer_id=? ORDER BY a.reviewed_at DESC LIMIT 10",[user.id]);
 return <Shell user={user}><div className="page-title-row"><div><div className="eyebrow">FACULTY & STAFF</div><h1 className="page-title">Approval queue</h1><p className="page-subtitle">Review student and campus requests before they enter technician allocation.</p></div><Link className="btn secondary" href="/requests/new">Create a request</Link></div>
  <section className="panel"><div className="panel-head"><div><h3 className="panel-title">Awaiting your review <span className="badge PENDING">{pending.length}</span></h3><p className="panel-caption">High urgency requests are listed first.</p></div></div>
   {pending.length?<div className="table-wrap"><table className="table"><thead><tr><th>Ticket</th><th>Requester</th><th>Location</th><th>Category</th><th>Urgency</th><th>Open</th></tr></thead><tbody>{pending.map((r:any)=><tr key={r.request_id}><td className="table-title">CC-{String(r.request_id).padStart(6,"0")}<span className="table-sub">{r.title}</span></td><td>{r.first_name} {r.last_name}</td><td>{r.building_name}<span className="table-sub">Room {r.room_number}</span></td><td>{r.category_name}</td><td><StatusBadge value={r.priority}/></td><td><Link className="text-link" href={"/requests/"+r.request_id}>Review</Link></td></tr>)}</tbody></table></div>:<div className="empty-state"><strong>No requests are waiting for review</strong>New requests will appear here after submission.</div>}
  </section>
  <section className="panel" style={{marginTop:14}}><div className="panel-head"><div><h3 className="panel-title">Your recent decisions</h3><p className="panel-caption">A traceable record of your approval history.</p></div></div>{reviewed.length?<div className="table-wrap"><table className="table"><thead><tr><th>Ticket / request</th><th>Decision</th><th>Remarks</th><th>Reviewed</th></tr></thead><tbody>{reviewed.map((r:any,i:number)=><tr key={i}><td><Link className="table-title" href={"/requests/"+r.request_id}>CC-{String(r.request_id).padStart(6,"0")}<span className="table-sub">{r.title}   {r.first_name} {r.last_name}</span></Link></td><td><StatusBadge value={r.decision}/></td><td>{r.review_notes||"No remarks."}</td><td>{r.reviewed_at?new Date(r.reviewed_at).toLocaleDateString("en-IN"):"Not recorded"}</td></tr>)}</tbody></table></div>:<div className="empty-state">Your decisions will be listed here.</div>}</section>
 </Shell>;
}


