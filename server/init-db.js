const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

async function initDb() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    console.error('DATABASE_URL not set');
    process.exit(1);
  }

  const pool = new Pool({
    connectionString,
    ssl: process.env.DB_SSL === 'false' ? false : { rejectUnauthorized: false },
  });

  const sqlPath = path.join(__dirname, 'init.sql');
  if (!fs.existsSync(sqlPath)) {
    console.error('init.sql not found at', sqlPath);
    process.exit(1);
  }

  const sql = fs.readFileSync(sqlPath, 'utf8');

  try {
    console.log('Initializing database...');
    await pool.query(sql);
    console.log('Database initialized successfully');
  } catch (err) {
    if (err.message?.includes('already exists')) {
      console.log('Database already initialized, skipping');
    } else {
      console.error('Database init error:', err.message);
      process.exit(1);
    }
  } finally {
    await pool.end();
  }
}

initDb();
