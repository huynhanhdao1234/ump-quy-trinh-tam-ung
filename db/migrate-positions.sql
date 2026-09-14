-- Migration: Set correct chuc_vu (position) for nguoi_de_nghi users
-- CĐBP units -> "Chủ tịch CĐBP", Tổ CĐ units -> "Tổ trưởng CĐ"

BEGIN;

UPDATE profiles p
SET chuc_vu = CASE
  WHEN dv.loai_don_vi = 'CDBP' THEN 'Chủ tịch CĐBP'
  WHEN dv.loai_don_vi = 'ToCD' THEN 'Tổ trưởng CĐ'
END
FROM don_vi dv
WHERE p.don_vi_id = dv.id
  AND p.vai_tro = 'nguoi_de_nghi'
  AND p.don_vi_id IS NOT NULL;

COMMIT;
