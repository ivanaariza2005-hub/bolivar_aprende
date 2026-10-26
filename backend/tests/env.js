import { testDatabaseUrl } from '../scripts/testDatabase.js';

process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = testDatabaseUrl;
process.env.JWT_SECRET = 'test-secret-key-with-at-least-32-characters-0123456789';
process.env.JWT_EXPIRES_IN = '1h';
process.env.LOG_LEVEL = 'silent';
process.env.CORS_ORIGINS = '*';
