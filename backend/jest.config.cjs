module.exports = {
  testEnvironment: 'node',
  setupFiles: ['<rootDir>/tests/env.js'],
  testMatch: ['<rootDir>/tests/**/*.test.js'],
  transform: {},
  verbose: true,
  clearMocks: true,
  // Las pruebas corren contra PostgreSQL en Supabase (esquema `test`), así que
  // cada consulta cuesta cientos de milisegundos de red. El valor por defecto
  // de 5 s no alcanza para los hooks que resetean la base y autentican.
  testTimeout: 30000,
};
