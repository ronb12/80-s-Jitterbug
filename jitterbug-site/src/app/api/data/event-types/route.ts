import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { getEventTypesNeon, setEventTypesNeon } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

export async function GET() {
  try {
    const eventTypes = await getEventTypesNeon();
    return NextResponse.json({ eventTypes });
  } catch (e) {
    console.error("GET event-types", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  let body: { eventTypes?: string[] };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  if (!Array.isArray(body.eventTypes)) {
    return NextResponse.json({ error: "eventTypes array required" }, { status: 400 });
  }

  try {
    await setEventTypesNeon(body.eventTypes);
    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("PUT event-types", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
