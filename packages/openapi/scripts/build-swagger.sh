#!/usr/bin/env bash
# =============================================================================
# build-swagger.sh - Swagger UI形式でOpenAPIドキュメントを生成
# =============================================================================
# 出力: docs/static/api/openapi/swagger/<spec-name>.html
#
# CDN から Swagger UI を読み込む静的 HTML を生成
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(cd "$PACKAGE_DIR/../.." && pwd)"
SPECS_DIR="$PACKAGE_DIR/specs"
OUTPUT_DIR="$REPO_ROOT/docs/static/api/openapi/swagger"

mkdir -p "$OUTPUT_DIR"

echo "[Swagger UI] Building documentation..."

for spec_file in "$SPECS_DIR"/*.yaml "$SPECS_DIR"/*.yml; do
  [ -f "$spec_file" ] || continue

  basename=$(basename "$spec_file")
  name="${basename%.*}"
  output_file="$OUTPUT_DIR/${name}.html"

  echo "  $basename -> ${name}.html"

  spec_content=$(cat "$spec_file")

  cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${name} - Swagger UI</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
  <style>
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
    #swagger-ui {
      height: 100%;
    }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script src="https://unpkg.com/js-yaml@4/dist/js-yaml.min.js"></script>
  <script>
    const spec = \`${spec_content}\`;
    window.onload = () => {
      SwaggerUIBundle({
        spec: jsyaml.load(spec),
        dom_id: '#swagger-ui',
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIBundle.SwaggerUIStandalonePreset
        ],
        layout: 'StandaloneLayout'
      });
    };
  </script>
</body>
</html>
EOF
done

echo "[Swagger UI] Done."
