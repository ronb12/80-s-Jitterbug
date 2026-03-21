import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { deleteBookingNeon, updateBookingNeon } from "@/lib/server/neon-queries";
export const runtime = "nodejs";

type Ctx = { params: Promise<{ id: string }> };

export async function PATCH(request: NextRequest, ctx: Ctx) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  const { id } = await ctx.params;
  if (!id) {
    return NextResponse.json({ error: "Missing id" }, { status: 400 });
  }

  let body: Record<string, unknown>;
  try {
    body = (await request.json()) as Record<string, unknown>;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  try {
    const patch: Parameters<typeof updateBookingNeon>[1] = {};
    if (body.status !== undefined) patch.status = String(body.status);
    if (body.name !== undefined) patch.name = String(body.name).trim();
    if (body.email !== undefined) patch.email = String(body.email).trim();
    if (body.phone !== undefined) patch.phone = String(body.phone).trim();
    if (body.eventType !== undefined) patch.eventType = String(body.eventType);
    if (body.eventDate !== undefined) patch.eventDate = String(body.eventDate);
    if (body.eventLocation !== undefined)
      patch.eventLocation = String(body.eventLocation).trim();
    if (body.eventAddress !== undefined)
      patch.eventAddress = String(body.eventAddress).trim();
    if (body.package !== undefined) patch.packageId = String(body.package);
    if (body.message !== undefined) patch.message = String(body.message).trim();
    if (body.depositPaid !== undefined) patch.depositPaid = Boolean(body.depositPaid);

    await updateBookingNeon(id, patch);
    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("PATCH booking", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}

export async function DELETE(request: NextRequest, ctx: Ctx) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  const { id } = await ctx.params;
  if (!id) {
    return NextResponse.json({ error: "Missing id" }, { status: 400 });
  }

  try {
    await deleteBookingNeon(id);
    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("DELETE booking", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
