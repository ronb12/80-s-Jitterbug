import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { getDb, adminFcmTokens } from "@/lib/db";
import { ensureConfigRows } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

/** Register / refresh an admin device FCM token (replaces Firestore `adminFCM/{uid}` for the website stack). */
export async function POST(request: NextRequest) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  let body: { adminUid?: string; fcmToken?: string };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const adminUid = String(body?.adminUid ?? "").trim();
  const fcmToken = String(body?.fcmToken ?? "").trim();
  if (!adminUid || fcmToken.length < 20) {
    return NextResponse.json({ error: "adminUid and fcmToken required" }, { status: 400 });
  }

  try {
    await ensureConfigRows();
    const db = getDb();
    await db
      .insert(adminFcmTokens)
      .values({ adminUid, fcmToken, updatedAt: new Date() })
      .onConflictDoUpdate({
        target: adminFcmTokens.adminUid,
        set: { fcmToken, updatedAt: new Date() },
      });
    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("POST admin-fcm", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
