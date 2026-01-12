---
sidebar_position: 7
---

# Logging Design Document

## Basic Information

| Item | Content |
|------|---------|
| **Feature Name** | `[FeatureName]` |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |
| **Author** | [Author Name] |

## Overview

Describes the design principles and implementation guidelines for log output.

## Log Architecture

### Log Flow

```mermaid
graph LR
    App[Application] --> Logger[Logger<br/>Pino/Winston]
    Logger --> Stdout[Stdout/Stderr]
    Stdout --> Collector[Log Collector<br/>Fluentd]
    Collector --> Storage[Log Storage<br/>Elasticsearch]
    Storage --> Kibana[Visualization<br/>Kibana]
```

## Log Levels

### Level Definitions

| Level | Value | Use | Example |
|-------|-------|-----|---------|
| fatal | 60 | Critical error | System down |
| error | 50 | Error | Exception, processing failure |
| warn | 40 | Warning | Deprecation, retry |
| info | 30 | Information | Request start/end |
| debug | 20 | Debug | Detailed processing info |
| trace | 10 | Trace | Function calls |

### Environment-specific Settings

| Environment | Default Level | Output Target |
|-------------|---------------|---------------|
| development | debug | stdout (pretty) |
| staging | info | stdout (JSON) |
| production | info | stdout (JSON) |

## Structured Logging

### Log Format

```typescript
interface LogEntry {
  // Basic information
  level: string;
  time: string;
  msg: string;

  // Request information
  requestId?: string;
  method?: string;
  path?: string;
  statusCode?: number;
  responseTime?: number;

  // User information
  userId?: string;

  // Error information
  err?: {
    type: string;
    message: string;
    stack?: string;
  };

  // Custom fields
  [key: string]: unknown;
}
```

### Log Output Example

```json
{
  "level": "info",
  "time": "2024-01-01T00:00:00.000Z",
  "msg": "Request completed",
  "requestId": "req_abc123",
  "method": "POST",
  "path": "/api/v1/users",
  "statusCode": 201,
  "responseTime": 150,
  "userId": "user_xyz789"
}
```

## Logger Configuration

### Pino Configuration

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: {
    paths: ['req.headers.authorization', 'req.body.password', 'res.headers["set-cookie"]'],
    censor: '[REDACTED]',
  },
  transport:
    process.env.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'SYS:standard',
          },
        }
      : undefined,
});

export { logger };
```

### Child Loggers

```typescript
// Logger with context
function createContextLogger(context: Record<string, unknown>) {
  return logger.child(context);
}

// Usage example
const userLogger = createContextLogger({ service: 'user-service' });
userLogger.info({ userId: '123' }, 'User created');
```

## Correlation ID

### Request ID Generation

```mermaid
sequenceDiagram
    participant Client
    participant BFF
    participant Service1
    participant Service2

    Note over Client,Service2: X-Request-ID: req_abc123

    Client->>BFF: Request
    BFF->>BFF: Generate/Use Request ID
    BFF->>Service1: Request (X-Request-ID)
    BFF->>Service2: Request (X-Request-ID)
    Service1-->>BFF: Response
    Service2-->>BFF: Response
    BFF-->>Client: Response
```

### Middleware Implementation

```typescript
import { v4 as uuidv4 } from 'uuid';
import { AsyncLocalStorage } from 'async_hooks';

// Manage request context with AsyncLocalStorage
const requestContext = new AsyncLocalStorage<{ requestId: string }>();

export function requestIdMiddleware(req: Request, res: Response, next: NextFunction) {
  // Use existing request ID or generate new one
  const requestId = req.headers['x-request-id'] as string || `req_${uuidv4()}`;

  // Set in response header
  res.setHeader('X-Request-ID', requestId);

  // Set on request object
  req.id = requestId;

  // Store in AsyncLocalStorage
  requestContext.run({ requestId }, () => {
    next();
  });
}

// Get request ID from anywhere
export function getRequestId(): string | undefined {
  return requestContext.getStore()?.requestId;
}

// Auto-attach request ID to logger
export function getContextLogger() {
  const requestId = getRequestId();
  return requestId ? logger.child({ requestId }) : logger;
}
```

## Access Logs

### HTTP Request Logs

```typescript
import pinoHttp from 'pino-http';

