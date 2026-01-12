---
sidebar_position: 11
---

# ミドルウェア設計書

## 基本情報

| 項目 | 内容 |
|------|------|
| **機能名** | `[FeatureName]` |
| **作成日** | YYYY-MM-DD |
| **更新日** | YYYY-MM-DD |
| **担当者** | [担当者名] |

## 概要

ミドルウェアの設計方針と実装ガイドラインを説明します。

## ミドルウェアチェーン

### 実行順序

```mermaid
flowchart LR
    subgraph Request["リクエスト処理"]
        R1[Request ID] --> R2[Logger]
        R2 --> R3[CORS]
        R3 --> R4[Security Headers]
        R4 --> R5[Rate Limit]
        R5 --> R6[Body Parser]
        R6 --> R7[Authentication]
        R7 --> R8[Authorization]
        R8 --> R9[Validation]
        R9 --> R10[Handler]
    end

    subgraph Response["レスポンス処理"]
        R10 --> S1[Response Transform]
        S1 --> S2[Error Handler]
        S2 --> S3[Response Logger]
    end
```

### 設定例

```typescript
// app.ts
import express from 'express';

const app = express();

// 1. Request ID
app.use(requestIdMiddleware);

// 2. Logger
app.use(httpLogger);

// 3. CORS
app.use(cors(corsOptions));

// 4. Security Headers
app.use(helmet(helmetOptions));

// 5. Rate Limit
app.use(rateLimiter);

// 6. Body Parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 7. Routes (認証・認可・バリデーションはルート単位)
app.use('/api/v1', apiRoutes);

// 8. 404 Handler
app.use(notFoundHandler);

// 9. Error Handler
app.use(errorHandler);
```

## リクエストIDミドルウェア

```typescript
// middlewares/requestId.ts
import { v4 as uuidv4 } from 'uuid';
import { AsyncLocalStorage } from 'async_hooks';

export const requestContext = new AsyncLocalStorage<{ requestId: string }>();

export function requestIdMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const requestId = (req.headers['x-request-id'] as string) || `req_${uuidv4()}`;

  req.id = requestId;
  res.setHeader('X-Request-ID', requestId);

  requestContext.run({ requestId }, () => {
    next();
  });
}

// ユーティリティ
export function getRequestId(): string | undefined {
  return requestContext.getStore()?.requestId;
}
```

## 認証ミドルウェア

### JWT認証

```typescript
// middlewares/auth.ts
import jwt from 'jsonwebtoken';

export interface AuthenticatedUser {
  id: string;
  email: string;
  roles: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

export function authenticate(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    res.status(401).json({
      error: {
        code: 'UNAUTHORIZED',
        message: '認証が必要です',
        requestId: req.id,
        timestamp: new Date().toISOString(),
      },
    });
    return;
  }

  const token = authHeader.slice(7);

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as jwt.JwtPayload;

    req.user = {
      id: payload.sub!,
      email: payload.email,
      roles: payload.roles || [],
    };

    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        error: {
          code: 'TOKEN_EXPIRED',
          message: 'トークンの有効期限が切れています',
          requestId: req.id,
          timestamp: new Date().toISOString(),
        },
      });
      return;
    }

    res.status(401).json({
      error: {
        code: 'INVALID_TOKEN',
        message: '無効なトークンです',
        requestId: req.id,
        timestamp: new Date().toISOString(),
      },
    });
  }
}

// オプショナル認証（認証なしでもアクセス可能）
export function optionalAuth(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return next();
  }

  const token = authHeader.slice(7);

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as jwt.JwtPayload;
    req.user = {
      id: payload.sub!,
      email: payload.email,
      roles: payload.roles || [],
    };
  } catch {
    // 認証失敗は無視
  }

  next();
}
```

## 認可ミドルウェア

### ロールベース認可

