import { NextResponse } from "next/server";
import { AuthError, requireApiUser } from "../../../lib/auth";
import { pool } from "../../../lib/db";
import { recordEvent } from "../../../lib/events";
import { sameOrigin } from "../../../lib/http";
import { parsePositiveId } from "../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req)) return NextResponse.json({error:"Invalid request origin."},{status:403});
  let user;
  try{user=await requireApiUser(["ADMIN"]);}catch(error){return NextResponse.json({error:error instanceof Error?error.message:"Sign in required."},{status:error instanceof AuthError?error.status:500});}
  const form=await req.formData(),requestId=parsePositiveId(form.get("request_id")),technicianId=parsePositiveId(form.get("technician_id"));
  if(!requestId||!technicianId)return NextResponse.json({error:"Select an available technician."},{status:400});
  const connection=await pool.getConnection();
  try{
    await connection.query("SET @campuscare_actor_id=?",[user.id]);
    await connection.query("CALL AssignTechnician(?,?,?)",[requestId,technicianId,user.id]);
  }catch(error){return NextResponse.json({error:error instanceof Error?error.message:"Assignment could not be saved."},{status:409});}
  finally{connection.release();}
  await recordEvent({eventType:"TECHNICIAN_ASSIGNED",requestId,technicianId,actorId:user.id});
  return NextResponse.redirect(new URL("/requests/"+requestId+"?assigned=1",req.url),303);
}
