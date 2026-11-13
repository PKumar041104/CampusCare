import { NextResponse } from "next/server";
import { AuthError, requireApiUser } from "../../../../lib/auth";
import { pool } from "../../../../lib/db";
import { recordEvent } from "../../../../lib/events";
import { sameOrigin } from "../../../../lib/http";
import { cleanText, parsePositiveId } from "../../../../lib/workflow";

export async function POST(req: Request) {
  if (!sameOrigin(req)) return NextResponse.json({ error: "Invalid request origin." }, { status: 403 });
  let user;
  try { user = await requireApiUser(["FACULTY","STAFF"]); }
  catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : "Sign in required." }, { status: error instanceof AuthError ? error.status : 500 }); }
  const form=await req.formData();
  const requestId=parsePositiveId(form.get("request_id"));
  const decision=String(form.get("decision")||"");
  const remarks=cleanText(form.get("remarks"),1000);
  if(!requestId||!["APPROVED","REJECTED"].includes(decision)) return NextResponse.json({error:"Choose a valid review decision."},{status:400});
  const connection=await pool.getConnection();
  try{
    await connection.beginTransaction();
    const [rows]:any=await connection.query("SELECT reported_by,current_status FROM maintenance_request WHERE request_id=? FOR UPDATE",[requestId]);
    if(!rows.length||rows[0].current_status!=="PENDING_APPROVAL") throw Object.assign(new Error("This request is no longer awaiting review."),{status:409});
    if(Number(rows[0].reported_by)===user.id) throw Object.assign(new Error("You cannot review a request you submitted."),{status:403});
    const [pending]:any=await connection.query("SELECT approval_id FROM request_approval WHERE request_id=? AND decision='PENDING' ORDER BY created_at DESC LIMIT 1 FOR UPDATE",[requestId]);
    if(!pending.length) throw Object.assign(new Error("Pending approval record is missing."),{status:409});
    await connection.query("SET @campuscare_actor_id=?",[user.id]);
    await connection.query("UPDATE request_approval SET reviewer_id=?,decision=?,review_notes=?,reviewed_at=CURRENT_TIMESTAMP WHERE approval_id=?",[user.id,decision,remarks||null,pending[0].approval_id]);
    await connection.query("UPDATE maintenance_request SET current_status=? WHERE request_id=?",[decision,requestId]);
    await connection.query("INSERT INTO request_event(request_id,user_id,event_type,old_status,new_status,note) VALUES(?,?,?,?,?,?)",[requestId,user.id,"FACULTY_"+decision,"PENDING_APPROVAL",decision,remarks||null]);
    await connection.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,old_value,new_value) VALUES(?,'request_approval',?,'REVIEW','PENDING',?)",[user.id,String(requestId),decision+(remarks?": "+remarks:"")]);
    await connection.commit();
  }catch(error:any){
    await connection.rollback();
    return NextResponse.json({error:error instanceof Error?error.message:"Review could not be saved."},{status:error?.status||400});
  }finally{connection.release();}
  await recordEvent({eventType:"FACULTY_"+decision,requestId,actorId:user.id,remarks});
  return NextResponse.redirect(new URL("/requests/"+requestId+"?reviewed=1",req.url),303);
}

