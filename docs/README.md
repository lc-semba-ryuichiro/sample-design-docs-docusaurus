# docs - Docusaurus サイト

[Docusaurus](https://docusaurus.io/) を使用した設計ドキュメントサイト本体のパッケージです。

> プロジェクト全体の概要は [ルート README](../README.md) を参照してください。

## 目次

- [機能](#機能)
- [クイックスタート](#クイックスタート)
- [ドキュメント構成](#ドキュメント構成)
- [主要コマンド](#主要コマンド)
- [開発者向け情報](#開発者向け情報)
- [関連リンク](#関連リンク)

## 機能

- **Markdown ベースのドキュメント管理** - Markdown で設計書を作成・管理
- **多言語対応（i18n）** - 日本語（デフォルト）と英語をサポート
- **テキストベースのダイアグラム** - PlantUML、Mermaid、GraphViz、D2、drawio 等をサポート
- **自動デプロイ** - GitHub Actions による GitHub Pages への自動デプロイ

## クイックスタート

```bash
# 開発サーバー起動（日本語版）
pnpm start

# 英語版で起動
pnpm start --locale en
```

ブラウザで <http://localhost:3000> を開きます。

## ドキュメント構成

`content/` 配下にドキュメントを配置します。

| カテゴリ    | パス                        | 説明                            |
| ------- | ------------------------- | ----------------------------- |
| イントロ    | `content/intro.md`        | サイトのイントロダクション                 |
| ADR     | `content/adr/`            | Architecture Decision Records |
| アーキテクチャ | `content/architecture/`   | アーキテクチャ設計                     |
| 仕様書     | `content/specifications/` | 仕様書                           |
| ガイド     | `content/guides/`         | ガイド・手順書                       |
| フロントエンド | `content/frontend/`       | フロントエンド関連                     |
| BFF     | `content/bff/`            | Backend for Frontend 関連       |
| API     | `content/api/`            | API ドキュメント（自動生成）              |

## 主要コマンド

| コマンド                | 説明                 |
| ------------------- | ------------------ |
| `pnpm start`        | 開発サーバー起動           |
| `pnpm build`        | ビルド                |
| `pnpm serve`        | ビルド済みサイトのプレビュー     |
| `pnpm typecheck`    | 型チェック              |
| `pnpm test:scripts` | シェルスクリプトのテスト（BATS） |
| `pnpm diagrams:all` | ダイアグラム一括変換         |

## 開発者向け情報

詳細な開発ガイドは [CONTRIBUTING.md](./CONTRIBUTING.md) を参照してください。

- セットアップ・前提条件
- ダイアグラム作成ガイド
- 国際化（i18n）
- ディレクトリ構成

## 関連リンク

- [ルート README](../README.md) - プロジェクト全体の概要
- [ルート CONTRIBUTING.md](../CONTRIBUTING.md) - 全体の貢献ガイドライン
- [CONTRIBUTING.md](./CONTRIBUTING.md) - docs パッケージの開発ガイド
