# sample-design-docs-docusaurus

Docusaurus を使用した設計ドキュメントサイトのサンプルプロジェクトです。

## 目次

- [概要](#概要)
  - [主な特徴](#主な特徴)
- [クイックスタート](#クイックスタート)
- [プロジェクト構成](#プロジェクト構成)
- [環境要件](#環境要件)
- [開発コマンド](#開発コマンド)
- [ライセンス](#ライセンス)
- [関連リンク](#関連リンク)

## 概要

設計ドキュメントを Markdown で管理し、静的サイトとして公開するためのモノレポプロジェクトです。

### 主な特徴

- **Markdown ベースのドキュメント管理** - 設計書を Markdown で作成・管理
- **多言語対応（i18n）** - 日本語（デフォルト）と英語をサポート
- **テキストベースのダイアグラム** - PlantUML、Mermaid、GraphViz、D2、drawio 等をサポート
- **自動デプロイ** - GitHub Actions による GitHub Pages への自動デプロイ
- **API ドキュメント自動生成** - TypeDoc による React コンポーネントの API ドキュメント生成

## クイックスタート

```bash
# 依存関係のインストール
pnpm install

# ツールのインストール（kroki CLI 等）
mise install

# 開発サーバー起動
cd docs && pnpm start
```

ブラウザで <http://localhost:3000> を開きます。

## プロジェクト構成

pnpm workspace によるモノレポ構成です。

```
sample-design-docs-docusaurus/
├── docs/                      # Docusaurus サイト（メインパッケージ）
├── packages/
│   ├── sample-react/          # React コンポーネントライブラリ
│   ├── openapi/               # OpenAPI 仕様ファイル
│   └── e2e/                   # E2E テスト
└── .github/workflows/         # GitHub Actions
```

| パッケージ                    | 説明                            | 詳細                                          |
| ------------------------ | ----------------------------- | ------------------------------------------- |
| `docs/`                  | Docusaurus サイト本体              | [README](./docs/README.md)                  |
| `packages/sample-react/` | React コンポーネントライブラリ（TypeDoc 用） | [README](./packages/sample-react/README.md) |
| `packages/openapi/`      | OpenAPI 仕様ファイル管理              | [README](./packages/openapi/README.md)      |
| `packages/e2e/`          | E2E テスト（Playwright）           | [README](./packages/e2e/README.md)          |

## 環境要件

| ツール     | バージョン | 備考                                    |
| ------- | ----- | ------------------------------------- |
| Node.js | 24.x  | `mise.toml` で管理                       |
| pnpm    | 10.x  | `package.json` の `packageManager` で固定 |
| Docker  | -     | kroki サーバーの実行に必要                      |
| mise    | -     | 推奨（ツールバージョン管理）                        |

## 開発コマンド

| コマンド                         | 説明                    |
| ---------------------------- | --------------------- |
| `pnpm install`               | 依存関係のインストール           |
| `mise install`               | ツールのインストール            |
| `cd docs && pnpm start`      | 開発サーバー起動              |
| `cd docs && pnpm build`      | ビルド                   |
| `pnpm test`                  | 全パッケージのテスト実行          |
| `cd docs && pnpm kroki:up`   | kroki サーバー起動          |
| `cd docs && pnpm kroki:down` | kroki サーバー停止          |
| `pnpm docs:api`              | API ドキュメント生成（TypeDoc） |

詳細は [CONTRIBUTING.md](./CONTRIBUTING.md) を参照してください。

## ライセンス

MIT License - 詳細は [LICENSE](./LICENSE) を参照してください。

## 関連リンク

- [コントリビューションガイド](./CONTRIBUTING.md)
- [Docusaurus 公式ドキュメント](https://docusaurus.io/)
