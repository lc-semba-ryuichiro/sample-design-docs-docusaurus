# @sample/openapi

OpenAPI 仕様ファイルを管理するパッケージです。

> プロジェクト全体の概要は [ルート README](../../README.md) を参照してください。

## 目次

- [概要](#概要)
- [含まれる仕様ファイル](#含まれる仕様ファイル)
  - [petstore.yaml](#petstoreyaml)
- [使い方](#使い方)
  - [新規 OpenAPI 仕様の追加](#新規-openapi-仕様の追加)
  - [仕様ファイルの編集](#仕様ファイルの編集)
  - [仕様ファイルの検証](#仕様ファイルの検証)
- [ディレクトリ構成](#ディレクトリ構成)
- [注意事項](#注意事項)
- [関連リンク](#関連リンク)

## 概要

このパッケージは、OpenAPI 仕様ファイルを管理し、docs サイトでの API ドキュメント自動生成と連携するためのサンプルです。

## 含まれる仕様ファイル

| ファイル                  | 説明                                |
| --------------------- | --------------------------------- |
| `specs/petstore.yaml` | Sample Pet Store API（デモンストレーション用） |

### petstore.yaml

サンプルの Pet Store API 仕様です。

- **バージョン**: OpenAPI 3.0.3
- **エンドポイント**:
  - `GET /pets` - ペット一覧を取得
  - `POST /pets` - 新しいペットを登録
  - `GET /pets/{petId}` - 特定のペットを取得
  - その他

## 使い方

### 新規 OpenAPI 仕様の追加

1. `specs/` ディレクトリに `.yaml` ファイルを追加
2. `docs/docusaurus.config.ts` の OpenAPI プラグイン設定を更新
3. API ドキュメントを生成

```bash
# ルートディレクトリで実行
pnpm docs:api
```

### 仕様ファイルの編集

- YAML 形式で記述
- [OpenAPI 3.0/3.1 仕様](https://spec.openapis.org/oas/latest.html)に準拠

### 仕様ファイルの検証

OpenAPI 仕様の検証には、以下のツールが利用可能です。

```bash
# Spectral（別途インストールが必要）
npx @stoplight/spectral-cli lint specs/petstore.yaml
```

## ディレクトリ構成

```
packages/openapi/
├── specs/
│   └── petstore.yaml    # サンプル API 仕様
├── package.json
└── README.md
```

## 注意事項

- OpenAPI ドキュメント生成プラグイン（`docusaurus-plugin-openapi-docs`）は React 19 非対応のため、現在コメントアウトされています
- 対応されるまでは、仕様ファイルの管理のみ行います

## 関連リンク

- [ルート README](../../README.md) - プロジェクト全体の概要
- [ルート CONTRIBUTING.md](../../CONTRIBUTING.md) - 貢献ガイドライン
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html) - OpenAPI 公式仕様
- [Swagger Editor](https://editor.swagger.io/) - オンラインエディタ
