#!/bin/bash
# Run from jitterbug-site: ./deploy.sh
# Or: bash deploy.sh
set -e
cd "$(dirname "$0")"
echo "Building Next.js..."
npm run build
echo "Deploying to Firebase Hosting + Functions (Stripe checkout uses Functions)..."
firebase deploy --only hosting,functions
echo "Deploy complete."
