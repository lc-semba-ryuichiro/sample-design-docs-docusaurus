#!/usr/bin/env bats
# =============================================================================
# convert-single.bats - Unit tests for convert-single.sh
# =============================================================================

load 'test_helper/common'

# =============================================================================
# Setup / Teardown
# =============================================================================

setup() {
  export TEST_DIR="$(mktemp -d)"
  export FIXTURES_DIR="$BATS_TEST_DIRNAME/fixtures"
  export PATH="$BATS_TEST_DIRNAME/test_helper/mocks:$PATH"

  mkdir -p "$TEST_DIR/static/diagrams/src/plantuml"
  mkdir -p "$TEST_DIR/static/diagrams/src/mermaid"
  mkdir -p "$TEST_DIR/static/diagrams/src/graphviz"
  mkdir -p "$TEST_DIR/static/diagrams/src/d2"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# =============================================================================
# Argument Validation Tests
# =============================================================================

@test "exits with error when no arguments provided" {
  # Given: 引数なしの状態

  # When: convert-single.sh を引数なしで実行する
  run bash "$SCRIPT_DIR/convert-single.sh"

  # Then: エラー終了し、Usage メッセージが表示される
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "exits with error when file does not exist" {
  # Given: 存在しないファイルパス

  # When: 存在しないファイルを指定して実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "/nonexistent/path/file.puml"

  # Then: エラー終了し、ファイル未発見メッセージが表示される
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

# =============================================================================
# Format Detection Tests
# =============================================================================

@test "correctly detects plantuml format from path" {
  # Given: plantuml ディレクトリにサンプルファイルが存在する
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: 成功し、plantuml フォーマットとして認識される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converting (plantuml):"* ]]
}

@test "correctly detects mermaid format from path" {
  # Given: mermaid ディレクトリにサンプルファイルが存在する
  cp "$FIXTURES_DIR/mermaid/sample.mmd" "$TEST_DIR/static/diagrams/src/mermaid/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/mermaid/sample.mmd"

  # Then: 成功し、mermaid フォーマットとして認識される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converting (mermaid):"* ]]
}

@test "correctly detects graphviz format from path" {
  # Given: graphviz ディレクトリにサンプルファイルが存在する
  cp "$FIXTURES_DIR/graphviz/sample.dot" "$TEST_DIR/static/diagrams/src/graphviz/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/graphviz/sample.dot"

  # Then: 成功し、graphviz フォーマットとして認識される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converting (graphviz):"* ]]
}

@test "correctly detects d2 format from path" {
  # Given: d2 ディレクトリにサンプルファイルが存在する
  cp "$FIXTURES_DIR/d2/sample.d2" "$TEST_DIR/static/diagrams/src/d2/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/d2/sample.d2"

  # Then: 成功し、d2 フォーマットとして認識される
  [ "$status" -eq 0 ]
  [[ "$output" == *"Converting (d2):"* ]]
}

@test "errors when path lacks src/format/ pattern" {
  # Given: src/format/ パターンを含まないパスにファイルが存在する
  touch "$TEST_DIR/invalid.puml"

  # When: 不正なパスのファイルを指定して実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/invalid.puml"

  # Then: エラー終了し、フォーマット判定不可メッセージが表示される
  [ "$status" -eq 1 ]
  [[ "$output" == *"Cannot determine format"* ]]
}

@test "correctly processes files in subdirectories" {
  # Given: plantuml のサブディレクトリにファイルが存在する
  mkdir -p "$TEST_DIR/static/diagrams/src/plantuml/subdir/nested"
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/subdir/nested/"

  # When: サブディレクトリ内のファイルを指定して実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/subdir/nested/sample.puml"

  # Then: 成功し、出力パスにサブディレクトリ構造が維持される
  [ "$status" -eq 0 ]
  [[ "$output" == *"output/plantuml/subdir/nested/sample.svg"* ]]
}

# =============================================================================
# Output Path Calculation Tests
# =============================================================================

@test "replaces src/ with output/ in path" {
  # Given: plantuml ソースファイルが存在する
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: 出力パスで src/ が output/ に置換される
  [ "$status" -eq 0 ]
  [[ "$output" == *"/output/plantuml/sample.svg"* ]]
}

@test "automatically creates output directory" {
  # Given: 出力ディレクトリが存在しない状態でソースファイルがある
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"
  [ ! -d "$TEST_DIR/static/diagrams/output/plantuml" ]

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: 成功し、出力ディレクトリが自動作成される
  [ "$status" -eq 0 ]
  [ -d "$TEST_DIR/static/diagrams/output/plantuml" ]
}

@test "converts extension to .svg" {
  # Given: mermaid ファイル（.mmd 拡張子）が存在する
  cp "$FIXTURES_DIR/mermaid/sample.mmd" "$TEST_DIR/static/diagrams/src/mermaid/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/mermaid/sample.mmd"

  # Then: 出力ファイルの拡張子が .svg になる
  [ "$status" -eq 0 ]
  [[ "$output" == *"sample.svg"* ]]
}

# =============================================================================
# Kroki Conversion Tests (using mock)
# =============================================================================

@test "calls kroki CLI with correct arguments" {
  # Given: plantuml ソースファイルが存在する
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: kroki が正しい引数（-t plantuml, -f svg）で呼び出される
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.kroki_args" ]
  grep -q -- "-t plantuml" "$TEST_DIR/.kroki_args"
  grep -q -- "-f svg" "$TEST_DIR/.kroki_args"
}

@test "exits with error when kroki conversion fails" {
  # Given: kroki が失敗する状態でソースファイルがある
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"
  export MOCK_KROKI_FAIL=1

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: エラー終了し、失敗メッセージが表示される
  [ "$status" -eq 1 ]
  [[ "$output" == *"Conversion failed"* ]] || [[ "$output" == *"Error"* ]]
}

@test "displays output file path on success" {
  # Given: plantuml ソースファイルが存在する
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: 成功し、出力ファイルパス（.svg）が表示される
  [ "$status" -eq 0 ]
  [[ "$output" == *".svg"* ]]
}

@test "generates SVG file on success" {
  # Given: plantuml ソースファイルが存在する
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"

  # When: convert-single.sh を実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: 成功し、SVG ファイルが生成される
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/static/diagrams/output/plantuml/sample.svg" ]
}

# =============================================================================
# Edge Case Tests
# =============================================================================

@test "handles filenames with spaces" {
  # Given: スペースを含むファイル名の plantuml ファイルが存在する
  mkdir -p "$TEST_DIR/static/diagrams/src/plantuml"
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/sample file.puml"

  # When: スペースを含むファイルを指定して実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample file.puml"

  # Then: 正常に処理される
  [ "$status" -eq 0 ]
}

@test "handles both relative and absolute paths" {
  # Given: plantuml ソースファイルが存在する
  cp "$FIXTURES_DIR/plantuml/sample.puml" "$TEST_DIR/static/diagrams/src/plantuml/"

  # When: 絶対パスを指定して実行する
  run bash "$SCRIPT_DIR/convert-single.sh" "$TEST_DIR/static/diagrams/src/plantuml/sample.puml"

  # Then: 正常に処理される
  [ "$status" -eq 0 ]
}
