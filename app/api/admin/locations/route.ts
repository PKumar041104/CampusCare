import {NextResponse} from "next/server";
import {AuthError,requireApiUser} from "../../../../lib/auth";
import {pool} from "../../../../lib/db";
import {sameOrigin} from "../../../../lib/http";
import {cleanText,parsePositiveId} from "../../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req))return NextResponse.json({error:"Invalid request origin."},{status:403});
  let admin;try{admin=await requireApiUser(["ADMIN"]);}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"Sign in required."},{status:e instanceof AuthError?e.status:500});}
  const f=await req.formData(),action=String(f.get("action")||"");
  try{
    if(action==="building"){
      const campus=parsePositiveId(f.get("campus_id")),name=cleanText(f.get("building_name"),120),code=cleanText(f.get("building_code"),30).toUpperCase(),type=cleanText(f.get("building_type"),50),floors=Number(f.get("no_of_floors"));
      if(!campus||name.length<2||!(/^[A-Z0-9-]+$/).test(code)||!type||!Number.isInteger(floors)||floors<1||floors>30)throw new Error("Complete building details with valid values.");
      const [r]:any=await pool.query("INSERT INTO building(campus_id,building_name,building_code,building_type,no_of_floors) VALUES(?,?,?,?,?)",[campus,name,code,type,floors]);
      await pool.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,new_value) VALUES(?,'building',?,'CREATE',?)",[admin.id,code,name]);
    }else if(action==="room"){
      const building=parsePositiveId(f.get("building_id")),number=cleanText(f.get("room_number"),30),floor=Number(f.get("floor")),type=cleanText(f.get("room_type"),50),capacity=Number(f.get("capacity")||0);
      const [bs]:any=await pool.query("SELECT no_of_floors FROM building WHERE building_id=? AND status='ACTIVE'",[building]);
      if(!building||!number||!Number.isInteger(floor)||floor<0||!type||(capacity&&(!Number.isInteger(capacity)||capacity<1))||!bs.length||floor>Number(bs[0].no_of_floors))throw new Error("Complete room details and choose a valid floor.");
      await pool.query("INSERT INTO room(building_id,room_number,floor,room_type,capacity) VALUES(?,?,?,?,?)",[building,number,floor,type,capacity||null]);
      await pool.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,new_value) VALUES(?,'room',?,'CREATE',?)",[admin.id,building+":"+number,type]);
    }else throw new Error("Choose a supported campus update.");
  }catch(e:any){return NextResponse.json({error:e?.code==="ER_DUP_ENTRY"?"That building or room code already exists.":e instanceof Error?e.message:"Campus update failed."},{status:e?.code==="ER_DUP_ENTRY"?409:400});}
  return NextResponse.redirect(new URL("/locations?created=1",req.url),303);
}
