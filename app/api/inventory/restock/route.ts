import {NextResponse} from "next/server";
import {AuthError,requireApiUser} from "../../../../lib/auth";
import {pool} from "../../../../lib/db";
import {sameOrigin} from "../../../../lib/http";
import {cleanText,parsePositiveId} from "../../../../lib/workflow";

export async function POST(req:Request){
  if(!sameOrigin(req))return NextResponse.json({error:"Invalid request origin."},{status:403});
  let user;try{user=await requireApiUser(["ADMIN"]);}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"Sign in required."},{status:e instanceof AuthError?e.status:500});}
  const f=await req.formData(),itemId=parsePositiveId(f.get("item_id")),quantity=Number(f.get("quantity")),note=cleanText(f.get("note"),500);
  if(!itemId||!Number.isFinite(quantity)||quantity<=0||quantity>100000)return NextResponse.json({error:"Enter a valid stock quantity."},{status:400});
  const c=await pool.getConnection();
  try{
    await c.beginTransaction();
    const [rows]:any=await c.query("SELECT item_id FROM inventory_item WHERE item_id=? FOR UPDATE",[itemId]);
    if(!rows.length)throw new Error("Inventory item not found.");
    await c.query("UPDATE inventory_item SET quantity_available=quantity_available+?,status='AVAILABLE' WHERE item_id=?",[quantity,itemId]);
    await c.query("INSERT INTO inventory_movement(item_id,actor_id,movement_type,quantity,note) VALUES(?,?,'RESTOCK',?,?)",[itemId,user.id,quantity,note||"Administrator restock"]);
    await c.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,new_value) VALUES(?,'inventory_item',?,'RESTOCK',?)",[user.id,String(itemId),String(quantity)]);
    await c.commit();
  }catch(e){await c.rollback();return NextResponse.json({error:e instanceof Error?e.message:"Restock failed."},{status:400});}
  finally{c.release();}
  return NextResponse.redirect(new URL("/inventory?restocked=1",req.url),303);
}
