import { NextResponse } from "next/server";
import { AuthError, requireApiUser } from "../../../../lib/auth";
import { pool } from "../../../../lib/db";
import { recordEvent } from "../../../../lib/events";
import { sameOrigin } from "../../../../lib/http";
import { canTechnicianTransition, cleanText, parsePositiveId } from "../../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req))return NextResponse.json({error:"Invalid request origin."},{status:403});
  let user;
  try{user=await requireApiUser(["TECHNICIAN"]);}catch(error){return NextResponse.json({error:error instanceof Error?error.message:"Sign in required."},{status:error instanceof AuthError?error.status:500});}
  if(!user.technicianId)return NextResponse.json({error:"Technician profile missing."},{status:403});
  const form=await req.formData(),requestId=parsePositiveId(form.get("request_id")),next=String(form.get("status")||"");
  const note=cleanText(form.get("note"),1500),resolution=cleanText(form.get("resolution"),2000);
  if(!requestId||!["IN_PROGRESS","ON_HOLD","RESOLVED"].includes(next))return NextResponse.json({error:"Choose a valid work update."},{status:400});
  if(next==="ON_HOLD"&&note.length<5)return NextResponse.json({error:"Explain why the work is blocked."},{status:400});
  if(next==="RESOLVED"&&resolution.length<10)return NextResponse.json({error:"Add resolution details before completing the job."},{status:400});

  const connection=await pool.getConnection();let oldStatus="";let assignmentId=0;
  try{
    await connection.beginTransaction();
    const [rows]:any=await connection.query(
      "SELECT r.current_status,wa.assignment_id FROM maintenance_request r JOIN work_assignment wa ON wa.request_id=r.request_id "+
      "WHERE r.request_id=? AND wa.technician_id=? AND wa.assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS') "+
      "ORDER BY wa.assigned_at DESC LIMIT 1 FOR UPDATE",[requestId,user.technicianId]);
    if(!rows.length)throw Object.assign(new Error("This work order is not assigned to your account."),{status:403});
    oldStatus=rows[0].current_status;assignmentId=Number(rows[0].assignment_id);
    if(!canTechnicianTransition(oldStatus,next))throw Object.assign(new Error("That status change is not allowed from the current stage."),{status:409});
    await connection.query("SET @campuscare_actor_id=?",[user.id]);
    if(next==="IN_PROGRESS"){
      await connection.query("UPDATE work_assignment SET assignment_status='IN_PROGRESS',accepted_at=COALESCE(accepted_at,CURRENT_TIMESTAMP),started_at=COALESCE(started_at,CURRENT_TIMESTAMP) WHERE assignment_id=?",[assignmentId]);
      await connection.query("UPDATE sla_tracking SET actual_response_time=COALESCE(actual_response_time,CURRENT_TIMESTAMP) WHERE request_id=?",[requestId]);
    }
    if(next==="RESOLVED"){
      await connection.query("UPDATE work_assignment SET assignment_status='COMPLETED',completed_at=CURRENT_TIMESTAMP WHERE assignment_id=?",[assignmentId]);
      await connection.query("UPDATE sla_tracking SET actual_resolution_time=CURRENT_TIMESTAMP,sla_status=CASE WHEN CURRENT_TIMESTAMP>resolution_deadline THEN 'BREACHED' ELSE 'COMPLETED' END,resolution_breached=(CURRENT_TIMESTAMP>resolution_deadline) WHERE request_id=?",[requestId]);
    }
    await connection.query("UPDATE maintenance_request SET current_status=?,resolution_summary=IF(?='RESOLVED',?,resolution_summary),resolved_at=IF(?='RESOLVED',CURRENT_TIMESTAMP,resolved_at) WHERE request_id=?",[next,next,resolution||null,next,requestId]);
    await connection.query("INSERT INTO maintenance_activity(assignment_id,user_id,technician_id,activity_type,activity_description,old_status,new_status,start_time,end_time) VALUES(?,?,?,?,?,?,?,?,?)",
      [assignmentId,user.id,user.technicianId,next==="RESOLVED"?"RESOLUTION":"STATUS_UPDATE",resolution||note||"Work status updated",oldStatus,next,next==="IN_PROGRESS"?new Date():null,next==="RESOLVED"?new Date():null]);
    await connection.query("INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note) VALUES(?,?,?,?,?,?)",[requestId,user.id,"TECHNICIAN_STATUS_CHANGE",oldStatus,next,resolution||note||null]);
    if(next==="RESOLVED")await connection.query(
      "UPDATE technician t SET availability_status=CASE WHEN EXISTS(SELECT 1 FROM work_assignment wa WHERE wa.technician_id=t.technician_id AND wa.assignment_status IN ('ASSIGNED','ACCEPTED','IN_PROGRESS')) THEN 'BUSY' ELSE 'AVAILABLE' END WHERE technician_id=?",
      [user.technicianId]);
    await connection.commit();
  }catch(error:any){await connection.rollback();return NextResponse.json({error:error instanceof Error?error.message:"Work update could not be saved."},{status:error?.status||400});}
  finally{connection.release();}
  await recordEvent({eventType:"TECHNICIAN_STATUS_CHANGE",requestId,actorId:user.id,oldStatus,newStatus:next,note:resolution||note});
  return NextResponse.redirect(new URL("/requests/"+requestId+"?updated=1",req.url),303);
}
