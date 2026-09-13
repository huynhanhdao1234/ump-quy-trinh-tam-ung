const router = require('express').Router();
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const REQUEST_SELECT = `
  hs.*,
  json_build_object('id', p.id, 'ho_ten', p.ho_ten) AS nguoi_de_nghi,
  json_build_object('id', dv.id, 'ten_don_vi', dv.ten_don_vi, 'ma_don_vi', dv.ma_don_vi) AS don_vi
`;

router.use(authenticate);

router.get('/next-id', async (req, res, next) => {
  try {
    const { rows } = await db.query("SELECT get_next_code('TU') AS code");
    res.json({ code: rows[0].code });
  } catch (err) {
    next(err);
  }
});

router.get('/', async (req, res, next) => {
  try {
    let sql;
    let params;

    if (req.user.vai_tro === 'nguoi_de_nghi') {
      sql = `SELECT ${REQUEST_SELECT}
             FROM ho_so_tam_ung hs
             LEFT JOIN profiles p ON p.id = hs.nguoi_de_nghi_id
             LEFT JOIN don_vi dv ON dv.id = hs.don_vi_id
             WHERE hs.nguoi_de_nghi_id = $1
             ORDER BY hs.created_at DESC`;
      params = [req.user.id];
    } else {
      sql = `SELECT ${REQUEST_SELECT}
             FROM ho_so_tam_ung hs
             LEFT JOIN profiles p ON p.id = hs.nguoi_de_nghi_id
             LEFT JOIN don_vi dv ON dv.id = hs.don_vi_id
             WHERE hs.trang_thai != 'nhap'
             ORDER BY hs.created_at DESC`;
      params = [];
    }

    const { rows } = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      `SELECT ${REQUEST_SELECT}
       FROM ho_so_tam_ung hs
       LEFT JOIN profiles p ON p.id = hs.nguoi_de_nghi_id
       LEFT JOIN don_vi dv ON dv.id = hs.don_vi_id
       WHERE hs.id = $1`,
      [resolved.id]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const {
      nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi,
      so_tien_duyet, trang_thai, loai_du_tru, thang_nam,
      ten_phong_trao, thoi_han_thanh_toan, ma_ho_so,
    } = req.body;

    let code = ma_ho_so;
    if (!code) {
      const { rows: codeRows } = await db.query("SELECT get_next_code('TU') AS code");
      code = codeRows[0].code;
    }

    const { rows } = await db.query(
      `INSERT INTO ho_so_tam_ung (
         ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi,
         so_tien_duyet, trang_thai, loai_du_tru, thang_nam,
         ten_phong_trao, thoi_han_thanh_toan
       ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       RETURNING *`,
      [
        code,
        nguoi_de_nghi_id || req.user.id,
        don_vi_id || null,
        ly_do || '',
        so_tien_de_nghi || 0,
        so_tien_duyet || null,
        trang_thai || 'nhap',
        loai_du_tru || 'HSTU-01',
        thang_nam || null,
        ten_phong_trao || null,
        thoi_han_thanh_toan || null,
      ]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const {
      don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet,
      trang_thai, loai_du_tru, thang_nam, ten_phong_trao,
      thoi_han_thanh_toan, ly_do_bo_sung, ly_do_tu_choi,
    } = req.body;

    await db.query(
      `UPDATE ho_so_tam_ung SET
         don_vi_id = COALESCE($1, don_vi_id),
         ly_do = COALESCE($2, ly_do),
         so_tien_de_nghi = COALESCE($3, so_tien_de_nghi),
         so_tien_duyet = $4,
         trang_thai = COALESCE($5, trang_thai),
         loai_du_tru = COALESCE($6, loai_du_tru),
         thang_nam = $7,
         ten_phong_trao = $8,
         thoi_han_thanh_toan = $9,
         ly_do_bo_sung = $10,
         ly_do_tu_choi = $11
       WHERE id = $12`,
      [
        don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet || null,
        trang_thai, loai_du_tru, thang_nam || null,
        ten_phong_trao || null, thoi_han_thanh_toan || null,
        ly_do_bo_sung || null, ly_do_tu_choi || null,
        resolved.id,
      ]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
