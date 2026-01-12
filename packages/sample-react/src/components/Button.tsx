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
  /** ボタンのサイズ */
  size?: 'small' | 'medium' | 'large';
  /** 無効状態 */
  disabled?: boolean;
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
export function Button({
  label,
  onClick,
  variant = 'primary',
  size = 'medium',
  disabled = false,
}: ButtonProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      data-variant={variant}
      data-size={size}
    >
      {label}
    </button>
  );
}
