import {test, expect} from '@playwright/experimental-ct-react';
import {Card} from '@sample/react';

test.describe('Card', () => {
  test('renders with title and content', async ({mount}) => {
    const component = await mount(
      <Card title="ユーザー情報">
        <p>名前: 山田太郎</p>
      </Card>,
    );
    await expect(component).toContainText('ユーザー情報');
    await expect(component).toContainText('名前: 山田太郎');
  });

  test('renders with footer', async ({mount, page}) => {
    const component = await mount(
      <Card title="タイトル" footer={<button type="button">アクション</button>}>
        コンテンツ
      </Card>,
    );
    await expect(page.locator('[data-part="footer"]')).toContainText(
      'アクション',
    );
  });

  test('renders with custom width', async ({mount}) => {
    const component = await mount(
      <Card title="幅指定" width={400}>
        コンテンツ
      </Card>,
    );
    await expect(component).toHaveCSS('width', '400px');
  });

  test('does not render footer when not provided', async ({mount, page}) => {
    const component = await mount(
      <Card title="フッターなし">コンテンツのみ</Card>,
    );
    await expect(page.locator('[data-part="footer"]')).toHaveCount(0);
  });
});
