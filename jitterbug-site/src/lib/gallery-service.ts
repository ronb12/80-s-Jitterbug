"use client";

import { publicApiOrigin } from "./api-public";
import { getAdminApiHeaders } from "./admin-auth";

export interface GalleryPhoto {
  id: string;
  url: string;
  caption: string;
  order: number;
  createdAt: string;
}

export async function listGalleryPhotos(): Promise<GalleryPhoto[]> {
  const origin = publicApiOrigin();
  if (!origin) return [];
  try {
    const r = await fetch(`${origin}/api/data/gallery`);
    if (!r.ok) return [];
    const data = (await r.json()) as { photos?: GalleryPhoto[] };
    return data.photos ?? [];
  } catch {
    return [];
  }
}

export async function addGalleryPhotoByUrl(
  imageUrl: string,
  caption: string,
  order: number
): Promise<GalleryPhoto> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");
  const url = imageUrl.trim();
  if (!url) throw new Error("Image URL is required");

  const r = await fetch(`${origin}/api/data/gallery`, {
    method: "POST",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify({ url, caption: caption.trim(), order }),
  });
  if (!r.ok) throw new Error("Could not add photo");
  const data = (await r.json()) as { photo?: GalleryPhoto };
  if (!data.photo) throw new Error("Invalid response");
  return data.photo;
}

export async function updateGalleryPhoto(
  id: string,
  data: { caption?: string; order?: number; url?: string }
): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/gallery/${encodeURIComponent(id)}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify(data),
  });
  if (!r.ok) throw new Error("Could not update photo");
}

export async function deleteGalleryPhoto(id: string): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/gallery/${encodeURIComponent(id)}`, {
    method: "DELETE",
    headers: getAdminApiHeaders(),
  });
  if (!r.ok) throw new Error("Could not delete photo");
}
