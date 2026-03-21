import { NextRequest, NextResponse } from "next/server";
import { assertAdminRequest } from "@/lib/server/admin-api-auth";
import { addGalleryPhotoNeon, listGalleryPhotosNeon } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

export async function GET() {
  try {
    const photos = await listGalleryPhotosNeon();
    return NextResponse.json({ photos });
  } catch (e) {
    console.error("GET gallery", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    assertAdminRequest(request);
  } catch (e) {
    const code = (e as Error & { statusCode?: number }).statusCode ?? 401;
    return NextResponse.json({ error: "Unauthorized" }, { status: code });
  }

  let body: { url?: string; caption?: string; order?: number };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const url = String(body?.url ?? "").trim();
  if (!url) {
    return NextResponse.json({ error: "url required" }, { status: 400 });
  }

  try {
    const photo = await addGalleryPhotoNeon(url, String(body?.caption ?? ""), Number(body?.order ?? 0));
    return NextResponse.json({ photo });
  } catch (e) {
    console.error("POST gallery", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
