import { createHash } from "crypto";
import { asc, desc, eq } from "drizzle-orm";
import {
  getDb,
  bookings,
  siteSettings,
  packagesConfig,
  eventTypesConfig,
  galleryPhotos,
  adminFcmTokens,
  bookingPushTokens,
} from "@/lib/db";
import type { Booking, BookingStatus } from "@/lib/booking-types";

const SITE_ID = "site";
const CONFIG_ID = 1 as const;

const DEFAULT_EVENT_TYPES = ["Wedding", "Birthday", "Corporate Event", "Party", "Other"];

let ensured = false;

export async function ensureConfigRows(): Promise<void> {
  if (ensured) return;
  const db = getDb();
  try {
    await db.insert(siteSettings).values({ id: SITE_ID }).onConflictDoNothing();
  } catch {
    /* ignore */
  }
  try {
    await db.insert(packagesConfig).values({ id: CONFIG_ID, packages: [] }).onConflictDoNothing();
  } catch {
    /* ignore */
  }
  try {
    await db
      .insert(eventTypesConfig)
      .values({ id: CONFIG_ID, eventTypes: DEFAULT_EVENT_TYPES })
      .onConflictDoNothing();
  } catch {
    /* ignore */
  }
  ensured = true;
}

function rowToBooking(row: typeof bookings.$inferSelect): Booking {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    phone: row.phone,
    eventType: row.eventType,
    eventDate: row.eventDate,
    eventLocation: row.eventLocation,
    eventAddress: row.eventAddress ?? "",
    package: row.packageId,
    message: row.message ?? "",
    photoReleaseConsent: row.photoReleaseConsent ?? false,
    photoReleaseIncludesMinors: row.photoReleaseIncludesMinors ?? false,
    status: (row.status as BookingStatus) ?? "pending",
    bookingRef: row.bookingRef,
    createdAt: row.createdAt?.toISOString?.() ?? "",
    updatedAt: row.updatedAt?.toISOString?.() ?? "",
  };
}

export async function listBookingsNeon(): Promise<Booking[]> {
  await ensureConfigRows();
  const db = getDb();
  const rows = await db.select().from(bookings).orderBy(desc(bookings.createdAt));
  return rows.map(rowToBooking);
}

export async function insertBookingNeon(data: {
  bookingRef: string;
  name: string;
  email: string;
  phone: string;
  eventType: string;
  eventDate: string;
  eventLocation: string;
  eventAddress: string;
  packageId: string;
  message: string;
  photoReleaseConsent: boolean;
  photoReleaseIncludesMinors: boolean;
}): Promise<{ id: string; bookingRef: string }> {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db
    .insert(bookings)
    .values({
      bookingRef: data.bookingRef,
      name: data.name,
      email: data.email,
      phone: data.phone,
      eventType: data.eventType,
      eventDate: data.eventDate,
      eventLocation: data.eventLocation,
      eventAddress: data.eventAddress,
      packageId: data.packageId,
      message: data.message,
      status: "pending",
      photoReleaseConsent: data.photoReleaseConsent,
      photoReleaseIncludesMinors: data.photoReleaseIncludesMinors,
    })
    .returning({ id: bookings.id, bookingRef: bookings.bookingRef });
  if (!row) throw new Error("Insert failed");
  return { id: row.id, bookingRef: row.bookingRef };
}

export async function getBookingByIdNeon(id: string) {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db.select().from(bookings).where(eq(bookings.id, id)).limit(1);
  return row ?? null;
}

