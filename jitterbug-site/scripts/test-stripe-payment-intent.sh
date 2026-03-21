#!/usr/bin/env bash
# Same request the iOS app sends for in-app Payment Sheet: POST /api/stripePaymentIntent
# Returns JSON with clientSecret (use in Stripe test tools or iOS app only).
#
# Usage:
#   export SITE_URL="https://jitterbug80s.web.app"
#   export BOOKING_ID="your_firestore_booking_document_id"
#   ./scripts/test-stripe-payment-intent.sh

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
URL="${BASE}/api/stripePaymentIntent"

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
  echo "The iOS app passes clientSecret to Stripe Payment Sheet. Webhook must include payment_intent.succeeded."
fi
