# @sample/e2e

@sample/react コンポーネントの E2E テストパッケージです。

> プロジェクト全体の概要は [ルート README](../../README.md) を参照してください。

## 目次

- [概要](#概要)
- [テスト対象](#テスト対象)
- [主要コマンド](#主要コマンド)
- [ディレクトリ構成](#ディレクトリ構成)
- [技術スタック](#技術スタック)
- [開発者向け情報](#開発者向け情報)
- [関連リンク](#関連リンク)

## 概要

このパッケージは、Playwright Component Testing を使用して @sample/react パッケージのコンポーネントを E2E テストします。

## テスト対象

| コンポーネント | テストファイル                 | 説明         |
| ------- | ----------------------- | ---------- |
| Button  | `tests/Button.spec.tsx` | ボタンコンポーネント |
| Card    | `tests/Card.spec.tsx`   | カードコンポーネント |

## 主要コマンド

| コマンド           | 説明           |
| -------------- | ------------ |
| `pnpm test`    | E2E テスト実行    |
| `pnpm test:ui` | UI モードでテスト実行 |
| `pnpm report`  | テストレポート表示    |

## ディレクトリ構成

```text
packages/e2e/
├── tests/
│   ├── global-setup.ts       # グローバルセットアップ
│   ├── Button.spec.tsx       # Button コンポーネントテスト
│   └── Card.spec.tsx         # Card コンポーネントテスト
├── playwright/
│   ├── index.html            # テスト用 HTML
│   └── index.tsx             # テスト用エントリポイント
├── playwright-ct.config.ts   # Playwright 設定
├── package.json
└── tsconfig.json
```

## 技術スタック

| ツール                               | 用途               |
| --------------------------------- | ---------------- |
| Playwright                        | E2E テストフレームワーク   |
| @playwright/experimental-ct-react | React コンポーネントテスト |
| TypeScript                        | 型付け              |

## 開発者向け情報

詳細な開発ガイドは [CONTRIBUTING.md](./CONTRIBUTING.md) を参照してください。

## 関連リンク

- [ルート README](../../README.md) - プロジェクト全体の概要
- [ルート CONTRIBUTING.md](../../CONTRIBUTING.md) - 全体の貢献ガイドライン
- [CONTRIBUTING.md](./CONTRIBUTING.md) - e2e パッケージの開発ガイド
- [@sample/react README](../sample-react/README.md) - テスト対象コンポーネント
