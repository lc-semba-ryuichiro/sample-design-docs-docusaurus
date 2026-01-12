#!/usr/bin/env bash
# =============================================================================
# build-stoplight.sh - Stoplight Elements形式でOpenAPIドキュメントを生成
# =============================================================================
# 出力: docs/static/api/openapi/stoplight/<spec-name>.html
#
# Stoplight ElementsはWeb Component形式のため、CDNから読み込む
# 静的HTMLを生成し、OpenAPI仕様ファイルを埋め込む
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
SPECS_DIR="$PACKAGE_DIR/specs"
OUTPUT_DIR="$PACKAGE_DIR/../../docs/static/api/openapi/stoplight"

mkdir -p "$OUTPUT_DIR"

echo "[Stoplight Elements] Building documentation..."

for spec_file in "$SPECS_DIR"/*.yaml "$SPECS_DIR"/*.yml; do
  [ -f "$spec_file" ] || continue

  basename=$(basename "$spec_file")
  name="${basename%.*}"
  output_file="$OUTPUT_DIR/${name}.html"

  echo "  $basename -> ${name}.html"

  # YAMLの内容を読み込み
  spec_content=$(cat "$spec_file")

  # HTMLテンプレートを生成
  cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${name} - API Documentation</title>
  <script src="https://unpkg.com/@stoplight/elements/web-components.min.js"></script>
  <link rel="stylesheet" href="https://unpkg.com/@stoplight/elements/styles.min.css">
  <style>
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
  </style>
</head>
<body>
  <elements-api
    id="docs"
    router="hash"
    layout="sidebar"
    tryItCredentialsPolicy="same-origin"
  ></elements-api>
  <script>
    const spec = \`${spec_content}\`;
    document.getElementById('docs').apiDescriptionDocument = spec;
  </script>
</body>
</html>
EOF
done

echo "[Stoplight Elements] Done."
