const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT * FROM thong_bao ORDER BY created_at DESC'
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.get('/mine', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM thong_bao
       WHERE gui_den_id = $1 OR gui_den_vai_tro = $2
       ORDER BY created_at DESC`,
      [req.user.id, req.user.vai_tro]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.get('/unread-count', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT COUNT(*)::int AS count FROM thong_bao
       WHERE da_doc = false AND (gui_den_id = $1 OR gui_den_vai_tro = $2)`,
      [req.user.id, req.user.vai_tro]
    );
    res.json({ count: rows[0].count });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { ho_so_id, noi_dung, gui_den_id, gui_den_vai_tro } = req.body;

    let resolvedHoSoId = ho_so_id || null;
    if (req.body.requestId && !resolvedHoSoId) {
      const resolved = await db.resolveRequestId(req.body.requestId);
      if (resolved) resolvedHoSoId = resolved.id;
    }

    const { rows } = await db.query(
      `INSERT INTO thong_bao (ho_so_id, noi_dung, gui_den_id, gui_den_vai_tro, da_doc)
       VALUES ($1, $2, $3, $4, false)
       RETURNING *`,
      [resolvedHoSoId, noi_dung, gui_den_id || null, gui_den_vai_tro || null]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.put('/read-all', async (req, res, next) => {
  try {
    await db.query(
      `UPDATE thong_bao SET da_doc = true
       WHERE da_doc = false AND (gui_den_id = $1 OR gui_den_vai_tro = $2)`,
      [req.user.id, req.user.vai_tro]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

router.put('/:id/read', async (req, res, next) => {
  try {
    await db.query('UPDATE thong_bao SET da_doc = true WHERE id = $1', [req.params.id]);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
