import { NextResponse } from "next/server";
import { AuthError, requireApiUser } from "../../../lib/auth";
import { pool } from "../../../lib/db";
import { recordEvent } from "../../../lib/events";
import { sameOrigin } from "../../../lib/http";
import { cleanText, parsePositiveId } from "../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req))return NextResponse.json({error:"Invalid request origin."},{status:403});
  let user;try{user=await requireApiUser(["STUDENT"]);}catch(error){return NextResponse.json({error:error instanceof Error?error.message:"Sign in required."},{status:error instanceof AuthError?error.status:500});}
  const form=await req.formData(),requestId=parsePositiveId(form.get("request_id")),rating=Number(form.get("rating")),comments=cleanText(form.get("comments"),1000);
  if(!requestId||!Number.isInteger(rating)||rating<1||rating>5)return NextResponse.json({error:"Select a rating from 1 to 5."},{status:400});
  try{
    const [rows]:any=await pool.query("SELECT current_status FROM maintenance_request WHERE request_id=? AND reported_by=?",[requestId,user.id]);
    if(!rows.length)return NextResponse.json({error:"Request not found."},{status:404});
    if(!["RESOLVED","CLOSED"].includes(rows[0].current_status))return NextResponse.json({error:"Feedback is available after work is completed."},{status:409});
    await pool.query("INSERT INTO request_feedback(request_id,submitted_by,rating,comments) VALUES(?,?,?,?)",[requestId,user.id,rating,comments||null]);
    await pool.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,new_value) VALUES(?,'request_feedback',?,'CREATE',?)",[user.id,String(requestId),String(rating)]);
  }catch(error:any){return NextResponse.json({error:error?.code==="ER_DUP_ENTRY"?"Feedback was already submitted.":"Feedback could not be saved."},{status:error?.code==="ER_DUP_ENTRY"?409:400});}
  await recordEvent({eventType:"REQUEST_FEEDBACK",requestId,actorId:user.id,rating});
  return NextResponse.redirect(new URL("/requests/"+requestId+"?feedback=1",req.url),303);
}
