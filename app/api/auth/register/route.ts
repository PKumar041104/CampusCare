import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { pool } from "../../../../lib/db";
import { sameOrigin } from "../../../../lib/http";

export async function POST(req: Request) {
  if (!sameOrigin(req)) return NextResponse.json({ error: "Invalid request origin." }, { status: 403 });
  const form = await req.formData();
  const first = String(form.get("firstName") || "").trim();
  const last = String(form.get("lastName") || "").trim();
  const email = String(form.get("email") || "").trim().toLowerCase();
  const password = String(form.get("password") || "");
  const role = String(form.get("role") || "STUDENT");
  const studentNumber = String(form.get("studentNumber") || "").trim();
  const employeeNumber = String(form.get("employeeNumber") || "").trim();
  const department = String(form.get("department") || "").trim();
  const semester = Number(form.get("semester") || 0);
  const campusIdPattern = /^[A-Za-z0-9/-]{4,40}$/;

  if (!first || first.length > 50 || !last || last.length > 50 ||
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 150 ||
      password.length < 10 || password.length > 100 ||
      !["STUDENT", "FACULTY"].includes(role)) {
    return NextResponse.redirect(new URL("/register?error=validation", req.url), 303);
  }
  if (role === "STUDENT" && (!campusIdPattern.test(studentNumber) || !Number.isInteger(semester) || semester < 1 || semester > 8)) {
    return NextResponse.redirect(new URL("/register?error=validation", req.url), 303);
  }
  if (role === "FACULTY" && (!campusIdPattern.test(employeeNumber) || !department || department.length > 120)) {
    return NextResponse.redirect(new URL("/register?error=validation", req.url), 303);
  }

  const userTable = String.fromCharCode(96) + "user" + String.fromCharCode(96);
  try {
    await pool.query(
      "INSERT INTO " + userTable + "(user_name,first_name,last_name,email,phone_number,role,password_hash,student_number,employee_number,department_name,semester) VALUES(?,?,?,?,?,?,?,?,?,?,?)",
      [email, first, last, email, String(form.get("phone") || "").trim().slice(0, 20) || null,
       role, await bcrypt.hash(password, 12),
       role === "STUDENT" ? studentNumber : null,
       role === "FACULTY" ? employeeNumber : null,
       role === "FACULTY" ? department : null,
       role === "STUDENT" ? semester : null],
    );
    return NextResponse.redirect(new URL("/login?registered=1", req.url), 303);
  } catch (error: any) {
    const code = error?.code === "ER_DUP_ENTRY" ? "duplicate" : "validation";
    return NextResponse.redirect(new URL("/register?error=" + code, req.url), 303);
  }
}
