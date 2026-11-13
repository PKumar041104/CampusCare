import Shell from "../../components/Shell";
import {requirePageUser} from "../../lib/auth";
import {pool} from "../../lib/db";

export default async function ProfilePage(){
 const user=await requirePageUser(),qt=String.fromCharCode(96)+"user"+String.fromCharCode(96);
 const [rows]:any=await pool.query("SELECT user_id,user_name,first_name,middle_name,last_name,email,phone_number,role,status,student_number,employee_number,department_name,semester,created_at FROM "+qt+" WHERE user_id=?",[user.id]);
 const p=rows[0];
 return <Shell user={user}><div className="page-title-row"><div><div className="eyebrow">ACCOUNT DETAILS</div><h1 className="page-title">My profile</h1><p className="page-subtitle">Your campus identity and role access.</p></div></div>
  <section className="panel" style={{maxWidth:760}}><div className="detail-summary"><div className="row"><span className="avatar" style={{width:48,height:48,fontSize:16}}>{user.name.split(/\s+/).map(x=>x[0]).slice(0,2).join("").toUpperCase()}</span><div><h2 className="panel-title" style={{fontSize:17}}>{p.first_name} {p.last_name}</h2><div className="muted" style={{fontSize:10,marginTop:4}}>{p.email}</div></div></div><span className="badge APPROVED">{p.role}</span></div>
   <div className="detail-meta"><div className="meta-item"><small>Account status</small><strong>{p.status}</strong></div><div className="meta-item"><small>Member since</small><strong>{new Date(p.created_at).toLocaleDateString("en-IN")}</strong></div>{p.student_number&&<div className="meta-item"><small>Student ID</small><strong>{p.student_number}</strong></div>}{p.semester&&<div className="meta-item"><small>Semester</small><strong>{p.semester}</strong></div>}{p.employee_number&&<div className="meta-item"><small>Employee ID</small><strong>{p.employee_number}</strong></div>}{p.department_name&&<div className="meta-item"><small>Department</small><strong>{p.department_name}</strong></div>}{p.phone_number&&<div className="meta-item"><small>Phone</small><strong>{p.phone_number}</strong></div>}</div>
  </section>
 </Shell>;
}
