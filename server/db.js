const { Pool } = require('pg');

const poolConfig = process.env.DATABASE_URL
  ? { connectionString: process.env.DATABASE_URL, ssl: process.env.DB_SSL === 'false' ? false : { rejectUnauthorized: false } }
  : {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      database: process.env.DB_NAME || 'tam_ung',
      user: process.env.DB_USER || 'appuser',
      password: process.env.DB_PASSWORD || 'change_me',
    };

const pool = new Pool(poolConfig);

pool.on('error', (err) => {
  console.error('Unexpected pool error', err);
});

function query(text, params) {
  return pool.query(text, params);
}

async function getClient() {
  return pool.connect();
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function resolveRequestId(idOrCode) {
  const col = UUID_RE.test(idOrCode) ? 'id' : 'ma_ho_so';
  const { rows } = await query(
    `SELECT id, ma_ho_so FROM ho_so_tam_ung WHERE ${col} = $1`,
    [idOrCode]
  );
  return rows[0] || null;
}

async function resolveUnitId(idOrCode) {
  const col = UUID_RE.test(idOrCode) ? 'id' : 'ma_don_vi';
  const { rows } = await query(
    `SELECT id, ma_don_vi FROM don_vi WHERE ${col} = $1`,
    [idOrCode]
  );
  return rows[0] || null;
}

module.exports = { pool, query, getClient, resolveRequestId, resolveUnitId, UUID_RE };
