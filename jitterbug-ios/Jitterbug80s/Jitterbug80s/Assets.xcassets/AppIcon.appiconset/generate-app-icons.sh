#!/bin/bash
# Regenerate AppIcon-512.png (macOS 1×) from the 1024×1024 master. Run from this directory or pass DIR.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
MASTER="$DIR/AppIcon-1024.png"
OUT="$DIR/AppIcon-512.png"
if [[ ! -f "$MASTER" ]]; then
  echo "Missing $MASTER" >&2
  exit 1
fi
sips -z 512 512 "$MASTER" --out "$OUT" >/dev/null
echo "OK: wrote $OUT (512×512 from $MASTER)"