const httpLogger = pinoHttp({
  logger,
  genReqId: (req) => req.id || `req_${uuidv4()}`,
  customSuccessMessage: (req, res) => {
    return `${req.method} ${req.url} ${res.statusCode}`;
  },
  customErrorMessage: (req, res, err) => {
    return `${req.method} ${req.url} ${res.statusCode} - ${err.message}`;
  },
  customAttributeKeys: {
    req: 'request',
    res: 'response',
    err: 'error',
    responseTime: 'responseTime',
  },
  serializers: {
    req: (req) => ({
      method: req.method,
      url: req.url,
      query: req.query,
      headers: {
        'user-agent': req.headers['user-agent'],
        'content-type': req.headers['content-type'],
      },
    }),
    res: (res) => ({
      statusCode: res.statusCode,
    }),
  },
});

app.use(httpLogger);
```

## Audit Logs

### Audit Target Actions

| Action | Log Level | Required Fields |
|--------|-----------|-----------------|
| User created | info | userId, email |
| Login success | info | userId, ipAddress |
| Login failure | warn | email, ipAddress, reason |
| Permission change | info | userId, oldRole, newRole |
| Data deletion | info | userId, resourceType, resourceId |

### Audit Log Implementation

```typescript
interface AuditLog {
  timestamp: string;
  action: string;
  actorId: string;
  actorType: 'user' | 'system';
  resourceType: string;
  resourceId?: string;
  details: Record<string, unknown>;
  ipAddress: string;
  userAgent: string;
  result: 'success' | 'failure';
}

class AuditLogger {
  private logger = createContextLogger({ type: 'audit' });

  log(audit: Omit<AuditLog, 'timestamp'>) {
    this.logger.info({
      ...audit,
      timestamp: new Date().toISOString(),
    });
  }

  userCreated(actorId: string, userId: string, email: string, req: Request) {
    this.log({
      action: 'USER_CREATED',
      actorId,
      actorType: 'user',
      resourceType: 'user',
      resourceId: userId,
      details: { email },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || '',
      result: 'success',
    });
  }

  loginAttempt(email: string, success: boolean, req: Request, userId?: string) {
    this.log({
      action: success ? 'LOGIN_SUCCESS' : 'LOGIN_FAILURE',
      actorId: userId || 'anonymous',
      actorType: 'user',
      resourceType: 'session',
      details: { email },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || '',
      result: success ? 'success' : 'failure',
    });
  }
}

export const auditLogger = new AuditLogger();
```

## Performance Logs

### Processing Time Measurement

```typescript
class PerformanceLogger {
  private logger = createContextLogger({ type: 'performance' });

  measure<T>(name: string, operation: () => Promise<T>): Promise<T>;
  measure<T>(name: string, operation: () => T): T;
  measure<T>(name: string, operation: () => T | Promise<T>): T | Promise<T> {
    const start = performance.now();

    const result = operation();

    if (result instanceof Promise) {
      return result.finally(() => {
        this.logDuration(name, start);
      });
    }

    this.logDuration(name, start);
    return result;
  }

  private logDuration(name: string, start: number) {
    const duration = performance.now() - start;
    this.logger.info({ operation: name, duration }, `${name} completed in ${duration.toFixed(2)}ms`);
  }
}

export const perfLogger = new PerformanceLogger();

// Usage example
const result = await perfLogger.measure('fetchUsers', async () => {
  return await userRepository.findAll();
});
```

## Sensitive Information Masking

### Masking Targets

| Field | Masking Method |
|-------|----------------|
| password | Full mask |
| token | Full mask |
| creditCard | Mask except last 4 digits |
| email | Partial mask (`te***@example.com`) |
| phone | Partial mask (`090-****-1234`) |

### Masking Implementation

```typescript
const sensitiveFields = ['password', 'token', 'secret', 'authorization'];

function maskSensitiveData(obj: unknown, depth = 0): unknown {
  if (depth > 10) return obj; // Depth limit

  if (obj === null || obj === undefined) return obj;

  if (typeof obj === 'object') {
    if (Array.isArray(obj)) {
      return obj.map((item) => maskSensitiveData(item, depth + 1));
    }

    const masked: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(obj)) {
      if (sensitiveFields.some((field) => key.toLowerCase().includes(field))) {
        masked[key] = '[REDACTED]';
      } else {
        masked[key] = maskSensitiveData(value, depth + 1);
      }
    }
    return masked;
  }

  return obj;
}
```

## Log Rotation

### Configuration Example (PM2)

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'bff',
    script: 'dist/main.js',
    error_file: '/var/log/bff/error.log',
    out_file: '/var/log/bff/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_size: '100M',
    retain: '7',
  }],
};
```

## Related Documents

- [Error Handling](./error-handling)
- [Middleware Design](./middleware-design)
- [Security Design](./security-design)

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | YYYY-MM-DD | Initial release |
