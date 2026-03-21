"use client";

import type { Booking } from "./booking-types";
import { BOOKING_CONTRACT_TERMS } from "./booking-contract-terms";
import { contactEmail, contactPhone } from "./contact";

function escapeHtml(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

export function openBookingContractPrint(booking: Booking): void {
  const b = booking;
  const termsHtml = BOOKING_CONTRACT_TERMS.map(
    (t) => `<div class="section"><h2>${escapeHtml(t.title)}</h2><p>${escapeHtml(t.body)}</p></div>`
  ).join("\n  ");

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Booking ${escapeHtml(b.bookingRef)} – 80's Jitterbug</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 700px; margin: 24px auto; padding: 20px; color: #111; font-size: 14px; }
    h1 { font-size: 1.5rem; color: #ec4899; margin-bottom: 4px; }
    .sub { font-size: 12px; color: #666; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; margin: 16px 0; }
    th, td { text-align: left; padding: 8px 12px; border-bottom: 1px solid #e5e5e5; }
    th { font-weight: 600; color: #444; width: 140px; }
    .section { margin-top: 24px; }
    .section h2 { font-size: 1rem; margin-bottom: 8px; color: #333; }
    .section p { line-height: 1.5; margin: 0; }
    .signature { margin-top: 32px; padding-top: 16px; border-top: 1px solid #ccc; }
    .signature-line { margin-top: 24px; }
    .signature-line span { display: inline-block; width: 200px; border-bottom: 1px solid #111; margin-right: 16px; }
    .contact-box { margin-top: 24px; padding: 12px; background: #f5f5f5; border-radius: 8px; font-size: 13px; }
    @media print { body { margin: 16px; } }
  </style>
</head>
<body>
  <h1>80's Jitterbug Photo Booth</h1>
  <p class="sub">Booking confirmation / contract</p>

  <table>
    <tr><th>Booking reference</th><td>${escapeHtml(b.bookingRef)}</td></tr>
    <tr><th>Status</th><td>${b.status}</td></tr>
    <tr><th>Requested</th><td>${b.createdAt ? new Date(b.createdAt).toLocaleDateString("en-US", { dateStyle: "medium" }) : "—"}</td></tr>
  </table>

  <div class="section">
    <h2>Client</h2>
    <table>
      <tr><th>Name</th><td>${escapeHtml(b.name)}</td></tr>
      <tr><th>Email</th><td>${escapeHtml(b.email)}</td></tr>
      <tr><th>Phone</th><td>${escapeHtml(b.phone)}</td></tr>
    </table>
  </div>

  <div class="section">
    <h2>Event</h2>
    <table>
      <tr><th>Type</th><td>${escapeHtml(b.eventType)}</td></tr>
      <tr><th>Date</th><td>${escapeHtml(b.eventDate)}</td></tr>
      <tr><th>Location</th><td>${escapeHtml(b.eventLocation)}</td></tr>
      <tr><th>Full address</th><td>${escapeHtml(b.eventAddress ?? "—")}</td></tr>
      <tr><th>Package</th><td>${escapeHtml(b.package)}</td></tr>
    </table>
  </div>

  ${b.message ? `<div class="section"><h2>Message</h2><p>${escapeHtml(b.message)}</p></div>` : ""}

  <div class="section">
    <h2>Photo release</h2>
    <table>
      <tr><th>Use photos for marketing</th><td>${b.photoReleaseConsent === true ? "Yes" : "No"}</td></tr>
      <tr><th>Includes minors permission</th><td>${b.photoReleaseIncludesMinors === true ? "Yes" : "No"}</td></tr>
    </table>
  </div>

  <h2 style="margin-top: 28px; font-size: 1rem; color: #333;">Booking Terms</h2>
  <p class="sub" style="margin-bottom: 12px;">By confirming this booking you agree to the following terms.</p>
  ${termsHtml}

  <div class="contact-box">
    <strong>Questions?</strong> Contact us: ${escapeHtml(contactEmail)} · ${escapeHtml(contactPhone)}
  </div>

  <div class="signature">
    <div class="signature-line">Client signature: <span></span> Date: <span></span></div>
  </div>
</body>
</html>`;

  openPrintWindow(html);
}

function openPrintWindow(html: string): void {
  const blob = new Blob([html], { type: "text/html;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const w = window.open(url, "_blank", "noopener,noreferrer");
  if (w) {
    w.focus();
    setTimeout(() => {
      URL.revokeObjectURL(url);
      try {
        w.print();
      } catch {
        // Print dialog may be blocked; document still visible
      }
    }, 600);
  } else {
    URL.revokeObjectURL(url);
  }
}

/** Opens a printable photo release form. Pass a booking to pre-fill, or null for a blank form to sign. */
export function openPhotoReleasePrint(booking: Booking | null): void {
  const clientName = booking ? escapeHtml(booking.name) : "";
  const eventDate = booking ? (booking.eventDate || "") : "";
  const marketingYesNo = booking ? (booking.photoReleaseConsent ? "Yes" : "No") : "__________";
  const minorsYesNo = booking ? (booking.photoReleaseIncludesMinors ? "Yes" : "No") : "__________";
  const refLine = booking ? `<tr><th>Booking ref</th><td>${escapeHtml(booking.bookingRef)}</td></tr>` : "";

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Photo Release Form – 80's Jitterbug</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 640px; margin: 24px auto; padding: 24px; color: #111; font-size: 14px; }
    h1 { font-size: 1.35rem; color: #ec4899; margin-bottom: 4px; }
    .sub { font-size: 12px; color: #666; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; margin: 12px 0; }
    th, td { text-align: left; padding: 6px 10px; border-bottom: 1px solid #e5e5e5; }
    th { font-weight: 600; color: #444; width: 120px; }
    .terms { margin: 20px 0; line-height: 1.5; }
    .terms p { margin: 10px 0; }
    .checkbox-line { margin: 14px 0; }
    .sig-line { margin-top: 28px; padding-top: 16px; border-top: 1px solid #ccc; }
    .sig-line span { display: inline-block; width: 200px; border-bottom: 1px solid #111; margin-right: 12px; }
    @media print { body { margin: 16px; } }
  </style>
</head>
<body>
  <h1>80's Jitterbug Photo Booth</h1>
  <p class="sub">Photo Release Form</p>

  <table>
    <tr><th>Client name</th><td>${clientName}</td></tr>
    <tr><th>Event date</th><td>${eventDate}</td></tr>
    ${refLine}
    <tr><th>Use photos for marketing</th><td>${marketingYesNo}</td></tr>
    <tr><th>Includes minors permission</th><td>${minorsYesNo}</td></tr>
  </table>

  <div class="terms">
    <p>I grant 80's Jitterbug Photo Booth permission to use selected photos and/or videos from my event on its website, social media, and marketing materials. I understand that these images may be used to showcase the company's work.</p>
    <p>I understand that 80's Jitterbug will not use images of minors (e.g. children) for marketing unless I have separately granted "minor permission" above or in my booking.</p>
    <p>I warrant that I have authority to agree to the use of likeness of attendees at my event (or have obtained consent where required). I may withdraw this permission later by contacting 80's Jitterbug.</p>
  </div>

  <div class="sig-line">
    <p>Signature: <span></span> &nbsp; Date: <span></span></p>
  </div>
</body>
</html>`;

  openPrintWindow(html);
}
