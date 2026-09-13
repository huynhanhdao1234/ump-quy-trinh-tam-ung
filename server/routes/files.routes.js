const router = require('express').Router();
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const UPLOAD_DIR = process.env.UPLOAD_DIR || path.join(__dirname, '..', 'uploads');

const storage = multer.diskStorage({
  destination: (req, _file, cb) => {
    const dir = path.join(UPLOAD_DIR, req._resolvedId || 'misc');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (_req, file, cb) => {
    const safeName = `${Date.now()}_${file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_')}`;
    cb(null, safeName);
  },
});

const upload = multer({ storage, limits: { fileSize: 20 * 1024 * 1024 } });

router.use(authenticate);

router.get('/download/:fileId', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT * FROM file_dinh_kem WHERE id = $1',
      [req.params.fileId]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'File không tồn tại' });

    const filePath = path.join(UPLOAD_DIR, rows[0].duong_dan);
    if (!fs.existsSync(filePath)) return res.status(404).json({ error: 'File không tồn tại trên đĩa' });

    res.download(filePath, rows[0].ten_file);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/files', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    const { rows } = await db.query(
      'SELECT * FROM file_dinh_kem WHERE ho_so_id = $1',
      [resolved.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/files', async (req, res, next) => {
  try {
    const resolved = await db.resolveRequestId(req.params.id);
    if (!resolved) return res.status(404).json({ error: 'Hồ sơ không tồn tại' });

    req._resolvedId = resolved.id;

    upload.single('file')(req, res, async (err) => {
      if (err) return next(err);
      if (!req.file) return res.status(400).json({ error: 'Không có file' });

      const relativePath = path.join(resolved.id, req.file.filename);

      try {
        const { rows } = await db.query(
          `INSERT INTO file_dinh_kem (ho_so_id, ten_file, duong_dan, loai_file, kich_thuoc, nguoi_tai_len_id)
           VALUES ($1, $2, $3, $4, $5, $6)
           RETURNING *`,
          [
            resolved.id,
            req.file.originalname,
            relativePath,
            req.file.mimetype,
            req.file.size,
            req.user.id,
          ]
        );
        res.status(201).json(rows[0]);
      } catch (dbErr) {
        next(dbErr);
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
