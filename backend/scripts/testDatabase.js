import 'dotenv/config';

// Las pruebas usan un esquema dedicado dentro de la misma base PostgreSQL,
// de modo que no tocan los datos de `public`.
const testSchema = 'test';

const withTestSchema = (rawUrl) => {
  const url = new URL(rawUrl);
  url.searchParams.set('schema', testSchema);
  return url.toString();
};

const baseUrl = process.env.TEST_DATABASE_URL ?? process.env.DATABASE_URL;

if (!baseUrl) {
  throw new Error(
    'Falta DATABASE_URL (o TEST_DATABASE_URL) para ejecutar las pruebas. Copia .env.example a .env.'
  );
}

export const testDatabaseSchema = testSchema;

export const testDatabaseUrl = withTestSchema(baseUrl);
