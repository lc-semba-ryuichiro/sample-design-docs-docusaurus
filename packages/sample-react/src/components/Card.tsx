import type {ReactNode} from 'react';

/**
 * カードコンポーネントのプロパティ
 */
export interface CardProps {
  /** カードのタイトル */
  title: string;
  /** カードの内容 */
  children: ReactNode;
  /** カードのフッター（オプション） */
  footer?: ReactNode;
  /** カードの幅 */
  width?: string | number;
}

/**
 * コンテンツを表示するカードコンポーネント
 *
 * @example
 * ```tsx
 * <Card title="ユーザー情報">
 *   <p>名前: 山田太郎</p>
 * </Card>
 * ```
 */
export function Card({title, children, footer, width}: CardProps) {
  return (
    <div
      data-component="card"
      style={{
        width,
        border: '1px solid #e0e0e0',
        borderRadius: '8px',
        overflow: 'hidden',
      }}
    >
      <div
        data-part="header"
        style={{
          padding: '16px',
          borderBottom: '1px solid #e0e0e0',
          fontWeight: 'bold',
        }}
      >
        {title}
      </div>
      <div data-part="content" style={{padding: '16px'}}>
        {children}
      </div>
      {footer && (
        <div
          data-part="footer"
          style={{
            padding: '16px',
            borderTop: '1px solid #e0e0e0',
            backgroundColor: '#f5f5f5',
          }}
        >
          {footer}
        </div>
      )}
    </div>
  );
}
