#!/usr/bin/env bash
# =============================================================================
# build-redoc.sh - Redoc形式でOpenAPIドキュメントを生成
# =============================================================================
# 出力: docs/static/api/openapi/redoc/<spec-name>.html
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
SPECS_DIR="$PACKAGE_DIR/specs"
OUTPUT_DIR="$PACKAGE_DIR/../../docs/static/api/openapi/redoc"

mkdir -p "$OUTPUT_DIR"

echo "[Redoc] Building documentation..."

for spec_file in "$SPECS_DIR"/*.yaml "$SPECS_DIR"/*.yml; do
  [ -f "$spec_file" ] || continue

  basename=$(basename "$spec_file")
  name="${basename%.*}"
  output_file="$OUTPUT_DIR/${name}.html"

  echo "  $basename -> ${name}.html"
  npx @redocly/cli build-docs "$spec_file" --output "$output_file"
done

echo "[Redoc] Done."
