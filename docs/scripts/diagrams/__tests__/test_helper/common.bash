#!/bin/bash
# =============================================================================
# common.bash - batsテスト用共通ヘルパー
# =============================================================================
#
# 概要:
#   全テストファイルで共通して使用するヘルパー関数と設定を提供する。
#   各テストファイルの先頭で load 'test_helper/common' として読み込む。
#
# 提供する機能:
#   - SCRIPT_DIR: テスト対象スクリプトのディレクトリパス
#   - bats-support/bats-assert のロード（インストールされている場合）
#   - テスト用ユーティリティ関数
# =============================================================================

# テスト対象スクリプトのディレクトリを設定
# __tests__/ の親ディレクトリ（scripts/）を指す
SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
export SCRIPT_DIR

# bats-support と bats-assert のロード
# node_modules にインストールされている場合のみ読み込む
_load_bats_libs() {
  local node_modules_dir
  node_modules_dir="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)/node_modules"

  if [ -f "$node_modules_dir/bats-support/load.bash" ]; then
    # shellcheck source=/dev/null
    source "$node_modules_dir/bats-support/load.bash"
  fi

  if [ -f "$node_modules_dir/bats-assert/load.bash" ]; then
    # shellcheck source=/dev/null
    source "$node_modules_dir/bats-assert/load.bash"
  fi
}
_load_bats_libs

# =============================================================================
# ユーティリティ関数
# =============================================================================

# 一時ディレクトリを作成してパスを返す
# 使用例: TEST_DIR=$(create_temp_dir)
create_temp_dir() {
  mktemp -d
}

# ファイルの存在を確認する
# 使用例: assert_file_exists "$path"
assert_file_exists() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "Expected file to exist: $file" >&2
    return 1
  fi
}

# ディレクトリの存在を確認する
# 使用例: assert_dir_exists "$path"
assert_dir_exists() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Expected directory to exist: $dir" >&2
    return 1
  fi
}

# ファイルが存在しないことを確認する
# 使用例: assert_file_not_exists "$path"
assert_file_not_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    echo "Expected file to NOT exist: $file" >&2
    return 1
  fi
}

# 文字列が含まれているかを確認する
# 使用例: assert_contains "$output" "expected text"
assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "Expected '$haystack' to contain '$needle'" >&2
    return 1
  fi
}

# 文字列が含まれていないことを確認する
# 使用例: assert_not_contains "$output" "unexpected text"
assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "Expected '$haystack' to NOT contain '$needle'" >&2
    return 1
  fi
}
