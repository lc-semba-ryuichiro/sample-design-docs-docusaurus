#!/usr/bin/env bats
# =============================================================================
# convert-all-kroki.bats - Unit tests for convert-all-kroki.sh
# =============================================================================

load 'test_helper/common'

# =============================================================================
# Setup / Teardown
# =============================================================================

setup() {
  export TEST_DIR="$(mktemp -d)"
  export FIXTURES_DIR="$BATS_TEST_DIRNAME/fixtures"
  export PATH="$BATS_TEST_DIRNAME/test_helper/mocks:$PATH"

  mkdir -p "$TEST_DIR/scripts"
  mkdir -p "$TEST_DIR/static/diagrams/src"

  # Create mock for convert-single.sh
  cat > "$TEST_DIR/scripts/convert-single.sh" << 'MOCK_SCRIPT'
#!/bin/bash
echo "$1" >> "${TEST_DIR}/.convert_single_calls"
if [ "${MOCK_CONVERT_FAIL:-0}" = "1" ]; then
  exit 1
fi
if [[ "$1" == *"fail"* ]]; then
  exit 1
fi
exit 0
MOCK_SCRIPT
  chmod +x "$TEST_DIR/scripts/convert-single.sh"

  cp "$SCRIPT_DIR/convert-all-kroki.sh" "$TEST_DIR/scripts/"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# =============================================================================
# Basic Operation Tests
# =============================================================================

@test "completes with 0 files when no source directory exists" {
  # Given: ソースディレクトリが存在しない状態
  cd "$TEST_DIR"

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、0ファイル変換・0ファイル失敗と表示される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 0 files"* ]]
  [[ "$output" == *"Failed: 0 files"* ]]
}

@test "outputs header and footer" {
  # Given: 空のソースディレクトリ
  cd "$TEST_DIR"

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: ヘッダーとフッターが出力される
  [ "$status" -eq 0 ]
  [[ "$output" == *"=== Kroki Diagram Conversion ==="* ]]
  [[ "$output" == *"=== Conversion Complete ==="* ]]
}

# =============================================================================
# Single Format Tests
# =============================================================================

@test "detects and converts plantuml files" {
  # Given: plantuml ディレクトリに .puml ファイルが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml
  touch static/diagrams/src/plantuml/test.puml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、1ファイル変換され、convert-single.sh が呼び出される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 1 files"* ]]
  [ -f "$TEST_DIR/.convert_single_calls" ]
  grep -q "plantuml/test.puml" "$TEST_DIR/.convert_single_calls"
}

@test "detects and converts mermaid files" {
  # Given: mermaid ディレクトリに .mmd ファイルが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/mermaid
  touch static/diagrams/src/mermaid/test.mmd

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、1ファイル変換され、convert-single.sh が呼び出される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 1 files"* ]]
  grep -q "mermaid/test.mmd" "$TEST_DIR/.convert_single_calls"
}

@test "detects and converts graphviz files" {
  # Given: graphviz ディレクトリに .dot ファイルが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/graphviz
  touch static/diagrams/src/graphviz/test.dot

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、1ファイル変換され、convert-single.sh が呼び出される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 1 files"* ]]
  grep -q "graphviz/test.dot" "$TEST_DIR/.convert_single_calls"
}

@test "detects and converts d2 files" {
  # Given: d2 ディレクトリに .d2 ファイルが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/d2
  touch static/diagrams/src/d2/test.d2

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、1ファイル変換され、convert-single.sh が呼び出される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 1 files"* ]]
  grep -q "d2/test.d2" "$TEST_DIR/.convert_single_calls"
}

# =============================================================================
# Multiple Files/Formats Tests
# =============================================================================

@test "converts all multiple files" {
  # Given: plantuml ディレクトリに複数の .puml ファイルが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml
  touch static/diagrams/src/plantuml/test1.puml
  touch static/diagrams/src/plantuml/test2.puml
  touch static/diagrams/src/plantuml/test3.puml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、3ファイル全てが変換される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 3 files"* ]]
}

@test "processes multiple formats" {
  # Given: 異なるフォーマットのファイルが複数存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml
  mkdir -p static/diagrams/src/graphviz
  mkdir -p static/diagrams/src/d2
  touch static/diagrams/src/plantuml/test.puml
  touch static/diagrams/src/graphviz/test.dot
  touch static/diagrams/src/d2/test.d2

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、全フォーマットの3ファイルが変換される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 3 files"* ]]
}

@test "detects files in subdirectories" {
  # Given: サブディレクトリに .puml ファイルが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml/subdir/nested
  touch static/diagrams/src/plantuml/subdir/nested/test.puml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、サブディレクトリのファイルも変換される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 1 files"* ]]
  grep -q "subdir/nested/test.puml" "$TEST_DIR/.convert_single_calls"
}

# =============================================================================
# Failure Handling Tests
# =============================================================================

@test "increments failure count on conversion error" {
  # Given: ファイル名に "fail" を含むファイルが存在する（モックが失敗を返す）
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml
  touch static/diagrams/src/plantuml/fail_test.puml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功終了するが、失敗1件としてカウントされる
  [ "$status" -eq 0 ]
  [[ "$output" == *"Failed: 1 files"* ]]
  [[ "$output" == *"[FAILED]"* ]]
}

@test "correctly counts mixed success and failure" {
  # Given: 成功するファイル2つと失敗するファイル1つが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml
  touch static/diagrams/src/plantuml/success1.puml
  touch static/diagrams/src/plantuml/fail_test.puml
  touch static/diagrams/src/plantuml/success2.puml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功2件、失敗1件としてカウントされる
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 2 files"* ]]
  [[ "$output" == *"Failed: 1 files"* ]]
}

@test "exits with 0 even when all files fail" {
  # Given: 全てのファイルが失敗する状態（MOCK_CONVERT_FAIL=1）
  cd "$TEST_DIR"
  export MOCK_CONVERT_FAIL=1
  mkdir -p static/diagrams/src/plantuml
  touch static/diagrams/src/plantuml/test.puml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: スクリプト自体は成功終了し、全ファイル失敗としてカウントされる
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 0 files"* ]]
  [[ "$output" == *"Failed: 1 files"* ]]
}

# =============================================================================
# Edge Case Tests
# =============================================================================

@test "ignores files with wrong extension" {
  # Given: 正しい拡張子と間違った拡張子のファイルが混在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml
  touch static/diagrams/src/plantuml/test.puml
  touch static/diagrams/src/plantuml/readme.md
  touch static/diagrams/src/plantuml/config.json

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: .puml ファイルのみが変換される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 1 files"* ]]
}

@test "handles empty source directory as 0 files" {
  # Given: 空の plantuml ソースディレクトリが存在する
  cd "$TEST_DIR"
  mkdir -p static/diagrams/src/plantuml

  # When: convert-all-kroki.sh を実行する
  run bash scripts/convert-all-kroki.sh

  # Then: 成功し、0ファイル変換と表示される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converted: 0 files"* ]]
}
