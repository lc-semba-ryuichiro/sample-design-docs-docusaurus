# openapi パッケージ開発ガイド

このドキュメントでは、openapi パッケージ（OpenAPI 仕様ファイル管理）の開発・保守に必要な情報を説明します。

> 全体的な貢献ガイドライン（セットアップ、コミット規約、CI/CD 等）は [ルート CONTRIBUTING.md](../../CONTRIBUTING.md) を参照してください。

## 目次

- [仕様ファイルの作成](#仕様ファイルの作成)
  - [新規 API 仕様の追加](#新規-api-仕様の追加)
  - [仕様ファイルのテンプレート](#仕様ファイルのテンプレート)
- [仕様ファイルの検証](#仕様ファイルの検証)
  - [Spectral によるリント](#spectral-によるリント)
  - [Swagger Editor での確認](#swagger-editor-での確認)
  - [Redocly CLI による検証](#redocly-cli-による検証)
- [ドキュメント生成との連携](#ドキュメント生成との連携)
  - [手動ビルド](#手動ビルド)
- [ベストプラクティス](#ベストプラクティス)
  - [バージョニング](#バージョニング)
  - [説明の記述](#説明の記述)
  - [例の提供](#例の提供)
  - [スキーマの再利用](#スキーマの再利用)

## 仕様ファイルの作成

### 新規 API 仕様の追加

1. `specs/` ディレクトリに `.yaml` ファイルを作成
2. OpenAPI 3.0/3.1 仕様に準拠して記述
3. `docs/docusaurus.config.ts` の OpenAPI プラグイン設定を更新（対応時）

### 仕様ファイルのテンプレート

```yaml
openapi: 3.0.3
info:
  title: API タイトル
  description: |
    API の説明。
    複数行で記述可能です。
  version: 1.0.0
  contact:
    name: API Support
    email: support@example.com

servers:
  - url: https://api.example.com/v1
    description: 本番環境
  - url: https://staging-api.example.com/v1
    description: ステージング環境

tags:
  - name: resource
    description: リソース管理

paths:
  /resource:
    get:
      tags:
        - resource
      summary: リソース一覧を取得
      description: 登録されているリソースの一覧を取得します。
      operationId: listResources
      parameters:
        - name: limit
          in: query
          description: 取得する最大件数
          required: false
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Resource'

components:
  schemas:
    Resource:
      type: object
      required:
        - id
        - name
      properties:
        id:
          type: integer
          format: int64
          description: リソース ID
        name:
          type: string
          description: リソース名
```

## 仕様ファイルの検証

### Spectral によるリント

```bash
npx @stoplight/spectral-cli lint specs/petstore.yaml
```

### Swagger Editor での確認

[Swagger Editor](https://editor.swagger.io/) に仕様ファイルをコピー&ペーストして、視覚的に確認できます。

### Redocly CLI による検証

```bash
npx @redocly/cli lint specs/petstore.yaml
```

## ドキュメント生成との連携

> **注意**: OpenAPI ドキュメント生成プラグイン（`docusaurus-plugin-openapi-docs`）は現在 React 19 非対応のため、コメントアウトされています。対応されるまでは、仕様ファイルの管理のみ行います。

### 手動ビルド

```bash
# ReDoc 形式でビルド
pnpm build:redoc

# Swagger UI 形式でビルド
pnpm build:swagger

# 全フォーマットでビルド
pnpm build
```

## ベストプラクティス

### バージョニング

`info.version` を適切に更新してください。

```yaml
info:
  version: 1.0.0  # メジャー.マイナー.パッチ
```

### 説明の記述

各エンドポイント、パラメータ、レスポンスに説明を付けてください。

```yaml
parameters:
  - name: limit
    in: query
    description: 取得する最大件数  # 説明を必ず付ける
    schema:
      type: integer
```

### 例の提供

`example` または `examples` でサンプルデータを提供してください。

```yaml
schemas:
  Pet:
    type: object
    properties:
      name:
        type: string
        example: "ポチ"  # 例を提供
```

### スキーマの再利用

再利用可能なスキーマは `components/schemas` に定義してください。

```yaml
components:
  schemas:
    Error:
      type: object
      properties:
        code:
          type: integer
        message:
          type: string
```
