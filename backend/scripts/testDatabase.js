import path from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDirectory = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export const testDatabasePath = path.join(rootDirectory, 'prisma', 'test.db');

export const testDatabaseUrl = `file:${testDatabasePath.replace(/\\/g, '/')}`;
