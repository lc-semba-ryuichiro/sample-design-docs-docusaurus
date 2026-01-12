import {test, expect} from '@playwright/experimental-ct-react';
import {Button} from '@sample/react';

test.describe('Button', () => {
  test('renders with label', async ({mount}) => {
    const component = await mount(<Button label="送信" />);
    await expect(component).toContainText('送信');
  });

  test('handles click events', async ({mount}) => {
    let clicked = false;
    const component = await mount(
      <Button label="クリック" onClick={() => (clicked = true)} />,
    );
    await component.click();
    expect(clicked).toBe(true);
  });

  test('renders with variant', async ({mount}) => {
    const component = await mount(<Button label="削除" variant="danger" />);
    await expect(component).toHaveAttribute('data-variant', 'danger');
  });

  test('disabled state prevents click', async ({mount}) => {
    const component = await mount(
      <Button label="無効" onClick={() => {}} disabled />,
    );
    await expect(component).toBeDisabled();
  });

  test('renders with small size', async ({mount}) => {
    const component = await mount(<Button label="小" size="small" />);
    await expect(component).toHaveAttribute('data-size', 'small');
  });

  test('renders with large size', async ({mount}) => {
    const component = await mount(<Button label="大" size="large" />);
    await expect(component).toHaveAttribute('data-size', 'large');
  });
});
