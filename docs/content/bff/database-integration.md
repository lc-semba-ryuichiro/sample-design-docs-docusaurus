---
sidebar_position: 9
---

# データベース統合設計書

## 基本情報

| 項目 | 内容 |
|------|------|
| **機能名** | `[FeatureName]` |
| **作成日** | YYYY-MM-DD |
| **更新日** | YYYY-MM-DD |
| **担当者** | [担当者名] |

## 概要

データベース統合の設計方針と実装ガイドラインを説明します。

## アーキテクチャ

### データベース接続構成

```mermaid
graph TD
    subgraph Application["Application Layer"]
        Repository[Repositories]
        ORM[ORM<br/>Prisma/Drizzle]
    end

    subgraph Connection["Connection Layer"]
        Pool[Connection Pool]
        ReadReplica[Read Replica Router]
    end

    subgraph Database["Database Layer"]
        Primary[(Primary DB)]
        Replica1[(Replica 1)]
        Replica2[(Replica 2)]
    end

    Repository --> ORM
    ORM --> Pool
    Pool --> ReadReplica
    ReadReplica -->|Write| Primary
    ReadReplica -->|Read| Replica1
    ReadReplica -->|Read| Replica2
    Primary -->|Replication| Replica1
    Primary -->|Replication| Replica2
```

## ORM設定

### Prisma設定

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
  previewFeatures = ["fullTextSearch"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  password  String
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@index([createdAt])
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([published, createdAt])
}

enum Role {
  USER
  ADMIN
}
```

### Prismaクライアント初期化

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? ['query', 'info', 'warn', 'error']
        : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

## コネクションプール

### プール設定

| 設定 | 開発環境 | 本番環境 | 説明 |
|------|---------|---------|------|
| connection_limit | 5 | 20 | 最大接続数 |
| pool_timeout | 10s | 30s | プールタイムアウト |
| connect_timeout | 5s | 10s | 接続タイムアウト |
| idle_timeout | 60s | 300s | アイドルタイムアウト |

### 接続文字列

```
postgresql://user:password@host:5432/database?connection_limit=20&pool_timeout=30
```

## リポジトリパターン

### 基本リポジトリ

```typescript
// repositories/base.repository.ts
export abstract class BaseRepository<T, CreateInput, UpdateInput> {
  constructor(protected prisma: PrismaClient) {}

  abstract findById(id: string): Promise<T | null>;
  abstract findMany(options?: FindManyOptions): Promise<T[]>;
  abstract create(data: CreateInput): Promise<T>;
  abstract update(id: string, data: UpdateInput): Promise<T>;
  abstract delete(id: string): Promise<void>;
}

interface FindManyOptions {
  page?: number;
  limit?: number;
  orderBy?: Record<string, 'asc' | 'desc'>;
  where?: Record<string, unknown>;
}
```

### ユーザーリポジトリ

```typescript
// repositories/user.repository.ts
import { User, Prisma } from '@prisma/client';

export class UserRepository extends BaseRepository<
  User,
  Prisma.UserCreateInput,
  Prisma.UserUpdateInput
> {
  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findMany(options: FindManyOptions = {}): Promise<User[]> {
    const { page = 1, limit = 20, orderBy = { createdAt: 'desc' }, where } = options;

    return this.prisma.user.findMany({
      where,
      orderBy,
      skip: (page - 1) * limit,
      take: limit,
    });
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return this.prisma.user.create({ data });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({
      where: { id },
    });
  }

  async existsByEmail(email: string): Promise<boolean> {
    const count = await this.prisma.user.count({
      where: { email },
    });
    return count > 0;
  }
}
```

## トランザクション

### トランザクション処理

```mermaid
sequenceDiagram
    participant Service
    participant Transaction
    participant UserRepo
    participant PostRepo
    participant DB

    Service->>Transaction: 開始
    Transaction->>DB: BEGIN
    Service->>UserRepo: create(user)
    UserRepo->>DB: INSERT
    DB-->>UserRepo: OK
    Service->>PostRepo: create(post)
    PostRepo->>DB: INSERT
    DB-->>PostRepo: OK
    Service->>Transaction: コミット
    Transaction->>DB: COMMIT
```

### 実装例

```typescript
// インタラクティブトランザクション
async function createUserWithPost(
  userData: Prisma.UserCreateInput,
  postData: Omit<Prisma.PostCreateInput, 'author'>
): Promise<User> {
  return prisma.$transaction(async (tx) => {
    // ユーザー作成
    const user = await tx.user.create({
      data: userData,
    });

    // 投稿作成
    await tx.post.create({
      data: {
        ...postData,
        author: { connect: { id: user.id } },
      },
    });

    return user;
  });
}

// トランザクションオプション
await prisma.$transaction(
  async (tx) => {
    // 処理
  },
  {
    maxWait: 5000, // 最大待機時間
    timeout: 10000, // タイムアウト
    isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
  }
);
```

## クエリ最適化

### N+1問題対策

```typescript
// ❌ N+1 問題
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { authorId: user.id },
  });
}

// ✅ Eager Loading
const users = await prisma.user.findMany({
  include: {
    posts: true,
  },
});

// ✅ 必要なフィールドのみ
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    posts: {
      select: {
        id: true,
        title: true,
      },
    },
  },
});
```

### インデックス設計

| テーブル | カラム | インデックス種別 | 用途 |
|---------|--------|----------------|------|
| users | email | UNIQUE | ログイン検索 |
| users | createdAt | B-tree | 一覧ソート |
| posts | authorId | B-tree | 外部キー |
| posts | (published, createdAt) | Composite | フィルタ + ソート |

## マイグレーション

### マイグレーション運用

```mermaid
flowchart LR
    A[開発] --> B[マイグレーション作成]
    B --> C[ローカルテスト]
    C --> D[ステージング適用]
    D --> E[本番適用]
```

### コマンド

```bash
# マイグレーション作成
npx prisma migrate dev --name add_user_table

# マイグレーション適用（本番）
npx prisma migrate deploy

# スキーマ生成（クライアント）
npx prisma generate

# データベースリセット（開発のみ）
npx prisma migrate reset
```

## エラーハンドリング

### Prismaエラー処理

```typescript
import { Prisma } from '@prisma/client';

async function handlePrismaError<T>(operation: () => Promise<T>): Promise<T> {
  try {
    return await operation();
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      switch (error.code) {
        case 'P2002':
          throw new ConflictError('この値は既に使用されています');
        case 'P2025':
          throw new NotFoundError('リソースが見つかりません');
        case 'P2003':
          throw new ValidationError('参照先が存在しません');
        default:
          throw new DatabaseError(`Database error: ${error.code}`);
      }
    }

    if (error instanceof Prisma.PrismaClientValidationError) {
      throw new ValidationError('入力値が不正です');
    }

    throw error;
  }
}
```

## 監視・ログ

### クエリログ

```typescript
const prisma = new PrismaClient({
  log: [
    { level: 'query', emit: 'event' },
    { level: 'error', emit: 'event' },
    { level: 'warn', emit: 'event' },
  ],
});

prisma.$on('query', (e) => {
  logger.debug({
    query: e.query,
    params: e.params,
    duration: e.duration,
  });
});

prisma.$on('error', (e) => {
  logger.error({ message: e.message });
});
```

## 関連ドキュメント

- [キャッシュ設計](./cache-design)
- [API設計](./api-design)

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0.0 | YYYY-MM-DD | 初版作成 |