export async function updateBookingNeon(
  id: string,
  patch: Partial<{
    depositPaid: boolean;
    stripeCheckoutSessionId: string | null;
    stripePaymentIntentId: string | null;
    status: string;
    name: string;
    email: string;
    phone: string;
    eventType: string;
    eventDate: string;
    eventLocation: string;
    eventAddress: string;
    packageId: string;
    message: string;
  }>
): Promise<void> {
  const db = getDb();
  const d: Partial<typeof bookings.$inferInsert> = { updatedAt: new Date() };
  if (patch.depositPaid !== undefined) d.depositPaid = patch.depositPaid;
  if (patch.stripeCheckoutSessionId !== undefined)
    d.stripeCheckoutSessionId = patch.stripeCheckoutSessionId;
  if (patch.stripePaymentIntentId !== undefined)
    d.stripePaymentIntentId = patch.stripePaymentIntentId;
  if (patch.status !== undefined) d.status = patch.status;
  if (patch.name !== undefined) d.name = patch.name;
  if (patch.email !== undefined) d.email = patch.email;
  if (patch.phone !== undefined) d.phone = patch.phone;
  if (patch.eventType !== undefined) d.eventType = patch.eventType;
  if (patch.eventDate !== undefined) d.eventDate = patch.eventDate;
  if (patch.eventLocation !== undefined) d.eventLocation = patch.eventLocation;
  if (patch.eventAddress !== undefined) d.eventAddress = patch.eventAddress;
  if (patch.packageId !== undefined) d.packageId = patch.packageId;
  if (patch.message !== undefined) d.message = patch.message;
  await db.update(bookings).set(d).where(eq(bookings.id, id));
}

export async function deleteBookingNeon(id: string): Promise<void> {
  const db = getDb();
  await db.delete(bookings).where(eq(bookings.id, id));
}

export async function loadSiteStripeSettingsNeon(): Promise<{
  stripeCheckoutEnabled: boolean;
  stripeDepositCents: number;
  stripePublicBaseUrl: string;
}> {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db.select().from(siteSettings).where(eq(siteSettings.id, SITE_ID)).limit(1);
  const base = String(row?.stripePublicBaseUrl ?? "https://jitterbug80s.web.app").replace(/\/$/, "");
  return {
    stripeCheckoutEnabled: Boolean(row?.stripeCheckoutEnabled),
    stripeDepositCents: Math.max(50, Number(row?.stripeDepositCents) || 5000),
    stripePublicBaseUrl: base || "https://jitterbug80s.web.app",
  };
}

export function parseMoneyToCents(price: string): number | null {
  const m = String(price)
    .replace(/,/g, "")
    .match(/\$?\s*(\d+(?:\.\d{1,2})?)/);
  if (!m) return null;
  const n = parseFloat(m[1]);
  if (Number.isNaN(n)) return null;
  return Math.round(n * 100);
}

export async function packagePriceCentsNeon(packageId: string): Promise<number | null> {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db.select().from(packagesConfig).where(eq(packagesConfig.id, CONFIG_ID)).limit(1);
  const list = row?.packages;
  if (!Array.isArray(list)) return null;
  const pkg = list.find((p) => String(p?.id ?? "") === packageId);
  if (!pkg?.price) return null;
  return parseMoneyToCents(String(pkg.price));
}

export type SiteSettingsRow = {
  contactEmail: string;
  contactPhone: string;
  serviceArea: string;
  stripePublicBaseUrl: string;
  stripeCheckoutEnabled: boolean;
  stripeDepositCents: number;
  stripePublishableKeyTest: string;
  stripePublishableKeyLive: string;
  stripeMode: "test" | "live";
  ownerName?: string;
};

const siteDefaults: SiteSettingsRow = {
  contactEmail: "sbowie207@gmail.com",
  contactPhone: "646-673-1956",
  serviceArea: "Serving the greater area and surrounding communities.",
  stripePublicBaseUrl: "https://jitterbug80s.web.app",
  stripeCheckoutEnabled: false,
  stripeDepositCents: 5000,
  stripePublishableKeyTest: "",
  stripePublishableKeyLive: "",
  stripeMode: "test",
  ownerName: "",
};

export async function getSiteSettingsNeon(): Promise<SiteSettingsRow> {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db.select().from(siteSettings).where(eq(siteSettings.id, SITE_ID)).limit(1);
  if (!row) return siteDefaults;
  const mode = row.stripeMode === "live" ? "live" : "test";
  return {
    contactEmail: row.contactEmail ?? siteDefaults.contactEmail,
    contactPhone: row.contactPhone ?? siteDefaults.contactPhone,
    serviceArea: row.serviceArea ?? siteDefaults.serviceArea,
    stripePublicBaseUrl: String(row.stripePublicBaseUrl ?? siteDefaults.stripePublicBaseUrl).replace(
      /\/$/,
      ""
    ),
    stripeCheckoutEnabled: Boolean(row.stripeCheckoutEnabled),
    stripeDepositCents: Math.max(50, Number(row.stripeDepositCents) || siteDefaults.stripeDepositCents),
    stripePublishableKeyTest: String(row.stripePublishableKeyTest ?? "").trim(),
    stripePublishableKeyLive: String(row.stripePublishableKeyLive ?? "").trim(),
    stripeMode: mode,
    ownerName: String(row.ownerName ?? "").trim(),
  };
}

