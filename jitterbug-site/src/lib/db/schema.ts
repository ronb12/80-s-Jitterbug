import {
  boolean,
  integer,
  jsonb,
  pgTable,
  text,
  timestamp,
  uuid,
} from "drizzle-orm/pg-core";

/** Single row id = 'site' */
export const siteSettings = pgTable("site_settings", {
  id: text("id").primaryKey(),
  ownerName: text("owner_name"),
  contactEmail: text("contact_email"),
  contactPhone: text("contact_phone"),
  serviceArea: text("service_area"),
  stripePublicBaseUrl: text("stripe_public_base_url"),
  stripeCheckoutEnabled: boolean("stripe_checkout_enabled").default(false),
  stripeDepositCents: integer("stripe_deposit_cents").default(5000),
  stripePublishableKeyTest: text("stripe_publishable_key_test"),
  stripePublishableKeyLive: text("stripe_publishable_key_live"),
  stripeMode: text("stripe_mode").default("test"),
});

/** Single row id = 1 */
export const packagesConfig = pgTable("packages_config", {
  id: integer("id").primaryKey(),
  packages: jsonb("packages").$type<Array<{ id: string; name: string; price: string }>>().notNull().default([]),
});

/** Single row id = 1 */
export const eventTypesConfig = pgTable("event_types_config", {
  id: integer("id").primaryKey(),
  eventTypes: jsonb("event_types").$type<string[]>().notNull().default([]),
});

export const bookings = pgTable("bookings", {
  id: uuid("id").defaultRandom().primaryKey(),
  bookingRef: text("booking_ref").notNull().unique(),
  name: text("name").notNull(),
  email: text("email").notNull(),
  phone: text("phone").notNull(),
  eventType: text("event_type").notNull(),
  eventDate: text("event_date").notNull(),
  eventLocation: text("event_location").notNull(),
  eventAddress: text("event_address").notNull().default(""),
  packageId: text("package_id").notNull(),
  message: text("message").notNull().default(""),
  status: text("status").notNull().default("pending"),
  photoReleaseConsent: boolean("photo_release_consent").default(false),
  photoReleaseIncludesMinors: boolean("photo_release_includes_minors").default(false),
  depositPaid: boolean("deposit_paid").default(false),
  balancePaid: boolean("balance_paid"),
  stripeCheckoutSessionId: text("stripe_checkout_session_id"),
  stripePaymentIntentId: text("stripe_payment_intent_id"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const galleryPhotos = pgTable("gallery_photos", {
  id: uuid("id").defaultRandom().primaryKey(),
  url: text("url").notNull(),
  caption: text("caption").notNull().default(""),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const adminFcmTokens = pgTable("admin_fcm_tokens", {
  adminUid: text("admin_uid").primaryKey(),
  fcmToken: text("fcm_token").notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const bookingPushTokens = pgTable("booking_push_tokens", {
  id: text("id").primaryKey(),
  bookingId: uuid("booking_id")
    .notNull()
    .references(() => bookings.id, { onDelete: "cascade" }),
  token: text("token").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});
