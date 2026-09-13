const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

router.post('/transition', async (req, res, next) => {
  try {
    const { hoSoId, hanhDong, ghiChu, soTienDuyet } = req.body;

    const resolved = await db.resolveRequestId(hoSoId);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT chuyen_trang_thai($1, $2, $3, $4, $5) AS result',
      [resolved.id, hanhDong, req.user.id, ghiChu || null, soTienDuyet || null]
    );

    res.json(rows[0].result);
  } catch (err) {
    if (err.message && err.message.includes('RAISE EXCEPTION')) {
      const msg = err.message.replace(/.*RAISE EXCEPTION:\s*/, '');
      return res.status(400).json({ error: msg });
    }
    next(err);
  }
});

router.get('/so-thanh-chu', async (req, res, next) => {
  try {
    const so = parseFloat(req.query.so);
    if (isNaN(so)) return res.status(400).json({ error: 'Số không hợp lệ' });

    const { rows } = await db.query('SELECT so_thanh_chu($1) AS result', [so]);
    res.json({ result: rows[0].result });
  } catch (err) {
    next(err);
  }
});

router.post('/tao-phieu-chi', async (req, res, next) => {
  try {
    const { hoSoId } = req.body;
    const resolved = await db.resolveRequestId(hoSoId);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT tao_phieu_chi($1, $2) AS result',
      [resolved.id, req.user.id]
    );
    res.json(rows[0].result);
  } catch (err) {
    if (err.message && err.message.includes('RAISE EXCEPTION')) {
      const msg = err.message.replace(/.*RAISE EXCEPTION:\s*/, '');
      return res.status(400).json({ error: msg });
    }
    next(err);
  }
});

module.exports = router;