export async function upsertSiteSettingsNeon(partial: Partial<SiteSettingsRow>): Promise<void> {
  await ensureConfigRows();
  const current = await getSiteSettingsNeon();
  const next = { ...current, ...partial };
  const db = getDb();
  await db
    .insert(siteSettings)
    .values({
      id: SITE_ID,
      ownerName: next.ownerName || null,
      contactEmail: next.contactEmail,
      contactPhone: next.contactPhone,
      serviceArea: next.serviceArea,
      stripePublicBaseUrl: next.stripePublicBaseUrl.replace(/\/$/, ""),
      stripeCheckoutEnabled: next.stripeCheckoutEnabled,
      stripeDepositCents: Math.max(50, next.stripeDepositCents),
      stripePublishableKeyTest: next.stripePublishableKeyTest,
      stripePublishableKeyLive: next.stripePublishableKeyLive,
      stripeMode: next.stripeMode,
    })
    .onConflictDoUpdate({
      target: siteSettings.id,
      set: {
        ownerName: next.ownerName || null,
        contactEmail: next.contactEmail,
        contactPhone: next.contactPhone,
        serviceArea: next.serviceArea,
        stripePublicBaseUrl: next.stripePublicBaseUrl.replace(/\/$/, ""),
        stripeCheckoutEnabled: next.stripeCheckoutEnabled,
        stripeDepositCents: Math.max(50, next.stripeDepositCents),
        stripePublishableKeyTest: next.stripePublishableKeyTest,
        stripePublishableKeyLive: next.stripePublishableKeyLive,
        stripeMode: next.stripeMode,
      },
    });
}

export type PackagePrice = { id: string; name: string; price: string };

const defaultPackages: PackagePrice[] = [
  { id: "basic", name: "Basic", price: "" },
  { id: "standard", name: "Standard", price: "" },
  { id: "vip", name: "VIP", price: "" },
];

export async function getPackagesNeon(): Promise<PackagePrice[]> {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db.select().from(packagesConfig).where(eq(packagesConfig.id, CONFIG_ID)).limit(1);
  const list = row?.packages;
  if (!Array.isArray(list) || list.length === 0) return defaultPackages;
  return list
    .filter(
      (p): p is PackagePrice =>
        p != null && typeof p === "object" && typeof (p as PackagePrice).name === "string"
    )
    .map((p) => ({
      id: (p as PackagePrice).id || `pkg-${Math.random().toString(36).slice(2, 9)}`,
      name: String((p as PackagePrice).name).trim(),
      price: String((p as PackagePrice).price ?? "").trim(),
    }));
}

export async function setPackagesNeon(packages: PackagePrice[]): Promise<void> {
  await ensureConfigRows();
  const db = getDb();
  const list = packages.map((p) => ({
    id: p.id || `pkg-${Math.random().toString(36).slice(2, 9)}`,
    name: String(p.name).trim(),
    price: String(p.price).trim(),
  }));
  await db
    .insert(packagesConfig)
    .values({ id: CONFIG_ID, packages: list })
    .onConflictDoUpdate({
      target: packagesConfig.id,
      set: { packages: list },
    });
}

export async function getEventTypesNeon(): Promise<string[]> {
  await ensureConfigRows();
  const db = getDb();
  const [row] = await db.select().from(eventTypesConfig).where(eq(eventTypesConfig.id, CONFIG_ID)).limit(1);
  const list = row?.eventTypes;
  if (!Array.isArray(list) || list.length === 0) return DEFAULT_EVENT_TYPES;
  return list.filter((t): t is string => typeof t === "string" && t.trim() !== "").map((t) => t.trim());
}

