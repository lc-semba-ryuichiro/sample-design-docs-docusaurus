#!/usr/bin/env bash
# =============================================================================
# convert-all-kroki.sh - 全ダイアグラムファイルを一括変換するスクリプト
# =============================================================================
#
# 概要:
#   kroki CLIを使用して、サポートされている全フォーマットのダイアグラム
#   ファイルを一括でSVG形式に変換する。内部でconvert-single.shを呼び出す。
#
# 使用方法:
#   cd docs && pnpm diagrams:kroki
#   または: mise exec -- bash scripts/diagrams/convert-all-kroki.sh
#
# 前提条件:
#   - krokiサーバーが起動していること（pnpm kroki:up）
#   - kroki CLIがインストールされていること（mise install）
#   - docs/ディレクトリから実行するか、スクリプト内で自動移動
#
# 入力:
#   static/diagrams/src/<format>/*.<ext>
#   （存在するディレクトリのみ処理）
#
# 出力:
#   static/diagrams/output/<format>/*.svg
#   処理完了時に変換成功/失敗のサマリーを表示
#
# サポートフォーマット:
#   全27種類のkrokiサポートフォーマット（FORMATS変数参照）
#   各フォーマットは "フォーマット名:拡張子" の形式で定義
#
# 終了コード:
#   0: 常に0（失敗ファイルがあっても処理は継続）
#      失敗数はサマリーで確認可能
#
# 注意:
#   - 変換エラーが発生しても処理は中断されず、次のファイルに進む
#   - 失敗したファイルは "[FAILED]" プレフィックスで表示される
# =============================================================================
set -euo pipefail

# スクリプトのディレクトリを基準に docs/ ディレクトリに移動
# これにより、どのディレクトリから実行しても正しく動作する
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR/.."

BASE_DIR="static/diagrams/src"

# 変換結果のカウンター
CONVERTED=0  # 成功数
FAILED=0     # 失敗数

echo "=== Kroki Diagram Conversion ==="
echo ""

# =============================================================================
# フォーマット定義
# =============================================================================
# 形式: "フォーマット名:ファイル拡張子"
# 各フォーマット名は kroki CLI の -t オプションに渡される値
# ディレクトリ名もフォーマット名と同じである必要がある
#
# 注意:
#   - 同じ拡張子を複数フォーマットで使用するケースあり
#     (.diag: actdiag/blockdiag/nwdiag等, .vg: vega/vega-lite, .puml: plantuml/c4plantuml)
#   - これらはディレクトリ名で区別される（convert-single.shで判定）
# =============================================================================
FORMATS="
plantuml:puml
graphviz:dot
d2:d2
mermaid:mmd
actdiag:diag
blockdiag:diag
nwdiag:diag
packetdiag:diag
rackdiag:diag
seqdiag:diag
ditaa:dt
excalidraw:excalidraw
nomnoml:nomnoml
pikchr:pikchr
vega:vg
vega-lite:vg
bpmn:bpmn
bytefield:bytefield
dbml:dbml
structurizr:dsl
svgbob:bob
symbolator:sv
tikz:tex
umlet:uxf
wavedrom:json
wireviz:yaml
c4plantuml:puml
erd:erd
"

# =============================================================================
# メイン処理: 全フォーマットをループして変換
# =============================================================================
for pair in $FORMATS; do
  # "format:ext" の形式を分解
  format="${pair%%:*}"  # コロンより前（フォーマット名）
  ext="${pair##*:}"     # コロンより後（拡張子）
  src_dir="$BASE_DIR/$format"

  # ソースディレクトリが存在しない場合はスキップ
  # 使用しないフォーマットのディレクトリは作成不要
  [ -d "$src_dir" ] || continue

  # ファイルを検索して変換
  # -print0 と read -d '' でファイル名のスペース対応
  while IFS= read -r -d '' file; do
    # convert-single.sh を呼び出して変換
    # 出力は抑制し、終了コードのみで成否を判定
    if bash "$SCRIPT_DIR/convert-single.sh" "$file" > /dev/null 2>&1; then
      ((CONVERTED++)) || true  # || true で算術展開が0でもエラーにならない
    else
      echo "  [FAILED] $file"
      ((FAILED++)) || true
    fi
  done < <(find "$src_dir" -name "*.$ext" -type f -print0 2>/dev/null)
done

echo ""
echo "=== Conversion Complete ==="
echo "Converted: $CONVERTED files"
echo "Failed: $FAILED files"
