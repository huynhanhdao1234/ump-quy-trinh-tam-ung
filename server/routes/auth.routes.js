const router = require('express').Router();
const bcrypt = require('bcryptjs');
const db = require('../db');
const { authenticate, signToken } = require('../middleware/auth');

const PROFILE_SELECT = `
  p.id, p.ho_ten, p.email, p.vai_tro, p.don_vi_id, p.chuc_vu,
  p.don_vi_ten, p.active, p.avatar_url, p.created_at, p.updated_at,
  json_build_object('id', d.id, 'ma_don_vi', d.ma_don_vi, 'ten_don_vi', d.ten_don_vi) AS don_vi
`;

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email và mật khẩu là bắt buộc' });
    }

    const { rows } = await db.query(
      `SELECT p.*, p.password_hash,
              json_build_object('id', d.id, 'ma_don_vi', d.ma_don_vi, 'ten_don_vi', d.ten_don_vi) AS don_vi
       FROM profiles p
       LEFT JOIN don_vi d ON d.id = p.don_vi_id
       WHERE p.email = $1 AND p.active = true`,
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Email hoặc mật khẩu không đúng' });
    }

    const user = rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Email hoặc mật khẩu không đúng' });
    }

    const token = signToken({
      id: user.id,
      email: user.email,
      vai_tro: user.vai_tro,
      ho_ten: user.ho_ten,
    });

    delete user.password_hash;
    res.json({ token, user });
  } catch (err) {
    next(err);
  }
});

router.get('/session', authenticate, async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT ${PROFILE_SELECT}
       FROM profiles p
       LEFT JOIN don_vi d ON d.id = p.don_vi_id
       WHERE p.id = $1 AND p.active = true`,
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Người dùng không tồn tại' });
    }

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
