import { NextResponse } from "next/server";

const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, x-internal-notify-secret",
};

export function jsonWithCors(body: unknown, init?: ResponseInit): NextResponse {
  const headers = new Headers(init?.headers);
  for (const [k, v] of Object.entries(CORS_HEADERS)) {
    if (!headers.has(k)) headers.set(k, v);
  }
  return NextResponse.json(body, { ...init, headers });
}

export function emptyCors204(): NextResponse {
  return new NextResponse(null, { status: 204, headers: CORS_HEADERS });
}