export async function setEventTypesNeon(eventTypes: string[]): Promise<void> {
  await ensureConfigRows();
  const db = getDb();
  const list = eventTypes.map((t) => t.trim()).filter(Boolean);
  await db
    .insert(eventTypesConfig)
    .values({ id: CONFIG_ID, eventTypes: list })
    .onConflictDoUpdate({
      target: eventTypesConfig.id,
      set: { eventTypes: list },
    });
}

export type GalleryPhotoRow = {
  id: string;
  url: string;
  caption: string;
  order: number;
  createdAt: string;
};

export async function listGalleryPhotosNeon(): Promise<GalleryPhotoRow[]> {
  await ensureConfigRows();
  const db = getDb();
  const rows = await db.select().from(galleryPhotos).orderBy(asc(galleryPhotos.sortOrder));
  return rows.map((r) => ({
    id: r.id,
    url: r.url,
    caption: r.caption ?? "",
    order: r.sortOrder,
    createdAt: r.createdAt.toISOString(),
  }));
}

export async function addGalleryPhotoNeon(
  url: string,
  caption: string,
  order: number
): Promise<GalleryPhotoRow> {
  const db = getDb();
  const [row] = await db
    .insert(galleryPhotos)
    .values({ url: url.trim(), caption: caption.trim(), sortOrder: order })
    .returning();
  if (!row) throw new Error("Insert failed");
  return {
    id: row.id,
    url: row.url,
    caption: row.caption ?? "",
    order: row.sortOrder,
    createdAt: row.createdAt.toISOString(),
  };
}

export async function updateGalleryPhotoNeon(
  id: string,
  data: { caption?: string; order?: number; url?: string }
): Promise<void> {
  const db = getDb();
  const patch: Partial<typeof galleryPhotos.$inferInsert> = {};
  if (data.caption !== undefined) patch.caption = data.caption.trim();
  if (data.order !== undefined) patch.sortOrder = data.order;
  if (data.url !== undefined) patch.url = data.url.trim();
  if (Object.keys(patch).length === 0) return;
  await db.update(galleryPhotos).set(patch).where(eq(galleryPhotos.id, id));
}

export async function deleteGalleryPhotoNeon(id: string): Promise<void> {
  const db = getDb();
  await db.delete(galleryPhotos).where(eq(galleryPhotos.id, id));
}

export async function getAdminFcmTokensNeon(): Promise<string[]> {
  await ensureConfigRows();
  const db = getDb();
  const rows = await db.select().from(adminFcmTokens);
  const tokens = new Set<string>();
  for (const r of rows) {
    if (typeof r.fcmToken === "string" && r.fcmToken.length > 20) tokens.add(r.fcmToken);
  }
  return [...tokens];
}

export async function getCustomerTokensForBookingNeon(bookingId: string): Promise<string[]> {
  const db = getDb();
  const rows = await db.select().from(bookingPushTokens).where(eq(bookingPushTokens.bookingId, bookingId));
  const tokens = new Set<string>();
  for (const r of rows) {
    if (typeof r.token === "string" && r.token.length > 20) tokens.add(r.token);
  }
  return [...tokens];
}

export async function registerCustomerPushTokenNeon(
  bookingId: string,
  bookingRef: string,
  fcmToken: string
): Promise<void> {
  const row = await getBookingByIdNeon(bookingId);
  if (!row) {
    const err = new Error("Booking not found");
    (err as Error & { statusCode?: number }).statusCode = 404;
    throw err;
  }
  if (String(row.bookingRef).trim() !== bookingRef.trim()) {
    const err = new Error("Invalid booking reference");
    (err as Error & { statusCode?: number }).statusCode = 403;
    throw err;
  }
  const id = createHash("sha256").update(fcmToken).digest("hex").slice(0, 28);
  const db = getDb();
  await db
    .insert(bookingPushTokens)
    .values({ id, bookingId: row.id, token: fcmToken })
    .onConflictDoUpdate({
      target: bookingPushTokens.id,
      set: { token: fcmToken, bookingId: row.id },
    });
}
