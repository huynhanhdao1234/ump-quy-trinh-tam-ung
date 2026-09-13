const router = require('express').Router();
const db = require('../db');
const { authenticate, requireRole } = require('../middleware/auth');

router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT * FROM don_vi WHERE active = true ORDER BY ma_don_vi'
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const resolved = await db.resolveUnitId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Không tìm thấy đơn vị' });

    const { rows } = await db.query('SELECT * FROM don_vi WHERE id = $1', [resolved.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy đơn vị' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.post('/', requireRole('chu_tich'), async (req, res, next) => {
  try {
    const { ma_don_vi, ten_don_vi, loai_don_vi, so_doan_vien } = req.body;
    const { rows } = await db.query(
      `INSERT INTO don_vi (ma_don_vi, ten_don_vi, loai_don_vi, so_doan_vien)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [ma_don_vi, ten_don_vi, loai_don_vi || 'CDBP', so_doan_vien || 0]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', requireRole('chu_tich'), async (req, res, next) => {
  try {
    const resolved = await db.resolveUnitId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Không tìm thấy đơn vị' });

    const { ma_don_vi, ten_don_vi, loai_don_vi, so_doan_vien } = req.body;
    await db.query(
      `UPDATE don_vi SET
         ma_don_vi = COALESCE($1, ma_don_vi),
         ten_don_vi = COALESCE($2, ten_don_vi),
         loai_don_vi = COALESCE($3, loai_don_vi),
         so_doan_vien = COALESCE($4, so_doan_vien)
       WHERE id = $5`,
      [ma_don_vi, ten_don_vi, loai_don_vi, so_doan_vien, resolved.id]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
