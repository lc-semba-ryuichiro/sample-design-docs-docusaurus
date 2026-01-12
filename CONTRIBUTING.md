# コントリビューションガイド

このドキュメントでは、プロジェクトへの貢献に必要な情報を説明します。

## 目次

- [開発環境のセットアップ](#開発環境のセットアップ)
  - [前提条件](#前提条件)
  - [セットアップ手順](#セットアップ手順)
- [プロジェクト構成](#プロジェクト構成)
  - [pnpm workspace](#pnpm-workspace)
  - [依存関係の catalog 管理](#依存関係の-catalog-管理)
- [コミット規約](#コミット規約)
  - [フォーマット](#フォーマット)
  - [type の種類](#type-の種類)
  - [commitlint による検証](#commitlint-による検証)
  - [pre-commit フック（lefthook）](#pre-commit-フックlefthook)
- [ブランチ戦略](#ブランチ戦略)
  - [main ブランチ](#main-ブランチ)
  - [フィーチャーブランチ](#フィーチャーブランチ)
  - [Pull Request の作成](#pull-request-の作成)
- [CI/CD](#cicd)
  - [デプロイフロー](#デプロイフロー)
  - [ワークフロー](#ワークフロー)
- [リンティング・フォーマット](#リンティングフォーマット)
  - [実行方法](#実行方法)
- [テスト](#テスト)
  - [全パッケージのテスト実行](#全パッケージのテスト実行)
  - [パッケージ固有のテスト](#パッケージ固有のテスト)
- [パッケージ固有のガイド](#パッケージ固有のガイド)

## 開発環境のセットアップ

### 前提条件

| ツール     | バージョン | 備考                                    |
| ------- | ----- | ------------------------------------- |
| Node.js | 24.x  | `mise.toml` で管理                       |
| pnpm    | 10.x  | `package.json` の `packageManager` で固定 |
| Docker  | -     | kroki サーバーの実行に必要                      |
| mise    | -     | 推奨（ツールバージョン管理）                        |

### セットアップ手順

```bash
# 1. リポジトリのクローン
git clone https://github.com/lc-semba-ryuichiro/sample-design-docs-docusaurus.git
cd sample-design-docs-docusaurus

# 2. ツールのインストール（mise を使用する場合）
mise install

# 3. 依存関係のインストール
pnpm install

# 4. 開発サーバー起動（docs パッケージ）
cd docs && pnpm start
```

## プロジェクト構成

pnpm workspace によるモノレポ構成です。

```
sample-design-docs-docusaurus/
├── docs/                      # Docusaurus サイト（メインパッケージ）
├── packages/
│   ├── sample-react/          # @sample/react - React コンポーネントライブラリ
│   └── openapi/               # @sample/openapi - OpenAPI 仕様ファイル
├── compose.yaml               # Docker Compose（kroki サーバー用）
└── .github/workflows/         # GitHub Actions
```

### pnpm workspace

`pnpm-workspace.yaml` でワークスペースパッケージを定義しています。

```yaml
packages:
  - docs
  - packages/*
```

### 依存関係の catalog 管理

`pnpm-workspace.yaml` の `catalog` で依存関係のバージョンを一元管理しています。新しい依存関係を追加する際は、まず catalog に追加してから各パッケージで参照してください。

## コミット規約

[Conventional Commits](https://www.conventionalcommits.org/) に準拠したコミットメッセージを使用します。

### フォーマット

```
<type>(<scope>): <subject>

<body>

<footer>
```

### type の種類

| type       | 説明                         |
| ---------- | -------------------------- |
| `feat`     | 新機能の追加                     |
| `fix`      | バグ修正                       |
| `docs`     | ドキュメントのみの変更                |
| `style`    | コードの意味に影響しない変更（空白、フォーマット等） |
| `refactor` | バグ修正でも機能追加でもないコード変更        |
| `perf`     | パフォーマンス改善                  |
| `test`     | テストの追加・修正                  |
| `chore`    | ビルドプロセスやツールの変更             |
| `ci`       | CI 設定の変更                   |

### commitlint による検証

コミットメッセージは commitlint によって自動検証されます。

### pre-commit フック（lefthook）

`lefthook.yml` で pre-commit フックを定義しています。

- **ダイアグラム自動変換**: kroki 形式（PlantUML, GraphViz, D2 等）のファイルがステージングされている場合、自動的に変換を実行

## ブランチ戦略

### main ブランチ

- 本番環境にデプロイされるブランチ
- 直接プッシュは禁止（Pull Request 経由でマージ）

### フィーチャーブランチ

```
feature/<issue-number>-<short-description>
fix/<issue-number>-<short-description>
docs/<short-description>
```

### Pull Request の作成

1. フィーチャーブランチを作成
2. 変更をコミット
3. リモートにプッシュ
4. Pull Request を作成
5. レビュー後にマージ

## CI/CD

GitHub Actions による自動化を行っています。

### デプロイフロー

`main` ブランチへのプッシュで GitHub Pages へ自動デプロイされます。

```
main push → Build → Deploy to GitHub Pages
```

### ワークフロー

- `.github/workflows/deploy.yml` - GitHub Pages デプロイ

## リンティング・フォーマット

| ツール        | 対象                    | 説明         |
| ---------- | --------------------- | ---------- |
| Biome      | JavaScript/TypeScript | リント・フォーマット |
| remark     | Markdown              | リント        |
| secretlint | 全ファイル                 | シークレット検出   |
| yamllint   | YAML                  | リント        |

### 実行方法

```bash
# Biome（JavaScript/TypeScript）
npx biome check .

# remark（Markdown）
npx remark --frail .

# secretlint（シークレット検出）
npx secretlint "**/*"
```

## テスト

### 全パッケージのテスト実行

```bash
pnpm test
```

### パッケージ固有のテスト

| パッケージ                   | コマンド                                    | 説明                   |
| ----------------------- | --------------------------------------- | -------------------- |
| `docs`                  | `cd docs && pnpm test:scripts`          | BATS によるシェルスクリプトテスト  |
| `packages/sample-react` | `cd packages/sample-react && pnpm test` | Vitest によるコンポーネントテスト |

## パッケージ固有のガイド

各パッケージの詳細な開発ガイドは以下を参照してください。

| パッケージ                   | ガイド                                                                      |
| ----------------------- | ------------------------------------------------------------------------ |
| `docs`                  | [docs/CONTRIBUTING.md](./docs/CONTRIBUTING.md) - ダイアグラム作成、i18n、ドキュメント構成等 |
| `packages/sample-react` | [packages/sample-react/README.md](./packages/sample-react/README.md)     |
| `packages/openapi`      | [packages/openapi/README.md](./packages/openapi/README.md)               |
