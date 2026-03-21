import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { listBookingsNeon } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

export async function GET(request: NextRequest) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  try {
    const bookings = await listBookingsNeon();
    return NextResponse.json({ bookings });
  } catch (e) {
    console.error("GET bookings", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
