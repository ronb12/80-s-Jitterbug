"use client";

import {
  collection,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  doc,
  query,
  orderBy,
  serverTimestamp,
} from "firebase/firestore";
import { db } from "./firebase";

const GALLERY_COLLECTION = "gallery";

export interface GalleryPhoto {
  id: string;
  url: string;
  caption: string;
  order: number;
  createdAt: string;
}

export async function listGalleryPhotos(): Promise<GalleryPhoto[]> {
  if (!db) return [];
  try {
    const q = query(
      collection(db, GALLERY_COLLECTION),
      orderBy("order", "asc")
    );
    const snap = await getDocs(q);
    return snap.docs.map((d) => {
      const data = d.data();
      return {
        id: d.id,
        url: data.url ?? "",
        caption: data.caption ?? "",
        order: typeof data.order === "number" ? data.order : 0,
        createdAt: data.createdAt?.toDate?.()?.toISOString?.() ?? data.createdAt ?? "",
      };
    });
  } catch {
    return [];
  }
}

/** Add a photo by URL (no Storage—works on free Spark plan). */
export async function addGalleryPhotoByUrl(
  imageUrl: string,
  caption: string,
  order: number
): Promise<GalleryPhoto> {
  if (!db) throw new Error("Firebase not configured");
  const url = imageUrl.trim();
  if (!url) throw new Error("Image URL is required");

  const docRef = await addDoc(collection(db, GALLERY_COLLECTION), {
    url,
    caption: caption.trim(),
    order,
    createdAt: serverTimestamp(),
  });

  return {
    id: docRef.id,
    url,
    caption: caption.trim(),
    order,
    createdAt: new Date().toISOString(),
  };
}

export async function updateGalleryPhoto(
  id: string,
  data: { caption?: string; order?: number; url?: string }
): Promise<void> {
  if (!db) throw new Error("Firebase not configured");
  const update: Record<string, unknown> = {};
  if (data.caption !== undefined) update.caption = data.caption.trim();
  if (data.order !== undefined) update.order = data.order;
  if (data.url !== undefined) update.url = data.url.trim();
  if (Object.keys(update).length === 0) return;
  await updateDoc(doc(db, GALLERY_COLLECTION, id), update);
}

export async function deleteGalleryPhoto(id: string): Promise<void> {
  if (!db) throw new Error("Firebase not configured");
  await deleteDoc(doc(db, GALLERY_COLLECTION, id));
}
