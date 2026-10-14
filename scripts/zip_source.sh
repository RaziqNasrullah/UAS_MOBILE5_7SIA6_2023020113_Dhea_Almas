#!/usr/bin/env bash
# Membuat ZIP source code NeoLearn tanpa folder build & cache.
# Pemakaian: bash scripts/zip_source.sh   -> NeoLearn_source_2023020113.zip
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="NeoLearn_source_2023020113.zip"
rm -f "$OUT"
zip -r -q "$OUT" . \
  -x "build/*" "*/build/*" \
  -x ".dart_tool/*" ".idea/*" "*.iml" \
  -x "android/.gradle/*" ".gradle/*" "android/local.properties" \
  -x "android/app/debug/*" "android/app/profile/*" "android/app/release/*" \
  -x ".git/*" "$OUT"
echo "Selesai: $OUT ($(du -h "$OUT" | cut -f1))"
