#!/usr/bin/env bash
# Release build with obfuscation. Run from the project root.
# Usage: ./scripts/build_release.sh [apk|appbundle]
set -euo pipefail

TARGET="${1:-appbundle}"
SYMBOLS_DIR="build/symbols"

mkdir -p "$SYMBOLS_DIR"

echo "Building $TARGET with obfuscation..."

flutter build "$TARGET" \
  --release \
  --obfuscate \
  --split-debug-info="$SYMBOLS_DIR"

echo ""
echo "Build complete."
echo "Debug symbols written to: $SYMBOLS_DIR"
echo ""
echo "IMPORTANT: Upload the symbols directory to Firebase Crashlytics:"
echo "  firebase crashlytics:symbols:upload --app=<APP_ID> $SYMBOLS_DIR"
