import { config as loadDotenv } from "dotenv";
import { defineConfig } from "drizzle-kit";
import { resolve } from "node:path";

// So `npm run db:push` picks up DATABASE_URL from .env.local (same as Next).
loadDotenv({ path: resolve(process.cwd(), ".env.local") });

export default defineConfig({
  schema: "./src/lib/db/schema.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
