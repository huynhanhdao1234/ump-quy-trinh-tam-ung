const router = require('express').Router();
const db = require('../db');
const { authenticate, requireRole } = require('../middleware/auth');

router.use(authenticate);

router.get('/sla', async (req, res, next) => {
  try {
    const { rows } = await db.query("SELECT * FROM cau_hinh WHERE id LIKE 'SLA%'");
    const result = {};
    for (const row of rows) {
      const stepKey = row.id.replace('SLA_STEP', 'step');
      result[stepKey] = JSON.parse(row.gia_tri);
    }
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.put('/sla', requireRole('chu_tich'), async (req, res, next) => {
  const client = await db.getClient();
  try {
    const sla = req.body;
    const steps = [
      { id: 'SLA_STEP2', ten: 'Tiếp nhận hồ sơ', val: sla.step2 },
      { id: 'SLA_STEP3', ten: 'Kiểm tra hợp lệ', val: sla.step3 },
      { id: 'SLA_STEP4', ten: 'Phê duyệt', val: sla.step4 },
      { id: 'SLA_STEP5', ten: 'Chi tạm ứng', val: sla.step5 },
      { id: 'SLA_STEP6', ten: 'Lưu hồ sơ', val: sla.step6 },
    ];

    await client.query('BEGIN');
    for (const s of steps) {
      if (s.val == null) continue;
      await client.query(
        `INSERT INTO cau_hinh (id, ten, gia_tri, mo_ta)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (id) DO UPDATE SET
           gia_tri = EXCLUDED.gia_tri`,
        [s.id, s.ten, JSON.stringify(s.val), '']
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
