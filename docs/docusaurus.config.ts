import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// このファイルはNode.jsで実行されます。クライアントサイドのコード（ブラウザAPI、JSX等）は使用しないでください。

const config: Config = {
  title: 'Sample Design Docs',
  tagline: '設計ドキュメント',
  favicon: 'img/favicon.ico',

  // 将来のフラグ設定（参照: https://docusaurus.io/docs/api/docusaurus-config#future）
  future: {
    v4: true, // Docusaurus v4との互換性を向上
  },

  // 本番環境のURL
  url: 'https://lc-semba-ryuichiro.github.io',
  // サイトが配信されるベースパス
  // GitHub Pagesの場合、通常は '/<プロジェクト名>/'
  baseUrl: process.env.BASE_URL || '/',

  // GitHub Pagesデプロイ設定
  organizationName: 'lc-semba-ryuichiro',
  projectName: 'sample-design-docs-docusaurus',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  // リンク切れ検出時の動作
  onBrokenLinks: 'throw',

  // Markdown設定
  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  // テーマ
  themes: [
    '@docusaurus/theme-mermaid',
    '@docusaurus/theme-live-codeblock',
    'docusaurus-theme-github-codeblock',
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        language: ['ja', 'en'],
        highlightSearchTermsOnTargetPage: true,
        explicitSearchResultPath: true,
        docsDir: 'content',
        blogDir: [],
      },
    ],
  ],

  // プラグイン
  plugins: [
    '@docusaurus/plugin-ideal-image',
    'docusaurus-plugin-image-zoom',
    [
      '@docusaurus/plugin-client-redirects',
      {
        redirects: [],
      },
    ],
    // TypeDoc: React コンポーネントの API ドキュメント生成
    [
      'docusaurus-plugin-typedoc',
      {
        id: 'sample-react',
        entryPoints: ['../packages/sample-react/src/index.ts'],
        tsconfig: '../packages/sample-react/tsconfig.json',
        out: 'content/api/sample-react',
      },
    ],
  ],

  // 国際化設定
  i18n: {
    defaultLocale: 'ja',
    locales: ['ja', 'en'],
    localeConfigs: {
      ja: {
        label: '日本語',
        htmlLang: 'ja',
      },
      en: {
        label: 'English',
        htmlLang: 'en',
      },
    },
  },

  // プリセット設定
  presets: [
    [
      'classic',
      {
        docs: {
          path: 'content', // ドキュメントのソースディレクトリ
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/lc-semba-ryuichiro/sample-design-docs-docusaurus/tree/main/docs/',
        },
        blog: false, // ブログ機能を無効化
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  // テーマ設定
  themeConfig: {
    image: 'img/docusaurus-social-card.jpg', // OGP画像
    colorMode: {
      respectPrefersColorScheme: true, // システムのカラーモード設定に従う
    },
    // ナビゲーションバー
    navbar: {
      title: 'Sample Design Docs',
      logo: {
        alt: 'Sample Design Docs Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'ドキュメント',
        },
        {
          type: 'localeDropdown', // 言語切り替え
          position: 'right',
        },
        {
          href: 'https://github.com/lc-semba-ryuichiro/sample-design-docs-docusaurus',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    // フッター
    footer: {
      style: 'dark',
      links: [
        {
          title: 'ドキュメント',
          items: [
            {
              label: 'はじめに',
              to: '/docs/intro',
            },
          ],
        },
        {
          title: 'リンク',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/lc-semba-ryuichiro/sample-design-docs-docusaurus',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Sample Design Docs. Built with Docusaurus.`,
    },
    // コードハイライト設定
    prism: {
      theme: prismThemes.github, // ライトモード用テーマ
      darkTheme: prismThemes.dracula, // ダークモード用テーマ
    },
    // 画像ズーム設定
    zoom: {
      selector: '.markdown img',
      background: {
        light: 'rgba(255, 255, 255, 0.9)',
        dark: 'rgba(50, 50, 50, 0.9)',
      },
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
