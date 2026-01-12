#!/usr/bin/env bash
# =============================================================================
# convert-single.sh - 単一ダイアグラムファイルをSVG形式に変換するスクリプト
# =============================================================================
#
# 概要:
#   指定されたダイアグラムファイルをkroki CLIを使用してSVG形式に変換する。
#   ファイルパスから自動的にフォーマットを判定し、適切な変換を実行する。
#
# 使用方法:
#   bash scripts/diagrams/convert-single.sh <source-file>
#
# 例:
#   bash scripts/diagrams/convert-single.sh static/diagrams/src/mermaid/flowchart.mmd
#   bash scripts/diagrams/convert-single.sh static/diagrams/src/plantuml/class.puml
#
# 引数:
#   <source-file>: 変換対象のダイアグラムファイルパス
#                  パスには "src/<format>/" が含まれている必要がある
#
# 出力:
#   成功時: 出力ファイルのパスを標準出力に出力
#   失敗時: エラーメッセージを標準エラー出力に出力
#
# フォーマット判定:
#   ファイルパスの "src/<format>/" 部分からフォーマットを判定する。
#   拡張子のみでは一意に判定できないケース（.diag, .vg等）があるため、
#   ディレクトリ名をフォーマット名として使用する。
#
# サポートフォーマット:
#   plantuml, graphviz, d2, mermaid, actdiag, blockdiag, nwdiag,
#   packetdiag, rackdiag, seqdiag, ditaa, excalidraw, nomnoml,
#   pikchr, vega, vega-lite, bpmn, bytefield, dbml, structurizr,
#   svgbob, symbolator, tikz, umlet, wavedrom, wireviz, c4plantuml, erd
#
# 環境変数:
#   KROKI_ENDPOINT: krokiサーバーのURL（mise.tomlで設定）
#
# 依存関係:
#   - kroki CLI（mise経由でインストール）
#   - ローカルkrokiサーバー（compose.yaml）
#
# 終了コード:
#   0: 変換成功
#   1: 引数不足、ファイル不在、フォーマット判定失敗、または変換エラー
#
# lefthookとの連携:
#   pre-commitフックからステージされたファイルごとに呼び出される。
#   出力パスを標準出力に返すことで、lefthookが出力ファイルを
#   自動的にステージに追加できるようにしている。
# =============================================================================
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <source-file>" >&2
  exit 1
fi

SOURCE_FILE="$1"

# ファイル存在チェック
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: File not found: $SOURCE_FILE" >&2
  exit 1
fi

# =============================================================================
# 関数定義
# =============================================================================

# declare_format_ext - 拡張子からフォーマット名を推定する
#
# 引数:
#   $1: ファイル拡張子（例: puml, dot, d2）
#
# 戻り値:
#   フォーマット名を標準出力に出力
#   マッピングが存在しない場合は空文字を出力
#
# 注意:
#   .diag や .vg など、複数フォーマットで共用される拡張子は空文字を返す。
#   その場合は extract_format_from_path() でディレクトリ名から判定する。
declare_format_ext() {
  case "$1" in
    puml) echo "plantuml" ;;
    dot) echo "graphviz" ;;
    d2) echo "d2" ;;
    mmd) echo "mermaid" ;;
    diag) echo "" ;;  # actdiag/blockdiag/nwdiag等はディレクトリ名から判定
    dt) echo "ditaa" ;;
    excalidraw) echo "excalidraw" ;;
    nomnoml) echo "nomnoml" ;;
    pikchr) echo "pikchr" ;;
    vg) echo "" ;;  # vega/vega-lite はディレクトリ名から判定
    bpmn) echo "bpmn" ;;
    bytefield) echo "bytefield" ;;
    dbml) echo "dbml" ;;
    dsl) echo "structurizr" ;;
    bob) echo "svgbob" ;;
    sv) echo "symbolator" ;;
    tex) echo "tikz" ;;
    uxf) echo "umlet" ;;
    json) echo "wavedrom" ;;
    yaml) echo "wireviz" ;;
    erd) echo "erd" ;;
    *) echo "" ;;
  esac
}

# extract_format_from_path - パスからフォーマット名を抽出する
#
# ファイルパスに含まれる "src/<format>/" パターンからフォーマット名を判定する。
# この方法により、拡張子が曖昧なフォーマット（actdiag/blockdiag等）も
# 正しく判定できる。
#
# 引数:
#   $1: ファイルパス（例: static/diagrams/src/mermaid/flowchart.mmd）
#
# 戻り値:
#   フォーマット名を標準出力に出力（例: mermaid）
#   パターンにマッチしない場合は空文字を出力
#
# 例:
#   extract_format_from_path "src/plantuml/class.puml" → "plantuml"
#   extract_format_from_path "docs/static/diagrams/src/d2/arch.d2" → "d2"
extract_format_from_path() {
  local path="$1"
  # src/<format>/ のパターンを抽出
  if [[ "$path" =~ src/([^/]+)/ ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

# calculate_output_path - 入力パスから出力パスを計算する
#
# 入力ファイルパスを基に、出力ファイルパスを生成する。
# 変換ルール:
#   1. パス内の "/src/" を "/output/" に置換
#   2. ファイル拡張子を ".svg" に変更
#
# 引数:
#   $1: 入力ファイルパス（例: static/diagrams/src/mermaid/flowchart.mmd）
#
# 戻り値:
#   出力ファイルパスを標準出力に出力
#
# 例:
#   入力: static/diagrams/src/mermaid/_templates/flowchart.mmd
#   出力: static/diagrams/output/mermaid/_templates/flowchart.svg
calculate_output_path() {
  local src_path="$1"

  # src/ を output/ に置換
  local out_path
  out_path=$(echo "$src_path" | sed 's|/src/|/output/|')

  # 拡張子を .svg に置換
  local ext="${src_path##*.}"
  out_path="${out_path%.$ext}.svg"

  echo "$out_path"
}

# =============================================================================
# メイン処理
# =============================================================================

# パスからフォーマットを判定
FORMAT=$(extract_format_from_path "$SOURCE_FILE")

if [ -z "$FORMAT" ]; then
  echo "Error: Cannot determine format from path: $SOURCE_FILE" >&2
  exit 1
fi

OUTPUT_FILE=$(calculate_output_path "$SOURCE_FILE" "$FORMAT")
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")

# 出力ディレクトリを作成
mkdir -p "$OUTPUT_DIR"

# 変換実行
echo "Converting ($FORMAT): $SOURCE_FILE -> $OUTPUT_FILE"
if kroki convert "$SOURCE_FILE" -t "$FORMAT" -f svg -o "$OUTPUT_FILE"; then
  echo "$OUTPUT_FILE"
else
  echo "Error: Conversion failed" >&2
  exit 1
fi
