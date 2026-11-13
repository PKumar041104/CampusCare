import {NextResponse} from "next/server";
import {AuthError,requireApiUser} from "../../../../lib/auth";
import {pool} from "../../../../lib/db";
import {sameOrigin} from "../../../../lib/http";
import {parsePositiveId} from "../../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req))return NextResponse.json({error:"Invalid request origin."},{status:403});
  let admin;try{admin=await requireApiUser(["ADMIN"]);}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"Sign in required."},{status:e instanceof AuthError?e.status:500});}
  const f=await req.formData(),id=parsePositiveId(f.get("user_id")),status=String(f.get("status")||"");
  if(!id||!["ACTIVE","INACTIVE","SUSPENDED"].includes(status))return NextResponse.json({error:"Choose a valid account status."},{status:400});
  if(id===admin.id)return NextResponse.json({error:"You cannot deactivate your own account."},{status:409});
  const qt=String.fromCharCode(96)+"user"+String.fromCharCode(96),c=await pool.getConnection();
  try{
    await c.beginTransaction();
    const [rows]:any=await c.query("SELECT status FROM "+qt+" WHERE user_id=? FOR UPDATE",[id]);
    if(!rows.length)throw new Error("Account not found.");
    await c.query("UPDATE "+qt+" SET status=? WHERE user_id=?",[status,id]);
    await c.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,old_value,new_value) VALUES(?,'user',?,'STATUS_CHANGE',?,?)",[admin.id,String(id),rows[0].status,status]);
    await c.commit();
  }catch(e){await c.rollback();return NextResponse.json({error:e instanceof Error?e.message:"Account update failed."},{status:400});}
  finally{c.release();}
  return NextResponse.redirect(new URL("/users?updated=1",req.url),303);
}
