#!/bin/bash
# Run from jitterbug-site: ./deploy.sh
# NOTE: Default Next config no longer uses output: "export", so there may be no `out/` folder for Firebase Hosting.
# Prefer Vercel for full Stripe + API routes — see VERCEL.md.
set -e
cd "$(dirname "$0")"
echo "Building Next.js..."
npm run build
echo "Deploying to Firebase Hosting + Functions..."
firebase deploy --only hosting,functions
echo "Deploy complete."
