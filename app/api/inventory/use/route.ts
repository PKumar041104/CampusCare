import {NextResponse} from "next/server";
import {AuthError,requireApiUser} from "../../../../lib/auth";
import {pool} from "../../../../lib/db";
import {recordEvent} from "../../../../lib/events";
import {sameOrigin} from "../../../../lib/http";
import {cleanText,parsePositiveId} from "../../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req))return NextResponse.json({error:"Invalid request origin."},{status:403});
  let user;try{user=await requireApiUser(["TECHNICIAN"]);}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"Sign in required."},{status:e instanceof AuthError?e.status:500});}
  const f=await req.formData(),requestId=parsePositiveId(f.get("request_id")),itemId=parsePositiveId(f.get("item_id")),quantity=Number(f.get("quantity")),note=cleanText(f.get("note"),300);
  if(!requestId||!itemId||!Number.isFinite(quantity)||quantity<=0||quantity>1000)return NextResponse.json({error:"Enter a valid part quantity."},{status:400});
  const c=await pool.getConnection();
  try{
    await c.beginTransaction();
    const [jobs]:any=await c.query("SELECT wa.assignment_id FROM work_assignment wa JOIN maintenance_request r ON r.request_id=wa.request_id WHERE wa.request_id=? AND wa.technician_id=? AND wa.assignment_status='IN_PROGRESS' AND r.current_status='IN_PROGRESS' FOR UPDATE",[requestId,user.technicianId]);
    if(!jobs.length)throw Object.assign(new Error("Parts can be recorded only on your in-progress work."),{status:403});
    const [items]:any=await c.query("SELECT item_id,unit_cost FROM inventory_item WHERE item_id=? AND status<>'INACTIVE' FOR UPDATE",[itemId]);
    if(!items.length)throw new Error("Choose an active inventory item.");
    await c.query("SET @campuscare_actor_id=?",[user.id]);
    await c.query("INSERT INTO part_usage(assignment_id,item_id,quantity_used,unit_cost) VALUES(?,?,?,?)",[jobs[0].assignment_id,itemId,quantity,items[0].unit_cost]);
    await c.query("INSERT INTO maintenance_activity(assignment_id,user_id,technician_id,activity_type,activity_description) VALUES(?,?,?,'PART_USED',?)",[jobs[0].assignment_id,user.id,user.technicianId,note||"Inventory part recorded"]);
    await c.query("INSERT INTO request_event(request_id,user_id,event_type,note) VALUES(?,?,'PART_USED',?)",[requestId,user.id,note||"Inventory part recorded"]);
    await c.commit();
  }catch(e:any){await c.rollback();return NextResponse.json({error:e instanceof Error?e.message:"Inventory update failed."},{status:e?.status||400});}
  finally{c.release();}
  await recordEvent({eventType:"PART_USED",requestId,actorId:user.id,itemId,quantity});
  return NextResponse.redirect(new URL("/requests/"+requestId+"?parts=1",req.url),303);
}
