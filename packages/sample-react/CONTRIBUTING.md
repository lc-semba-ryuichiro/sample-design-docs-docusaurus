# sample-react パッケージ開発ガイド

このドキュメントでは、sample-react パッケージ（React コンポーネントライブラリ）の開発・保守に必要な情報を説明します。

> 全体的な貢献ガイドライン（セットアップ、コミット規約、CI/CD 等）は [ルート CONTRIBUTING.md](../../CONTRIBUTING.md) を参照してください。

## 目次

- [テスト](#テスト)
  - [テストの書き方](#テストの書き方)
- [コンポーネント追加](#コンポーネント追加)
  - [手順](#手順)
  - [ファイル構成](#ファイル構成)
- [TypeDoc](#typedoc)
  - [JSDoc の書き方](#jsdoc-の書き方)
  - [API ドキュメント生成](#api-ドキュメント生成)
- [コーディング規約](#コーディング規約)

## テスト

Vitest と Testing Library を使用してコンポーネントをテストします。

```bash
# テスト実行
pnpm test

# ウォッチモード
pnpm test:watch

# カバレッジ付き
pnpm test:coverage
```

### テストの書き方

```tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../src/components/Button';

describe('Button', () => {
  it('ラベルを正しく表示する', () => {
    render(<Button label="クリック" />);
    expect(screen.getByText('クリック')).toBeInTheDocument();
  });

  it('クリック時に onClick が呼ばれる', () => {
    const handleClick = vi.fn();
    render(<Button label="送信" onClick={handleClick} />);

    fireEvent.click(screen.getByText('送信'));

    expect(handleClick).toHaveBeenCalledOnce();
  });
});
```

## コンポーネント追加

### 手順

1. `src/components/` にコンポーネントファイルを作成
2. JSDoc コメントで Props と機能を文書化
3. `src/index.ts` でエクスポート
4. `tests/` にテストファイルを作成

### ファイル構成

```text
src/
├── index.ts              # エクスポートエントリポイント
└── components/
    ├── Button.tsx        # コンポーネント
    └── NewComponent.tsx  # 新規コンポーネント

tests/
├── setup.ts              # テスト設定
├── Button.test.tsx       # テストファイル
└── NewComponent.test.tsx # 新規テスト
```

## TypeDoc

API ドキュメントを自動生成するため、適切な JSDoc コメントを記述してください。

### JSDoc の書き方

````tsx
/**
 * ボタンコンポーネントのプロパティ
 */
export interface ButtonProps {
  /** ボタンに表示するラベルテキスト */
  label: string;
  /** クリック時に呼び出されるコールバック関数 */
  onClick?: () => void;
  /** ボタンのスタイルバリエーション */
  variant?: 'primary' | 'secondary' | 'danger';
}

/**
 * 基本的なボタンコンポーネント
 *
 * @example
 * ```tsx
 * <Button label="送信" onClick={() => console.log('clicked')} />
 * <Button label="削除" variant="danger" />
 * ```
 */
export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  // ...
}
````

### API ドキュメント生成

ルートディレクトリで以下を実行します。

```bash
pnpm docs:api
```

生成されたドキュメントは `docs/content/api/sample-react/` に配置されます。

## コーディング規約

- **Props 定義**: interface で定義し、各プロパティに JSDoc コメントを付ける
- **コンポーネント形式**: 関数コンポーネントで実装
- **デフォルト値**: Props のデストラクチャリングで設定
- **型安全性**: `any` の使用を避け、適切な型を定義
