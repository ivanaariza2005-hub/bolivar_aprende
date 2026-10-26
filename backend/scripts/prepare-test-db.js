import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { testDatabasePath, testDatabaseUrl } from './testDatabase.js';

const rootDirectory = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const prismaCli = path.join(rootDirectory, 'node_modules', 'prisma', 'build', 'index.js');

fs.rmSync(testDatabasePath, { force: true });

execFileSync(process.execPath, [prismaCli, 'migrate', 'deploy'], {
  cwd: rootDirectory,
  stdio: 'inherit',
  env: { ...process.env, DATABASE_URL: testDatabaseUrl },
});
