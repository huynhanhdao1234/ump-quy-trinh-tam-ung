const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

router.get('/next-id', async (req, res, next) => {
  try {
    const { rows } = await db.query("SELECT get_next_code('PC') AS code");
    res.json({ code: rows[0].code });
  } catch (err) {
    next(err);
  }
});

router.get('/:id/payment', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT * FROM phieu_chi WHERE ho_so_id = $1 LIMIT 1',
      [resolved.id]
    );
    res.json(rows[0] || null);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/payment', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const {
      ma_phieu_chi, quyen_so, ngay_chi, nguoi_nhan,
      don_vi_nhan, noi_dung, so_tien, hinh_thuc,
      ngan_hang, so_tai_khoan, ten_tai_khoan,
      xac_nhan_boi,
    } = req.body;

    let code = ma_phieu_chi;
    if (!code) {
      const { rows: codeRows } = await db.query("SELECT get_next_code('PC') AS code");
      code = codeRows[0].code;
    }

    const { rows } = await db.query(
      `INSERT INTO phieu_chi (
         ma_phieu_chi, ho_so_id, quyen_so, ngay_chi, nguoi_nhan,
         don_vi_nhan, noi_dung, so_tien, bang_chu, hinh_thuc,
         ngan_hang, so_tai_khoan, ten_tai_khoan,
         nguoi_tao_id, xac_nhan_boi, xac_nhan_luc
       ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'',$9,$10,$11,$12,$13,$14,NOW())
       RETURNING *`,
      [
        code, resolved.id,
        quyen_so || '01',
        ngay_chi || new Date().toISOString().split('T')[0],
        nguoi_nhan,
        don_vi_nhan || null,
        noi_dung || null,
        so_tien,
        hinh_thuc || 'tien_mat',
        ngan_hang || null,
        so_tai_khoan || null,
        ten_tai_khoan || null,
        req.user.id,
        xac_nhan_boi || req.user.ho_ten,
      ]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
