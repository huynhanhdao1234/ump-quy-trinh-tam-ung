const router = require('express').Router();
const db = require('../db');
const { authenticate, requireRole } = require('../middleware/auth');

const USER_SELECT = `
  p.id, p.ho_ten, p.email, p.vai_tro, p.don_vi_id, p.chuc_vu,
  p.don_vi_ten, p.active, p.avatar_url, p.created_at, p.updated_at,
  json_build_object('id', d.id, 'ma_don_vi', d.ma_don_vi, 'ten_don_vi', d.ten_don_vi) AS don_vi
`;

router.use(authenticate);

router.get('/search', async (req, res, next) => {
  try {
    const q = req.query.q || '';
    const { rows } = await db.query(
      `SELECT p.id, p.ho_ten, p.don_vi_id, p.chuc_vu,
              d.ten_don_vi, d.ma_don_vi
       FROM profiles p
       LEFT JOIN don_vi d ON d.id = p.don_vi_id
       WHERE p.active = true
         AND p.ho_ten ILIKE $1
       ORDER BY p.ho_ten
       LIMIT 20`,
      [`%${q}%`]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT ${USER_SELECT}
       FROM profiles p
       LEFT JOIN don_vi d ON d.id = p.don_vi_id
       WHERE p.active = true
       ORDER BY p.ho_ten`
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.get('/by-email/:email', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT ${USER_SELECT}
       FROM profiles p
       LEFT JOIN don_vi d ON d.id = p.don_vi_id
       WHERE p.email = $1`,
      [req.params.email]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT ${USER_SELECT}
       FROM profiles p
       LEFT JOIN don_vi d ON d.id = p.don_vi_id
       WHERE p.id = $1`,
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const { ho_ten, vai_tro, don_vi_id, don_vi_ten, chuc_vu, email, active } = req.body;
    await db.query(
      `UPDATE profiles SET
         ho_ten = COALESCE($1, ho_ten),
         vai_tro = COALESCE($2, vai_tro),
         don_vi_id = $3,
         don_vi_ten = COALESCE($4, don_vi_ten),
         chuc_vu = COALESCE($5, chuc_vu),
         email = COALESCE($6, email),
         active = COALESCE($7, active)
       WHERE id = $8`,
      [ho_ten, vai_tro, don_vi_id || null, don_vi_ten, chuc_vu, email, active, req.params.id]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await db.query('UPDATE profiles SET active = false WHERE id = $1', [req.params.id]);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
