import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { getSiteSettingsNeon, upsertSiteSettingsNeon } from "@/lib/server/neon-queries";
import type { SiteSettingsRow } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

/** Public read (contact + Stripe publishable settings for client). */
export async function GET() {
  try {
    const s = await getSiteSettingsNeon();
    return NextResponse.json({
      ownerName: s.ownerName ?? "",
      contactEmail: s.contactEmail,
      contactPhone: s.contactPhone,
      serviceArea: s.serviceArea,
      stripePublicBaseUrl: s.stripePublicBaseUrl,
      stripeCheckoutEnabled: s.stripeCheckoutEnabled,
      stripeDepositCents: s.stripeDepositCents,
      stripePublishableKeyTest: s.stripePublishableKeyTest,
      stripePublishableKeyLive: s.stripePublishableKeyLive,
      stripeMode: s.stripeMode,
    });
  } catch (e) {
    console.error("GET site-settings", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}

/** Admin merge-update. */
export async function PUT(request: NextRequest) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  let body: Partial<SiteSettingsRow>;
  try {
    body = (await request.json()) as Partial<SiteSettingsRow>;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  try {
    await upsertSiteSettingsNeon(body);
    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("PUT site-settings", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
