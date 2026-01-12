#!/usr/bin/env bash
# =============================================================================
# build-all.sh - 全形式のOpenAPIドキュメントを一括生成
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== OpenAPI Documentation Build ==="
echo ""

bash "$SCRIPT_DIR/build-redoc.sh"
bash "$SCRIPT_DIR/build-swagger.sh"
bash "$SCRIPT_DIR/build-stoplight.sh"

echo ""
echo "=== Build Complete ==="
