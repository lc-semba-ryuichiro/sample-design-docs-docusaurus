---
sidebar_position: 11
---

# プラグイン機能ガイド

このサイトで利用可能な追加機能の使い方をまとめています。

## 検索機能

ページ上部の検索バーから全文検索が可能です。日本語・英語に対応しています。

- キーワードを入力すると候補が表示されます
- 検索結果ページでハイライト表示されます

## 画像ズーム

ドキュメント内の画像をクリックすると拡大表示されます。

![Docusaurus ロゴ](/img/docusaurus.png)

:::tip
上の画像をクリックしてみてください。拡大表示されます。
:::

## GitHub コード参照

GitHub リポジトリのコードを直接参照できます。

```js reference
https://github.com/facebook/docusaurus/blob/main/packages/docusaurus/src/server/index.ts#L1-L10
```

### 使い方

````markdown
```js reference
https://github.com/owner/repo/blob/main/path/to/file.js#L1-L20
```
````

## Ideal Image（最適化画像）

`@docusaurus/plugin-ideal-image` を使うと、画像が自動的に最適化されます。

MDX ファイルで以下のように使用:

```jsx
import Image from '@theme/IdealImage';
import img from './path/to/image.png';

<Image img={img} />
```

## PWA（オフライン対応）

このサイトは PWA 対応しています。

- 一度アクセスするとオフラインでも閲覧可能
- ホーム画面に追加してアプリのように使用可能

## PDF 出力

ドキュメントを PDF として出力する場合:

```bash
# 開発サーバーを起動した状態で
npx docs-to-pdf \
  --initialDocURLs="http://localhost:3000/docs/intro" \
  --contentSelector="article" \
  --paginationSelector="a.pagination-nav__link--next" \
  --excludeSelectors=".margin-vert--xl a" \
  --coverTitle="Sample Design Docs" \
  --pdfMargin="20,40,20,40"
```

## OpenAPI ドキュメント（要設定）

OpenAPI 仕様ファイル（YAML/JSON）がある場合、インタラクティブな API リファレンスを生成できます。

### 設定例

```typescript
// docusaurus.config.ts
plugins: [
  [
    'docusaurus-plugin-openapi-docs',
    {
      id: 'api',
      docsPluginId: 'classic',
      config: {
        petstore: {
          specPath: 'openapi/petstore.yaml',
          outputDir: 'content/api',
        },
      },
    },
  ],
],
```

## TypeDoc（要設定）

TypeScript プロジェクトから API ドキュメントを自動生成できます。

### 設定例

```typescript
// docusaurus.config.ts
plugins: [
  [
    'docusaurus-plugin-typedoc',
    {
      entryPoints: ['../src/index.ts'],
      tsconfig: '../tsconfig.json',
      out: 'api',
    },
  ],
],
```

## Client Redirects

URL リダイレクトを設定できます。

```typescript
// docusaurus.config.ts
plugins: [
  [
    '@docusaurus/plugin-client-redirects',
    {
      redirects: [
        {
          from: '/old-path',
          to: '/new-path',
        },
      ],
    },
  ],
],
```
