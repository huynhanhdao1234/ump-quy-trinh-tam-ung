const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

router.get('/:id/history', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT * FROM lich_su_phe_duyet WHERE ho_so_id = $1 ORDER BY buoc, thoi_gian',
      [resolved.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/history', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { buoc, hanh_dong, ten_nguoi_xu_ly, ghi_chu } = req.body;
    const { rows } = await db.query(
      `INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        resolved.id,
        buoc,
        hanh_dong,
        req.user.id,
        ten_nguoi_xu_ly || req.user.ho_ten,
        ghi_chu || '',
      ]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.put('/:id/history', async (req, res, next) => {
  const client = await db.getClient();
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) {
      client.release();
      return res.status(404).json({ error: 'Hồ sơ không tồn tại' });
    }

    const { entries } = req.body;

    await client.query('BEGIN');
    await client.query('DELETE FROM lich_su_phe_duyet WHERE ho_so_id = $1', [resolved.id]);

    if (entries && entries.length > 0) {
      const values = [];
      const placeholders = [];
      let idx = 1;

      for (const e of entries) {
        placeholders.push(`($${idx},$${idx+1},$${idx+2},$${idx+3},$${idx+4},$${idx+5})`);
        values.push(
          resolved.id,
          e.buoc || e.step,
          e.hanh_dong || e.action,
          req.user.id,
          e.ten_nguoi_xu_ly || e.user || req.user.ho_ten,
          e.ghi_chu || e.note || ''
        );
        idx += 6;
      }

      await client.query(
        `INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu)
         VALUES ${placeholders.join(',')}`,
        values
      );
    }

    await client.query('COMMIT');
    res.json({ success: true });
  } catch (err) {
    await client.query('ROLLBACK');
    next(err);
  } finally {
    client.release();
  }
});

module.exports = router;
