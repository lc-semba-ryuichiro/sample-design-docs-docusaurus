#!/usr/bin/env bats
# =============================================================================
# convert-drawio.bats - Unit tests for convert-drawio.sh
# =============================================================================

load 'test_helper/common'

# =============================================================================
# Setup / Teardown
# =============================================================================

setup() {
  export TEST_DIR="$(mktemp -d)"
  export PATH="$BATS_TEST_DIRNAME/test_helper/mocks:$PATH"

  mkdir -p "$TEST_DIR/docs/scripts"
  mkdir -p "$TEST_DIR/docs/static/diagrams/src/drawio"
  mkdir -p "$TEST_DIR/docs/static/diagrams/output/drawio"

  cp "$SCRIPT_DIR/convert-drawio.sh" "$TEST_DIR/docs/scripts/"

  # テスト用の .drawio ファイルを作成
  touch "$TEST_DIR/docs/static/diagrams/src/drawio/test.drawio"

  cat > "$TEST_DIR/compose.yaml" << 'EOF'
services:
  drawio-export:
    image: rlespinasse/drawio-export
EOF
}

teardown() {
  rm -rf "$TEST_DIR"
}

# =============================================================================
# Docker Invocation Tests
# =============================================================================

@test "calls docker compose run" {
  # Given: テスト用の docs/ ディレクトリ構造がある
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: docker compose run が呼び出される
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.docker_args" ]
  grep -q "compose run" "$TEST_DIR/.docker_args"
}

@test "specifies drawio-export service" {
  # Given: テスト用の docs/ ディレクトリ構造がある
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: drawio-export サービスが指定される
  [ "$status" -eq 0 ]
  grep -q "drawio-export" "$TEST_DIR/.docker_args"
}

@test "specifies --rm option" {
  # Given: テスト用の docs/ ディレクトリ構造がある
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: --rm オプションが指定される
  [ "$status" -eq 0 ]
  grep -q -- "--rm" "$TEST_DIR/.docker_args"
}

@test "specifies -f png option for format" {
  # Given: テスト用の docs/ ディレクトリ構造がある
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: -f png オプションが指定される
  [ "$status" -eq 0 ]
  grep -q -- "-f png" "$TEST_DIR/.docker_args"
}

@test "specifies -x option for export mode" {
  # Given: テスト用の docs/ ディレクトリ構造がある
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: -x オプション（エクスポートモード）が指定される
  [ "$status" -eq 0 ]
  grep -q -- "-x" "$TEST_DIR/.docker_args"
}

@test "specifies -o option for output path" {
  # Given: テスト用の docs/ ディレクトリ構造がある
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: -o オプションで出力パスが指定される
  [ "$status" -eq 0 ]
  grep -q -- "-o" "$TEST_DIR/.docker_args"
}

# =============================================================================
# Directory Navigation Tests
# =============================================================================

@test "moves to project root for execution" {
  # Given: scripts/ ディレクトリにいる状態
  cd "$TEST_DIR/docs/scripts"

  # When: convert-drawio.sh を実行する
  run bash convert-drawio.sh

  # Then: 成功し、docker が呼び出される
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.docker_args" ]
}

@test "works when run from docs/ directory" {
  # Given: docs/ ディレクトリにいる状態
  cd "$TEST_DIR/docs"

  # When: scripts/convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: 正常に処理される
  [ "$status" -eq 0 ]
}

# =============================================================================
# Error Handling Tests
# =============================================================================

@test "exits with error when Docker fails" {
  # Given: Docker が失敗する状態（MOCK_DOCKER_FAIL=1）
  export MOCK_DOCKER_FAIL=1
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: エラー終了する
  [ "$status" -ne 0 ]
}

@test "outputs error message when Docker fails" {
  # Given: Docker が失敗する状態（MOCK_DOCKER_FAIL=1）
  export MOCK_DOCKER_FAIL=1
  cd "$TEST_DIR/docs"

  # When: convert-drawio.sh を実行する
  run bash scripts/convert-drawio.sh

  # Then: エラー終了し、エラーメッセージが表示される
  [ "$status" -ne 0 ]
  [[ "$output" == *"Error"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Docker"* ]]
}
