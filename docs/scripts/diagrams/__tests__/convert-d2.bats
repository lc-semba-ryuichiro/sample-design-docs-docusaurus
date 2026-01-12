#!/usr/bin/env bats
# =============================================================================
# convert-d2.bats - Unit tests for convert-d2.sh
# =============================================================================

load 'test_helper/common'

FORMAT="d2"
EXT="d2"
SCRIPT_NAME="convert-d2.sh"

# =============================================================================
# Setup / Teardown
# =============================================================================

setup() {
  export TEST_DIR="$(mktemp -d)"
  export FIXTURES_DIR="$BATS_TEST_DIRNAME/fixtures"
  export PATH="$BATS_TEST_DIRNAME/test_helper/mocks:$PATH"

  mkdir -p "$TEST_DIR/static/diagrams/src/$FORMAT"
  mkdir -p "$TEST_DIR/scripts"
  cp "$SCRIPT_DIR/$SCRIPT_NAME" "$TEST_DIR/scripts/"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# =============================================================================
# Basic Operation Tests
# =============================================================================

@test "does nothing when no source files exist" {
  # Given: ソースファイルが存在しない状態
  cd "$TEST_DIR"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: 成功し、変換メッセージは出力されない
  [ "$status" -eq 0 ]
  [[ "$output" != *"Converting:"* ]]
}

@test "automatically creates output directory" {
  # Given: 出力ディレクトリが存在せず、ソースファイルがある
  cd "$TEST_DIR"
  [ ! -d "$TEST_DIR/static/diagrams/output/$FORMAT" ]
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/test.$EXT"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: 成功し、出力ディレクトリが自動作成される
  [ "$status" -eq 0 ]
  [ -d "$TEST_DIR/static/diagrams/output/$FORMAT" ]
}

# =============================================================================
# Single File Conversion Tests
# =============================================================================

@test "correctly converts single file" {
  # Given: d2 ソースファイルが1つ存在する
  cd "$TEST_DIR"
  cp "$FIXTURES_DIR/$FORMAT/sample.$EXT" "$TEST_DIR/static/diagrams/src/$FORMAT/"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: 成功し、変換メッセージにファイル名が含まれる
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converting:"* ]]
  [[ "$output" == *"sample.$EXT"* ]]
}

@test "generates correct output filename" {
  # Given: d2 ソースファイルが存在する
  cd "$TEST_DIR"
  cp "$FIXTURES_DIR/$FORMAT/sample.$EXT" "$TEST_DIR/static/diagrams/src/$FORMAT/"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: 成功し、出力ファイル名が .svg になる
  [ "$status" -eq 0 ]
  [[ "$output" == *"sample.svg"* ]]
}

# =============================================================================
# Multiple File Conversion Tests
# =============================================================================

@test "converts all multiple files" {
  # Given: 複数の d2 ソースファイルが存在する
  cd "$TEST_DIR"
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/test1.$EXT"
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/test2.$EXT"
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/test3.$EXT"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: 成功し、3ファイル全ての変換メッセージが出力される
  [ "$status" -eq 0 ]
  count=$(echo "$output" | grep -c "Converting:" || true)
  [ "$count" -eq 3 ]
}

# =============================================================================
# Kroki Invocation Tests
# =============================================================================

@test "calls kroki convert" {
  # Given: d2 ソースファイルが存在する
  cd "$TEST_DIR"
  cp "$FIXTURES_DIR/$FORMAT/sample.$EXT" "$TEST_DIR/static/diagrams/src/$FORMAT/"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: kroki convert コマンドが呼び出される
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.kroki_args" ]
  grep -q "convert" "$TEST_DIR/.kroki_args"
}

@test "specifies -f svg option" {
  # Given: d2 ソースファイルが存在する
  cd "$TEST_DIR"
  cp "$FIXTURES_DIR/$FORMAT/sample.$EXT" "$TEST_DIR/static/diagrams/src/$FORMAT/"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: -f svg オプションが指定される
  [ "$status" -eq 0 ]
  grep -q -- "-f svg" "$TEST_DIR/.kroki_args"
}

@test "specifies -o option with output path" {
  # Given: d2 ソースファイルが存在する
  cd "$TEST_DIR"
  cp "$FIXTURES_DIR/$FORMAT/sample.$EXT" "$TEST_DIR/static/diagrams/src/$FORMAT/"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: -o オプションで出力パス（.svg）が指定される
  [ "$status" -eq 0 ]
  grep -q -- "-o" "$TEST_DIR/.kroki_args"
  grep -q "sample.svg" "$TEST_DIR/.kroki_args"
}

# =============================================================================
# Edge Case Tests
# =============================================================================

@test "ignores files with wrong extension" {
  # Given: 正しい拡張子と間違った拡張子のファイルが混在する
  cd "$TEST_DIR"
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/test.$EXT"
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/readme.md"
  touch "$TEST_DIR/static/diagrams/src/$FORMAT/config.json"

  # When: convert-d2.sh を実行する
  run bash "scripts/$SCRIPT_NAME"

  # Then: .d2 ファイルのみが変換される
  [ "$status" -eq 0 ]
  count=$(echo "$output" | grep -c "Converting:" || true)
  [ "$count" -eq 1 ]
}
