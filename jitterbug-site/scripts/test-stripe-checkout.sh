#!/usr/bin/env bash
# Same request the iOS app and website send: POST /api/stripeCheckout
# Usage:
#   export SITE_URL="https://jitterbug80s.web.app"
#   export BOOKING_ID="your_firestore_booking_document_id"
#   ./scripts/test-stripe-checkout.sh
#
# Get BOOKING_ID: submit a booking (app or site), then Firebase Console → Firestore → bookings → copy document ID.

set -euo pipefail
cd "$(dirname "$0")/.."

SITE_URL="${SITE_URL:-https://jitterbug80s.web.app}"
BOOKING_ID="${BOOKING_ID:-}"

if [[ -z "$BOOKING_ID" ]]; then
  echo "Set BOOKING_ID to a real Firestore booking document id."
  echo "Example: BOOKING_ID=AbCdEf1234567890 $0"
  exit 1
fi

BASE="${SITE_URL%/}"
URL="${BASE}/api/stripeCheckout"

echo "POST $URL"
echo "Body: {\"bookingId\":\"$BOOKING_ID\"}"
echo ""

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "{\"bookingId\":\"$BOOKING_ID\"}")

CODE=$(echo "$RESP" | tail -n1)
BODY=$(echo "$RESP" | sed '$d')

echo "HTTP $CODE"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

if [[ "$CODE" == "200" ]]; then
  echo ""
  echo "Open the \"url\" value in a browser (or Safari on device) to complete Stripe test payment."
fi
