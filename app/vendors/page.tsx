import Shell from "../../components/Shell";
import StatusBadge from "../../components/StatusBadge";
import {requirePageUser} from "../../lib/auth";
import {pool} from "../../lib/db";
const date=(v:any)=>v?new Date(v).toLocaleDateString("en-IN"):"Not set";
export default async function Page(){
 const user=await requirePageUser(["ADMIN"]);
 const [rows]:any=await pool.query("SELECT vendor_id,vendor_name,contact_person,service_type,phone,email,contract_start_date,contract_end_date,rating,status FROM vendor ORDER BY vendor_name");
 return <Shell user={user}><div className="page-title-row"><div><div className="eyebrow">EXTERNAL SERVICE PARTNERS</div><h1 className="page-title">Vendors</h1><p className="page-subtitle">Campus contractors linked to maintenance operations.</p></div></div><section className="panel">{rows.length?<div className="table-wrap"><table className="table"><thead><tr><th>Vendor</th><th>Service</th><th>Contact</th><th>Contract dates</th><th>Rating</th><th>Status</th></tr></thead><tbody>{rows.map((v:any)=><tr key={v.vendor_id}><td className="table-title">{v.vendor_name}<span className="table-sub">{v.email||"No email"}</span></td><td>{v.service_type||"General"}</td><td>{v.contact_person}<span className="table-sub">{v.phone||"No phone"}</span></td><td>{date(v.contract_start_date)} - {date(v.contract_end_date)}</td><td>{v.rating==null?"Not rated":Number(v.rating).toFixed(1)+" / 5"}</td><td><StatusBadge value={v.status}/></td></tr>)}</tbody></table></div>:<div className="empty-state">No vendors are registered.</div>}</section></Shell>;
}