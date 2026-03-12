"use client";

import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "./firebase";

const SETTINGS_EVENT_TYPES_ID = "eventTypes";
const SETTINGS_COLLECTION = "settings";

const DEFAULT_EVENT_TYPES = ["Wedding", "Birthday", "Corporate Event", "Party", "Other"];

export async function getEventTypes(): Promise<string[]> {
  if (!db) return DEFAULT_EVENT_TYPES;
  try {
    const ref = doc(db, SETTINGS_COLLECTION, SETTINGS_EVENT_TYPES_ID);
    const snap = await getDoc(ref);
    if (!snap.exists()) return DEFAULT_EVENT_TYPES;
    const data = snap.data();
    const list = data?.eventTypes;
    if (!Array.isArray(list) || list.length === 0) return DEFAULT_EVENT_TYPES;
    return list.filter((t): t is string => typeof t === "string" && t.trim() !== "").map((t) => t.trim());
  } catch {
    return DEFAULT_EVENT_TYPES;
  }
}

export async function setEventTypes(eventTypes: string[]): Promise<void> {
  if (!db) throw new Error("Firebase not configured");
  const ref = doc(db, SETTINGS_COLLECTION, SETTINGS_EVENT_TYPES_ID);
  await setDoc(ref, { eventTypes: eventTypes.map((t) => t.trim()).filter(Boolean) });
}

export { DEFAULT_EVENT_TYPES };
