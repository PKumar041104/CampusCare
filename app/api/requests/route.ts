import { NextResponse } from "next/server";
import { AuthError, requireApiUser } from "../../../lib/auth";
import { pool } from "../../../lib/db";
import { recordEvent } from "../../../lib/events";
import { sameOrigin } from "../../../lib/http";
import { cleanText, isOneOf, parsePositiveId, PRIORITIES } from "../../../lib/workflow";

export async function POST(req: Request) {
  if (!sameOrigin(req)) return NextResponse.json({ error: "Invalid request origin." }, { status: 403 });
  let user;
  try { user = await requireApiUser(["STUDENT", "FACULTY", "STAFF", "ADMIN"]); }
  catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : "Sign in required." }, { status: error instanceof AuthError ? error.status : 500 }); }
  const form = await req.formData();
  const title = cleanText(form.get("title"), 200);
  const description = cleanText(form.get("description"), 4000);
  const roomId = parsePositiveId(form.get("room_id"));
  const rawAsset = String(form.get("asset_id") || "");
  const assetId = rawAsset ? parsePositiveId(form.get("asset_id")) : null;
  const categoryId = parsePositiveId(form.get("category_id"));
  const priority = String(form.get("priority") || "");
  const severity = String(form.get("severity") || "");
  if (title.length < 5 || description.length < 15 || !roomId || !categoryId ||
      (rawAsset && !assetId) || !isOneOf(priority, PRIORITIES) || !isOneOf(severity, PRIORITIES)) {
    return NextResponse.redirect(new URL("/requests/new?error=validation", req.url), 303);
  }

  const connection = await pool.getConnection();
  let requestId = 0;
  try {
    await connection.beginTransaction();
    const [rooms]: any = await connection.query("SELECT room_id FROM room WHERE room_id=? AND status='ACTIVE' FOR UPDATE", [roomId]);
    if (!rooms.length) throw new Error("Choose an active campus room.");
    const [categories]: any = await connection.query("SELECT maintenance_category_id FROM maintenance_category WHERE maintenance_category_id=?", [categoryId]);
    if (!categories.length) throw new Error("Choose a valid maintenance category.");
    if (assetId) {
      const [assets]: any = await connection.query("SELECT asset_id FROM asset WHERE asset_id=? AND room_id=? AND asset_status='ACTIVE'", [assetId,roomId]);
      if (!assets.length) throw new Error("The selected asset does not belong to this room.");
    }
    const [insert]: any = await connection.query(
      "INSERT INTO maintenance_request(reported_by,asset_id,room_id,maintenance_category_id,title,description,priority,severity,current_status) VALUES(?,?,?,?,?,?,?,?, 'PENDING_APPROVAL')",
      [user.id,assetId,roomId,categoryId,title,description,priority,severity],
    );
    requestId = Number(insert.insertId);
    await connection.query("INSERT INTO request_approval(request_id,reviewer_id,decision) VALUES(?,NULL,'PENDING')", [requestId]);
    const [policies]: any = await connection.query(
      "SELECT sla_id,response_time_minutes,resolution_time_minutes FROM sla_policy WHERE priority=? AND status='ACTIVE' ORDER BY (severity=?) DESC LIMIT 1",
      [priority,severity],
    );
    if (policies.length) await connection.query(
      "INSERT INTO sla_tracking(request_id,sla_id,response_deadline,resolution_deadline) VALUES(?,?,DATE_ADD(NOW(),INTERVAL ? MINUTE),DATE_ADD(NOW(),INTERVAL ? MINUTE))",
      [requestId,policies[0].sla_id,policies[0].response_time_minutes,policies[0].resolution_time_minutes],
    );
    await connection.query("INSERT INTO request_event(request_id,user_id,event_type,new_status,note) VALUES(?,?,'REQUEST_SUBMITTED','PENDING_APPROVAL',?)", [requestId,user.id,title]);
    await connection.query("INSERT INTO audit_log(user_id,entity_name,record_id,action,new_value) VALUES(?,'maintenance_request',?,'CREATE',?)", [user.id,String(requestId),title]);
    await connection.commit();
  } catch (error) {
    await connection.rollback();
    const url = new URL("/requests/new",req.url);
    url.searchParams.set("error","validation");
    return NextResponse.redirect(url,303);
  } finally { connection.release(); }

  await recordEvent({ eventType: "REQUEST_SUBMITTED", requestId, actorId: user.id, ticketCode: "CC-" + String(requestId).padStart(6,"0"), title });
  return NextResponse.redirect(new URL("/requests/" + requestId + "?created=1",req.url),303);
}

