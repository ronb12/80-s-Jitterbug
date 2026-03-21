"use client";

import { publicApiOrigin } from "./api-public";
import { getAdminApiHeaders } from "./admin-auth";

const DEFAULT_EVENT_TYPES = ["Wedding", "Birthday", "Corporate Event", "Party", "Other"];

export async function getEventTypes(): Promise<string[]> {
  const origin = publicApiOrigin();
  if (!origin) return DEFAULT_EVENT_TYPES;
  try {
    const r = await fetch(`${origin}/api/data/event-types`);
    if (!r.ok) return DEFAULT_EVENT_TYPES;
    const data = (await r.json()) as { eventTypes?: string[] };
    const list = data.eventTypes;
    if (!Array.isArray(list) || list.length === 0) return DEFAULT_EVENT_TYPES;
    return list.filter((t): t is string => typeof t === "string" && t.trim() !== "").map((t) => t.trim());
  } catch {
    return DEFAULT_EVENT_TYPES;
  }
}

export async function setEventTypes(eventTypes: string[]): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/event-types`, {
    method: "PUT",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify({ eventTypes: eventTypes.map((t) => t.trim()).filter(Boolean) }),
  });
  if (!r.ok) throw new Error("Could not save event types");
}

export { DEFAULT_EVENT_TYPES };
