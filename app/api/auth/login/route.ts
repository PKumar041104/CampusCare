import { NextResponse } from "next/server";
import { login } from "../../../../lib/auth";
import { sameOrigin } from "../../../../lib/http";

export async function POST(req: Request) {
  if (!sameOrigin(req)) return NextResponse.json({ error: "Invalid request origin." }, { status: 403 });
  try {
    const form = await req.formData();
    const user = await login(String(form.get("email") || ""), String(form.get("password") || ""));
    if (!user) return NextResponse.redirect(new URL("/login?error=invalid", req.url), 303);
    return NextResponse.redirect(new URL("/dashboard", req.url), 303);
  } catch {
    return NextResponse.redirect(new URL("/login?error=service", req.url), 303);
  }
}
