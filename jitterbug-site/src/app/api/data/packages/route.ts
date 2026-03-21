import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { getPackagesNeon, setPackagesNeon, type PackagePrice } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

export async function GET() {
  try {
    const packages = await getPackagesNeon();
    return NextResponse.json({ packages });
  } catch (e) {
    console.error("GET packages", e);
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

  let body: { packages?: PackagePrice[] };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  if (!Array.isArray(body.packages)) {
    return NextResponse.json({ error: "packages array required" }, { status: 400 });
  }

  try {
    await setPackagesNeon(body.packages);
    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("PUT packages", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