```typescript
// middlewares/authorize.ts
type Permission = string;

const rolePermissions: Record<string, Permission[]> = {
  admin: ['*'],
  manager: ['users:read', 'resources:*'],
  user: ['resources:read', 'resources:create', 'resources:update:own'],
};

function hasPermission(roles: string[], required: Permission): boolean {
  for (const role of roles) {
    const permissions = rolePermissions[role] || [];

    for (const permission of permissions) {
      if (permission === '*') return true;
      if (permission === required) return true;

      // ワイルドカードマッチング（例: resources:*）
      if (permission.endsWith(':*')) {
        const prefix = permission.slice(0, -1);
        if (required.startsWith(prefix)) return true;
      }
    }
  }

  return false;
}

export function authorize(permission: Permission) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: '認証が必要です',
          requestId: req.id,
          timestamp: new Date().toISOString(),
        },
      });
      return;
    }

    if (!hasPermission(req.user.roles, permission)) {
      res.status(403).json({
        error: {
          code: 'FORBIDDEN',
          message: 'この操作を行う権限がありません',
          requestId: req.id,
          timestamp: new Date().toISOString(),
        },
      });
      return;
    }

    next();
  };
}

// リソース所有者チェック
export function authorizeOwner(getResourceOwnerId: (req: Request) => Promise<string>) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    if (!req.user) {
      res.status(401).json({
        error: { code: 'UNAUTHORIZED', message: '認証が必要です' },
      });
      return;
    }

    // 管理者はすべてのリソースにアクセス可能
    if (req.user.roles.includes('admin')) {
      return next();
    }

    const ownerId = await getResourceOwnerId(req);
    if (ownerId !== req.user.id) {
      res.status(403).json({
        error: { code: 'FORBIDDEN', message: 'このリソースにアクセスする権限がありません' },
      });
      return;
    }

    next();
  };
}
```

## バリデーションミドルウェア

```typescript
// middlewares/validate.ts
import { z, ZodSchema, ZodError } from 'zod';

export function validate<T extends ZodSchema>(schema: T) {
  return async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const validated = await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });

      req.validated = validated;
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const details = error.errors.map((err) => ({
          field: err.path.join('.'),
          code: err.code.toUpperCase(),
          message: err.message,
        }));

        res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: '入力値が不正です',
            details,
            requestId: req.id,
            timestamp: new Date().toISOString(),
          },
        });
        return;
      }

      next(error);
    }
  };
}
```

## エラーハンドリングミドルウェア

```typescript
// middlewares/errorHandler.ts
export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  const requestId = req.id || 'unknown';

  // ApplicationError の場合
  if (error instanceof ApplicationError) {
    if (error.statusCode >= 500) {
      logger.error({
        error: error.toJSON(),
        stack: error.stack,
        requestId,
      });
    } else {
      logger.warn({
        error: error.toJSON(),
        requestId,
      });
    }

    res.status(error.statusCode).json({
      error: {
        ...error.toJSON(),
        requestId,
      },
    });
    return;
  }

  // 予期しないエラー
  logger.error({
    type: 'unhandled_error',
    error: error.message,
    stack: error.stack,
    requestId,
  });

  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: '予期しないエラーが発生しました',
      requestId,
      timestamp: new Date().toISOString(),
    },
  });
}

// 404 Handler
export function notFoundHandler(
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: `${req.method} ${req.path} が見つかりません`,
      requestId: req.id,
      timestamp: new Date().toISOString(),
    },
  });
}
```

## ロギングミドルウェア

```typescript
// middlewares/logger.ts
import pino from 'pino-http';

export const httpLogger = pino({
  logger,
  genReqId: (req) => req.id,
  customLogLevel: (req, res, error) => {
    if (res.statusCode >= 500 || error) return 'error';
    if (res.statusCode >= 400) return 'warn';
    return 'info';
  },
  serializers: {
    req: (req) => ({
      method: req.method,
      url: req.url,
      headers: {
        'user-agent': req.headers['user-agent'],
      },
    }),
    res: (res) => ({
      statusCode: res.statusCode,
    }),
  },
});
```

## ミドルウェア組み合わせ例

### ルート定義

```typescript
// routes/users.ts
import { Router } from 'express';

const router = Router();

// 認証不要
router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);

// 認証必要
router.use(authenticate);

router.get('/me', getCurrentUser);
router.put('/me', validate(updateUserSchema), updateCurrentUser);

// 管理者のみ
router.get('/', authorize('users:read'), getUsers);
router.delete('/:id', authorize('users:delete'), deleteUser);

export { router as userRouter };
```

## 関連ドキュメント

- [認証・認可設計](./authentication-design)
- [バリデーション設計](./validation-design)
- [エラーハンドリング](./error-handling)
- [ロギング設計](./logging-design)

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0.0 | YYYY-MM-DD | 初版作成 |
