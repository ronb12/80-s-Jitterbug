"use client";

import { publicApiOrigin } from "./api-public";
import { getAdminApiHeaders } from "./admin-auth";

export type PackagePrice = { id: string; name: string; price: string };

const DEFAULT_PACKAGES: PackagePrice[] = [
  { id: "basic", name: "Basic", price: "" },
  { id: "standard", name: "Standard", price: "" },
  { id: "vip", name: "VIP", price: "" },
];

export async function getPackages(): Promise<PackagePrice[]> {
  const origin = publicApiOrigin();
  if (!origin) return DEFAULT_PACKAGES;
  try {
    const r = await fetch(`${origin}/api/data/packages`);
    if (!r.ok) return DEFAULT_PACKAGES;
    const data = (await r.json()) as { packages?: PackagePrice[] };
    const list = data.packages;
    if (!Array.isArray(list) || list.length === 0) return DEFAULT_PACKAGES;
    return list.map((p) => ({
      id: p.id || `pkg-${Math.random().toString(36).slice(2, 9)}`,
      name: String(p.name).trim(),
      price: String(p.price ?? "").trim(),
    }));
  } catch {
    return DEFAULT_PACKAGES;
  }
}

export async function setPackages(packages: PackagePrice[]): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const list = packages.map((p) => ({
    id: p.id || `pkg-${Math.random().toString(36).slice(2, 9)}`,
    name: String(p.name).trim(),
    price: String(p.price).trim(),
  }));

  const r = await fetch(`${origin}/api/data/packages`, {
    method: "PUT",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify({ packages: list }),
  });
  if (!r.ok) throw new Error("Could not save packages");
}
