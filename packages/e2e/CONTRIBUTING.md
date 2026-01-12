# e2e パッケージ開発ガイド

このドキュメントでは、e2e パッケージ（Playwright Component Testing）の開発・保守に必要な情報を説明します。

> 全体的な貢献ガイドライン（セットアップ、コミット規約、CI/CD 等）は [ルート CONTRIBUTING.md](../../CONTRIBUTING.md) を参照してください。

## 目次

- [テスト実行](#テスト実行)
- [テストの書き方](#テストの書き方)
  - [アサーションの例](#アサーションの例)
- [新規テストの追加](#新規テストの追加)
  - [ファイル命名規則](#ファイル命名規則)
- [Playwright 設定](#playwright-設定)
- [トラブルシューティング](#トラブルシューティング)
  - [ブラウザが見つからない](#ブラウザが見つからない)
  - [キャッシュのクリア](#キャッシュのクリア)
  - [テスト結果のクリア](#テスト結果のクリア)

## テスト実行

```bash
# 全テスト実行
pnpm test

# UI モードで実行（デバッグに便利）
pnpm test:ui

# テストレポート表示
pnpm report

# 特定のテストファイルのみ実行
pnpm test tests/Button.spec.tsx
```

## テストの書き方

Playwright Component Testing を使用してコンポーネントをマウントし、テストします。

```tsx
import { test, expect } from '@playwright/experimental-ct-react';
import { Button } from '@sample/react';

test.describe('Button', () => {
  test('ラベルが表示される', async ({ mount }) => {
    const component = await mount(<Button label="送信" />);
    await expect(component).toContainText('送信');
  });

  test('クリックイベントが発火する', async ({ mount }) => {
    let clicked = false;
    const component = await mount(
      <Button label="クリック" onClick={() => (clicked = true)} />
    );
    await component.click();
    expect(clicked).toBe(true);
  });

  test('無効状態ではクリックできない', async ({ mount }) => {
    const component = await mount(
      <Button label="無効" onClick={() => {}} disabled />
    );
    await expect(component).toBeDisabled();
  });
});
```

### アサーションの例

| アサーション                                      | 説明             |
| ------------------------------------------- | -------------- |
| `await expect(component).toContainText()`   | テキストが含まれることを確認 |
| `await expect(component).toHaveAttribute()` | 属性値を確認         |
| `await expect(component).toBeDisabled()`    | 無効状態であることを確認   |
| `await expect(component).toBeVisible()`     | 表示されていることを確認   |

## 新規テストの追加

1. `tests/` ディレクトリに `.spec.tsx` ファイルを作成
2. `@playwright/experimental-ct-react` から `test`, `expect` をインポート
3. テスト対象コンポーネントを `@sample/react` からインポート
4. `mount` 関数でコンポーネントをマウント
5. アサーションを記述

### ファイル命名規則

```text
tests/
├── Button.spec.tsx    # Button コンポーネントのテスト
├── Card.spec.tsx      # Card コンポーネントのテスト
└── NewComponent.spec.tsx  # 新規コンポーネントのテスト
```

## Playwright 設定

`playwright-ct.config.ts` で設定を管理しています。

- **テストディレクトリ**: `tests/`
- **グローバルセットアップ**: `tests/global-setup.ts`
- **レポート出力**: `playwright-report/`
- **テスト結果**: `test-results/`

## トラブルシューティング

### ブラウザが見つからない

```bash
npx playwright install
```

### キャッシュのクリア

```bash
rm -rf playwright/.cache
```

### テスト結果のクリア

```bash
rm -rf test-results playwright-report
```
