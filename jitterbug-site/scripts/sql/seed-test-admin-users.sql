-- Test admin rows for Neon `users` (no passwords stored here — use Firebase Auth for sign-in).
-- Run in Neon SQL Editor, or: psql "$DATABASE_URL" -f scripts/sql/seed-test-admin-users.sql

INSERT INTO "users" ("email", "role", "metadata", "created_at", "updated_at")
VALUES
  (
    'ronellbradley@hotmail.com',
    'admin',
    '{"seed":"test","label":"test admin"}'::jsonb,
    now(),
    now()
  ),
  (
    'sbowie207@gmail.com',
    'admin',
    '{"seed":"test","label":"test admin"}'::jsonb,
    now(),
    now()
  )
ON CONFLICT ("email") DO UPDATE SET
  "role" = EXCLUDED."role",
  "metadata" = EXCLUDED."metadata",
  "updated_at" = now();
