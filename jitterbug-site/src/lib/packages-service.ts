"use client";

import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "./firebase";

const SETTINGS_PACKAGES_ID = "packages";
const SETTINGS_COLLECTION = "settings";

export type PackagePrice = { id: string; name: string; price: string };

const DEFAULT_PACKAGES: PackagePrice[] = [
  { id: "basic", name: "Basic", price: "" },
  { id: "standard", name: "Standard", price: "" },
  { id: "vip", name: "VIP", price: "" },
];

export async function getPackages(): Promise<PackagePrice[]> {
  if (!db) return DEFAULT_PACKAGES;
  try {
    const ref = doc(db, SETTINGS_COLLECTION, SETTINGS_PACKAGES_ID);
    const snap = await getDoc(ref);
    if (!snap.exists()) return DEFAULT_PACKAGES;
    const data = snap.data();
    const list = data?.packages;
    if (!Array.isArray(list) || list.length === 0) return DEFAULT_PACKAGES;
    return list
      .filter((p): p is PackagePrice => p != null && typeof p === "object" && typeof (p as PackagePrice).name === "string" && typeof (p as PackagePrice).price === "string")
      .map((p) => ({
        id: (p as PackagePrice).id || `pkg-${Math.random().toString(36).slice(2, 9)}`,
        name: String((p as PackagePrice).name).trim(),
        price: String((p as PackagePrice).price).trim(),
      }));
  } catch {
    return DEFAULT_PACKAGES;
  }
}

export async function setPackages(packages: PackagePrice[]): Promise<void> {
  if (!db) throw new Error("Firebase not configured");
  const ref = doc(db, SETTINGS_COLLECTION, SETTINGS_PACKAGES_ID);
  const list = packages.map((p) => ({
    id: p.id || `pkg-${Math.random().toString(36).slice(2, 9)}`,
    name: String(p.name).trim(),
    price: String(p.price).trim(),
  }));
  await setDoc(ref, { packages: list });
}
