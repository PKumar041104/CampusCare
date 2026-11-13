import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import bcrypt from "bcryptjs";
import { createHash, randomBytes } from "crypto";
import { pool } from "./db";

export type UserRole = "STUDENT" | "FACULTY" | "STAFF" | "ADMIN" | "TECHNICIAN";
export type AppUser = {
  id: number;
  role: UserRole;
  email: string;
  name: string;
  technicianId: number | null;
};

const SESSION_COOKIE = "campuscare_session";
const SESSION_HOURS = 8;
const digest = (value: string) => createHash("sha256").update(value).digest("hex");

export class AuthError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export async function login(email: string, password: string): Promise<AppUser | null> {
  const [rows]: any = await pool.query(
    "SELECT user_id, email, first_name, last_name, role, password_hash, status FROM `user` WHERE email = ? LIMIT 1",
    [email.trim().toLowerCase()],
  );
  const record = rows[0];
  if (!record || record.status !== "ACTIVE") return null;
  if (!(await bcrypt.compare(password, record.password_hash))) return null;

  const token = randomBytes(32).toString("hex");
  const expires = new Date(Date.now() + SESSION_HOURS * 60 * 60 * 1000);
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    await connection.query(
      "INSERT INTO user_session(token_hash, user_id, expires_at) VALUES(?, ?, ?)",
      [digest(token), record.user_id, expires],
    );
    await connection.query(
      "INSERT INTO audit_log(user_id, entity_name, record_id, action, new_value) VALUES(?, 'session', ?, 'LOGIN', ?)",
      [record.user_id, String(record.user_id), record.email],
    );
    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const cookieStore = await cookies();
  cookieStore.set(SESSION_COOKIE, token, {
    httpOnly: true,
    sameSite: "strict",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: SESSION_HOURS * 60 * 60,
  });
  return {
    id: Number(record.user_id),
    role: record.role,
    email: record.email,
    name: record.first_name + " " + record.last_name,
    technicianId: null,
  };
}

export async function getCurrentUser(): Promise<AppUser | null> {
  const cookieStore = await cookies();
  const token = cookieStore.get(SESSION_COOKIE)?.value;
  if (!token || !/^[a-f0-9]{64}$/.test(token)) return null;
  const [rows]: any = await pool.query(
    "SELECT u.user_id, u.email, u.first_name, u.last_name, u.role, t.technician_id " +
      "FROM user_session s JOIN `user` u ON u.user_id = s.user_id " +
      "LEFT JOIN technician t ON t.user_id = u.user_id " +
      "WHERE s.token_hash = ? AND s.revoked_at IS NULL AND s.expires_at > CURRENT_TIMESTAMP " +
      "AND u.status = 'ACTIVE' LIMIT 1",
    [digest(token)],
  );
  const record = rows[0];
  if (!record) return null;
  return {
    id: Number(record.user_id),
    role: record.role,
    email: record.email,
    name: record.first_name + " " + record.last_name,
    technicianId: record.technician_id === null ? null : Number(record.technician_id),
  };
}

export async function requireApiUser(roles?: UserRole[]): Promise<AppUser> {
  const user = await getCurrentUser();
  if (!user) throw new AuthError(401, "Please sign in to continue.");
  if (roles && !roles.includes(user.role)) {
    throw new AuthError(403, "Your account does not have permission for this action.");
  }
  return user;
}

export async function requirePageUser(roles?: UserRole[]): Promise<AppUser> {
  const user = await getCurrentUser();
  if (!user) redirect("/login");
  if (roles && !roles.includes(user.role)) redirect("/dashboard?error=forbidden");
  return user;
}

export async function logoutSession(): Promise<void> {
  const cookieStore = await cookies();
  const token = cookieStore.get(SESSION_COOKIE)?.value;
  if (token && /^[a-f0-9]{64}$/.test(token)) {
    await pool.query("UPDATE user_session SET revoked_at = CURRENT_TIMESTAMP WHERE token_hash = ? AND revoked_at IS NULL", [digest(token)]);
  }
  cookieStore.delete(SESSION_COOKIE);
}
