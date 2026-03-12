/**
 * Public contact info shown on Contact, Privacy, and Terms pages.
 * Set in .env.local (and in your build/deploy environment for production):
 *   NEXT_PUBLIC_CONTACT_EMAIL=your@email.com
 *   NEXT_PUBLIC_CONTACT_PHONE=(555) 123-4567
 */

export const contactEmail =
  process.env.NEXT_PUBLIC_CONTACT_EMAIL?.trim() || "sbowie207@gmail.com";

export const contactPhone =
  process.env.NEXT_PUBLIC_CONTACT_PHONE?.trim() || "646-673-1956";

/** Phone in tel: link format for href (e.g. +15551234567) */
const digits = contactPhone.replace(/\D/g, "");
export const contactPhoneTel =
  digits.length === 10 ? `+1${digits}` : digits.length === 11 && digits.startsWith("1") ? `+${digits}` : digits ? `+${digits}` : "+16466731956";
