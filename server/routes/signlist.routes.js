const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

router.get('/:id/signlist', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT * FROM ky_nhan_item WHERE ho_so_id = $1 ORDER BY stt',
      [resolved.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.put('/:id/signlist', async (req, res, next) => {
  const client = await db.getClient();
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) {
      client.release();
      return res.status(404).json({ error: 'Hồ sơ không tồn tại' });
    }

    const { items } = req.body;

    await client.query('BEGIN');
    await client.query('DELETE FROM ky_nhan_item WHERE ho_so_id = $1', [resolved.id]);

    if (items && items.length > 0) {
      const values = [];
      const placeholders = [];
      let idx = 1;

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        placeholders.push(`($${idx},$${idx+1},$${idx+2},$${idx+3},$${idx+4},$${idx+5})`);
        values.push(
          resolved.id,
          item.stt || i + 1,
          item.ho_ten || item.name || '',
          item.so_tien || item.amount || 0,
          item.so_ngay || item.days || 1,
          item.da_ky || item.signed || false
        );
        idx += 6;
      }

      await client.query(
        `INSERT INTO ky_nhan_item (ho_so_id, stt, ho_ten, so_tien, so_ngay, da_ky)
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
