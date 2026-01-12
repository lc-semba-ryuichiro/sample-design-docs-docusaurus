import {describe, it, expect, vi} from 'vitest';
import {render, screen, fireEvent} from '@testing-library/react';
import {Button} from '../src/components/Button';

describe('Button', () => {
  it('ラベルを正しく表示する', () => {
    render(<Button label="クリック" />);
    expect(screen.getByText('クリック')).toBeInTheDocument();
  });

  it('クリック時にonClickが呼ばれる', () => {
    const handleClick = vi.fn();
    render(<Button label="送信" onClick={handleClick} />);

    fireEvent.click(screen.getByText('送信'));

    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('disabled時はonClickが呼ばれない', () => {
    const handleClick = vi.fn();
    render(<Button label="送信" onClick={handleClick} disabled />);

    fireEvent.click(screen.getByText('送信'));

    expect(handleClick).not.toHaveBeenCalled();
  });

  it('variantが正しく設定される', () => {
    render(<Button label="削除" variant="danger" />);

    const button = screen.getByText('削除');
    expect(button).toHaveAttribute('data-variant', 'danger');
  });

  it('sizeが正しく設定される', () => {
    render(<Button label="小さいボタン" size="small" />);

    const button = screen.getByText('小さいボタン');
    expect(button).toHaveAttribute('data-size', 'small');
  });

  it('デフォルト値が正しく設定される', () => {
    render(<Button label="デフォルト" />);

    const button = screen.getByText('デフォルト');
    expect(button).toHaveAttribute('data-variant', 'primary');
    expect(button).toHaveAttribute('data-size', 'medium');
    expect(button).not.toBeDisabled();
  });
});
