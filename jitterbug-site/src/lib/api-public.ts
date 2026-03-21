/** Browser origin for same-origin `/api/*` calls. */
export function publicApiOrigin(): string {
  if (typeof window === "undefined") return "";
  return window.location.origin;
}
