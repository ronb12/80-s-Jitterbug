-- Run in Neon SQL Editor if you prefer raw SQL instead of `npm run db:push`
-- Table matches src/lib/db/schema.ts `users`

CREATE TABLE IF NOT EXISTS "users" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "email" text NOT NULL,
  "firebase_uid" text,
  "display_name" text,
  "role" text DEFAULT 'admin' NOT NULL,
  "metadata" jsonb,
  "created_at" timestamptz DEFAULT now() NOT NULL,
  "updated_at" timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT "users_email_unique" UNIQUE ("email"),
  CONSTRAINT "users_firebase_uid_unique" UNIQUE ("firebase_uid")
);
