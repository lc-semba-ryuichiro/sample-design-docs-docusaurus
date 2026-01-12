---
sidebar_position: 9
---

# Database Integration Design Document

## Basic Information

| Item | Content |
|------|---------|
| **Feature Name** | `[FeatureName]` |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |
| **Author** | [Author Name] |

## Overview

Describes the design principles and implementation guidelines for database integration.

## Architecture

### Database Connection Structure

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

## ORM Configuration

### Prisma Configuration

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

### Prisma Client Initialization

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

## Connection Pool

### Pool Settings

| Setting | Development | Production | Description |
|---------|-------------|------------|-------------|
| connection_limit | 5 | 20 | Max connections |
| pool_timeout | 10s | 30s | Pool timeout |
| connect_timeout | 5s | 10s | Connection timeout |
| idle_timeout | 60s | 300s | Idle timeout |

### Connection String

```
postgresql://user:password@host:5432/database?connection_limit=20&pool_timeout=30
```

## Repository Pattern

### Base Repository

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

### User Repository

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

## Transactions

### Transaction Processing

```mermaid
sequenceDiagram
    participant Service
    participant Transaction
    participant UserRepo
    participant PostRepo
    participant DB

    Service->>Transaction: Begin
    Transaction->>DB: BEGIN
    Service->>UserRepo: create(user)
    UserRepo->>DB: INSERT
    DB-->>UserRepo: OK
    Service->>PostRepo: create(post)
    PostRepo->>DB: INSERT
    DB-->>PostRepo: OK
    Service->>Transaction: Commit
    Transaction->>DB: COMMIT
```

### Implementation Example

```typescript
// Interactive transaction
async function createUserWithPost(
  userData: Prisma.UserCreateInput,
  postData: Omit<Prisma.PostCreateInput, 'author'>
): Promise<User> {
  return prisma.$transaction(async (tx) => {
    // Create user
    const user = await tx.user.create({
      data: userData,
    });

    // Create post
    await tx.post.create({
      data: {
        ...postData,
        author: { connect: { id: user.id } },
      },
    });

    return user;
  });
}

// Transaction options
await prisma.$transaction(
  async (tx) => {
    // Processing
  },
  {
    maxWait: 5000, // Max wait time
    timeout: 10000, // Timeout
    isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
  }
);
```

## Query Optimization

### N+1 Problem Prevention

```typescript
// ❌ N+1 problem
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

// ✅ Select only needed fields
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

### Index Design

| Table | Column | Index Type | Use Case |
|-------|--------|------------|----------|
| users | email | UNIQUE | Login lookup |
| users | createdAt | B-tree | List sorting |
| posts | authorId | B-tree | Foreign key |
| posts | (published, createdAt) | Composite | Filter + sort |

## Migrations

### Migration Workflow

```mermaid
flowchart LR
    A[Development] --> B[Create Migration]
    B --> C[Local Test]
    C --> D[Apply to Staging]
    D --> E[Apply to Production]
```

### Commands

```bash
# Create migration
npx prisma migrate dev --name add_user_table

# Apply migration (production)
npx prisma migrate deploy

# Generate schema (client)
npx prisma generate

# Reset database (development only)
npx prisma migrate reset
```

## Error Handling

### Prisma Error Handling

```typescript
import { Prisma } from '@prisma/client';

async function handlePrismaError<T>(operation: () => Promise<T>): Promise<T> {
  try {
    return await operation();
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      switch (error.code) {
        case 'P2002':
          throw new ConflictError('This value is already in use');
        case 'P2025':
          throw new NotFoundError('Resource not found');
        case 'P2003':
          throw new ValidationError('Referenced resource does not exist');
        default:
          throw new DatabaseError(`Database error: ${error.code}`);
      }
    }

    if (error instanceof Prisma.PrismaClientValidationError) {
      throw new ValidationError('Invalid input');
    }

    throw error;
  }
}
```

## Monitoring & Logging

### Query Logging

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

## Related Documents

- [Cache Design](./cache-design)
- [API Design](./api-design)

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | YYYY-MM-DD | Initial release |
