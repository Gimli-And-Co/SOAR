export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  enableAuth: process.env.AUTH == 'true',
  swagger: process.env.SWAGGER == 'true',
  database: {
    host: process.env.DB_HOST,
    username: process.env.DB_USERNAME,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PWD,
    port: process.env.DB_PORT || 5432,
  },
});
