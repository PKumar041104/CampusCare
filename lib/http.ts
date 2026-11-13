import { NextResponse } from "next/server";

export function sameOrigin(req: Request): boolean {
  const origin = req.headers.get("origin");
  if (origin && origin !== new URL(req.url).origin) return false;
  return req.headers.get("sec-fetch-site") !== "cross-site";
}

export function redirectForm(req: Request, path: string, values: Record<string, string> = {}): NextResponse {
  const url = new URL(path, req.url);
  for (const [key, value] of Object.entries(values)) url.searchParams.set(key, value);
  return NextResponse.redirect(url, 303);
}

export function authErrorResponse(error: unknown): NextResponse {
  const status = typeof error === "object" && error !== null && "status" in error
    ? Number((error as { status: number }).status)
    : 500;
  const message = error instanceof Error ? error.message : "The request could not be completed.";
  return NextResponse.json({ error: message }, { status: status >= 400 && status < 600 ? status : 500 });
}

export function formError(req: Request, path: string, error: unknown): NextResponse {
  const status = typeof error === "object" && error !== null && "status" in error
    ? Number((error as { status: number }).status)
    : 400;
  const message = error instanceof Error ? error.message : "Please check the form and try again.";
  if (status === 401 || status === 403) return NextResponse.json({ error: message }, { status });
  const url = new URL(path, req.url);
  url.searchParams.set("error", status === 409 ? "conflict" : "validation");
  return NextResponse.redirect(url, 303);
}
