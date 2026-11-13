import { NextResponse } from "next/server";
import { logoutSession } from "../../../../lib/auth";
import { sameOrigin } from "../../../../lib/http";

export async function POST(req: Request) {
  if (!sameOrigin(req)) return NextResponse.json({ error: "Invalid request origin." }, { status: 403 });
  await logoutSession();
  return NextResponse.redirect(new URL("/login", req.url), 303);
}
