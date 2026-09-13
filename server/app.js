require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/users', require('./routes/users.routes'));
app.use('/api/units', require('./routes/units.routes'));
app.use('/api/requests', require('./routes/requests.routes'));
app.use('/api/requests', require('./routes/estimates.routes'));
app.use('/api/requests', require('./routes/signlist.routes'));
app.use('/api/requests', require('./routes/payments.routes'));
app.use('/api/requests', require('./routes/history.routes'));
app.use('/api/requests', require('./routes/files.routes'));
app.use('/api/payments', require('./routes/payments.routes'));
app.use('/api/notifications', require('./routes/notifications.routes'));
app.use('/api/workflow', require('./routes/workflow.routes'));
app.use('/api/rpc', require('./routes/workflow.routes'));
app.use('/api/config', require('./routes/config.routes'));
app.use('/api/files', require('./routes/files.routes'));
app.use('/api/ai', require('./routes/ai.routes'));

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const fs = require('fs');
const clientDistDocker = path.join(__dirname, 'client-dist');
const clientDistLocal = path.join(__dirname, '..', 'client', 'dist');
const clientDist = fs.existsSync(clientDistDocker) ? clientDistDocker : clientDistLocal;
app.use(express.static(clientDist));
app.get(/^\/(?!api\/).*/, (_req, res) => {
  res.sendFile(path.join(clientDist, 'index.html'));
});

app.use((err, _req, res, _next) => {
  console.error(err.stack || err);
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';
  res.status(status).json({ error: message });
});

async function autoInitDb() {
  const { pool } = require('./db');
  try {
    const { rows } = await pool.query("SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles')");
    if (rows[0].exists) return;
    console.log('Database empty, running init.sql...');
    const initSql = path.join(__dirname, 'init.sql');
    const fallback = path.join(__dirname, '..', 'db', 'init.sql');
    const sqlPath = fs.existsSync(initSql) ? initSql : fallback;
    if (!fs.existsSync(sqlPath)) { console.warn('init.sql not found, skipping'); return; }
    await pool.query(fs.readFileSync(sqlPath, 'utf8'));
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Auto-init DB error:', err.message);
  }
}

app.listen(PORT, '0.0.0.0', async () => {
  console.log(`API server running on port ${PORT}`);
  await autoInitDb();
});

module.exports = app;
