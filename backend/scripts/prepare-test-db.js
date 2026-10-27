import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { testDatabaseSchema, testDatabaseUrl } from './testDatabase.js';

const rootDirectory = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const prismaCli = path.join(rootDirectory, 'node_modules', 'prisma', 'build', 'index.js');

// Recrea el esquema de pruebas desde cero.
const resetSql = `DROP SCHEMA IF EXISTS "${testDatabaseSchema}" CASCADE; CREATE SCHEMA "${testDatabaseSchema}";`;

execFileSync(process.execPath, [prismaCli, 'db', 'execute', '--stdin', '--url', testDatabaseUrl], {
  cwd: rootDirectory,
  input: resetSql,
  stdio: ['pipe', 'inherit', 'inherit'],
});

execFileSync(process.execPath, [prismaCli, 'migrate', 'deploy'], {
  cwd: rootDirectory,
  stdio: 'inherit',
  env: { ...process.env, DATABASE_URL: testDatabaseUrl },
});
