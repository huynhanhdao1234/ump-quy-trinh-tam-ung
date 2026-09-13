const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

router.get('/:id/estimates', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT * FROM du_tru_item WHERE ho_so_id = $1 ORDER BY stt',
      [resolved.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.put('/:id/estimates', async (req, res, next) => {
  const client = await db.getClient();
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) {
      client.release();
      return res.status(404).json({ error: 'Hồ sơ không tồn tại' });
    }

    const { items } = req.body;

    await client.query('BEGIN');
    await client.query('DELETE FROM du_tru_item WHERE ho_so_id = $1', [resolved.id]);

    if (items && items.length > 0) {
      const values = [];
      const placeholders = [];
      let idx = 1;

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        placeholders.push(`($${idx},$${idx+1},$${idx+2},$${idx+3},$${idx+4},$${idx+5},$${idx+6})`);
        values.push(
          resolved.id,
          item.stt || i + 1,
          item.noi_dung || item.content || '',
          item.don_gia || item.price || 0,
          item.so_luong || item.quantity || 1,
          item.don_vi_tinh || item.unit || 'Cái',
          item.ghi_chu || item.note || ''
        );
        idx += 7;
      }

      await client.query(
        `INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu)
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
