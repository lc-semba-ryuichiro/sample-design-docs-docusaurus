# @sample/react

サンプル React コンポーネントライブラリです。

> このパッケージは TypeDoc による API ドキュメント自動生成のデモンストレーション用です。

## 目次

- [概要](#概要)
- [提供コンポーネント](#提供コンポーネント)
  - [Button](#button)
  - [Card](#card)
- [開発](#開発)
  - [テスト](#テスト)
  - [API ドキュメント生成](#api-ドキュメント生成)
- [ディレクトリ構成](#ディレクトリ構成)
- [技術スタック](#技術スタック)

## 概要

このパッケージは、TypeDoc による API ドキュメント自動生成のデモンストレーション用として作成されたサンプルコンポーネント集です。

## 提供コンポーネント

### Button

基本的なボタンコンポーネント。

```tsx
import { Button } from '@sample/react';

<Button label="送信" onClick={() => console.log('clicked')} />
<Button label="削除" variant="danger" />
<Button label="小さいボタン" size="small" />
```

**Props:**

| Prop       | 型                                      | デフォルト       | 説明              |
| ---------- | -------------------------------------- | ----------- | --------------- |
| `label`    | `string`                               | -           | ボタンに表示するラベルテキスト |
| `onClick`  | `() => void`                           | -           | クリック時のコールバック関数  |
| `variant`  | `'primary' \| 'secondary' \| 'danger'` | `'primary'` | ボタンのスタイルバリエーション |
| `size`     | `'small' \| 'medium' \| 'large'`       | `'medium'`  | ボタンのサイズ         |
| `disabled` | `boolean`                              | `false`     | 無効状態            |

### Card

コンテンツを表示するカードコンポーネント。

```tsx
import { Card } from '@sample/react';

<Card title="ユーザー情報">
  <p>名前: 山田太郎</p>
</Card>

<Card title="詳細" footer={<button>詳細を見る</button>}>
  <p>カードの内容</p>
</Card>
```

**Props:**

| Prop       | 型                  | デフォルト | 説明              |
| ---------- | ------------------ | ----- | --------------- |
| `title`    | `string`           | -     | カードのタイトル        |
| `children` | `ReactNode`        | -     | カードの内容          |
| `footer`   | `ReactNode`        | -     | カードのフッター（オプション） |
| `width`    | `string \| number` | -     | カードの幅           |

## 開発

### テスト

```bash
# テスト実行
pnpm test

# ウォッチモード
pnpm test:watch

# カバレッジ付き
pnpm test:coverage
```

### API ドキュメント生成

TypeDoc による API ドキュメントを生成するには、ルートディレクトリで以下を実行します。

```bash
pnpm docs:api
```

生成されたドキュメントは `docs/content/api/sample-react/` に配置されます。

## ディレクトリ構成

```text
packages/sample-react/
├── src/
│   ├── index.ts              # エクスポートエントリポイント
│   └── components/
│       ├── Button.tsx        # ボタンコンポーネント
│       └── Card.tsx          # カードコンポーネント
├── tests/
│   ├── setup.ts              # テスト設定
│   └── Button.test.tsx       # テストファイル
├── package.json
├── tsconfig.json
└── vitest.config.ts
```

## 技術スタック

| ツール             | バージョン | 用途         |
| --------------- | ----- | ---------- |
| React           | 19.x  | UI ライブラリ   |
| TypeScript      | 5.x   | 型付け        |
| Vitest          | -     | テストフレームワーク |
| Testing Library | -     | テストユーティリティ |

