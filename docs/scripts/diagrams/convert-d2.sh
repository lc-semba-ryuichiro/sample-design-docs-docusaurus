#!/bin/bash
# =============================================================================
# convert-d2.sh - D2ファイルをSVG形式に変換するスクリプト
# =============================================================================
#
# 概要:
#   kroki CLIを使用してD2形式（.d2）のファイルをSVG画像に変換する。
#   ローカルのkrokiサーバー経由で変換を実行する。
#
# 使用方法:
#   cd docs && bash scripts/diagrams/convert-d2.sh
#
# 前提条件:
#   - krokiサーバーが起動していること（pnpm kroki:up）
#   - kroki CLIがインストールされていること（mise install）
#   - docs/ディレクトリから実行すること
#
# 入力:
#   static/diagrams/src/d2/*.d2
#
# 出力:
#   static/diagrams/output/d2/*.svg
#
# 環境変数:
#   KROKI_ENDPOINT: krokiサーバーのURL（mise.tomlで設定）
#
# 依存関係:
#   - kroki CLI（mise経由でインストール）
#   - ローカルkrokiサーバー（compose.yaml）
#
# 終了コード:
#   0: 成功（変換対象がない場合も含む）
#   非0: kroki変換エラー
#
# 注意:
#   このスクリプトは単体で全ファイルを変換する。
#   個別ファイルの変換にはconvert-single.shを使用すること。
#   サブディレクトリ内のファイルは検出されるが、出力はフラットになる。
# =============================================================================
set -euo pipefail

# 入出力ディレクトリの定義
SRC_DIR="static/diagrams/src/d2"
OUT_DIR="static/diagrams/output/d2"

# 出力ディレクトリを作成（存在しない場合）
mkdir -p "$OUT_DIR"

# 入力ディレクトリ内のすべての.d2ファイルを検索して変換
# 2>/dev/null: ディレクトリが存在しない場合のエラーを抑制
find "$SRC_DIR" -name "*.d2" 2>/dev/null | while read -r file; do
  # ファイル名から拡張子を除去してベース名を取得
  basename=$(basename "$file" .d2)
  output="$OUT_DIR/$basename.svg"

  echo "Converting: $file -> $output"

  # kroki CLIで変換を実行
  # -f svg: 出力形式をSVGに指定
  # -o: 出力ファイルパスを指定
  kroki convert "$file" -f svg -o "$output"
done
