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

app.use((err, _req, res, _next) => {
  console.error(err.stack || err);
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';
  res.status(status).json({ error: message });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`API server running on port ${PORT}`);
});

module.exports = app;
