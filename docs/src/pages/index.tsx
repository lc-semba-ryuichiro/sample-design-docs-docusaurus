import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import Translate from '@docusaurus/Translate';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro">
            <Translate id="homepage.button.docs">ドキュメントを見る</Translate>
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description={siteConfig.tagline}>
      <HomepageHeader />
      <main className="container margin-vert--lg">
        <div className="row">
          <div className="col col--4">
            <Heading as="h3"><Translate id="homepage.adr.title">ADR</Translate></Heading>
            <p><Translate id="homepage.adr.description">アーキテクチャの意思決定を記録します。</Translate></p>
            <Link to="/docs/adr/template"><Translate id="homepage.link.details">詳細を見る →</Translate></Link>
          </div>
          <div className="col col--4">
            <Heading as="h3"><Translate id="homepage.architecture.title">アーキテクチャ</Translate></Heading>
            <p><Translate id="homepage.architecture.description">システム全体の構造と設計を説明します。</Translate></p>
            <Link to="/docs/architecture/overview"><Translate id="homepage.link.details">詳細を見る →</Translate></Link>
          </div>
          <div className="col col--4">
            <Heading as="h3"><Translate id="homepage.guides.title">ガイド</Translate></Heading>
            <p><Translate id="homepage.guides.description">開発者向けの手順書やベストプラクティス。</Translate></p>
            <Link to="/docs/guides/getting-started"><Translate id="homepage.link.details">詳細を見る →</Translate></Link>
          </div>
        </div>
      </main>
    </Layout>
  );
}
