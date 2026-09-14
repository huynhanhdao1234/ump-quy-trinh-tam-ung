-- ============================================================================
-- HE THONG QUAN LY TAM UNG TAI CHINH CONG DOAN
-- CDCS Dai hoc Y Duoc TP.HCM
--
-- PostgreSQL Init Script (adapted from Supabase migration)
-- Phien ban: 2.0.0
-- Ngay tao: 2026-09-13
-- ============================================================================


-- ============================================================================
-- PART 1 — EXTENSIONS & ENUMS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Vai tro nguoi dung
CREATE TYPE vai_tro_type AS ENUM (
  'chu_tich',
  'ke_toan',
  'chuyen_vien',
  'thu_quy',
  'nguoi_de_nghi'
);

-- Trang thai ho so tam ung
CREATE TYPE trang_thai_type AS ENUM (
  'nhap',
  'cho_tiep_nhan',
  'cho_kiem_tra',
  'can_bo_sung',
  'cho_duyet',
  'da_duyet',
  'tu_choi',
  'da_chi',
  'hoan_tat'
);

-- Loai don vi cong doan
CREATE TYPE loai_don_vi_type AS ENUM (
  'CDBP',
  'ToCD'
);

-- Hinh thuc chi
CREATE TYPE hinh_thuc_chi_type AS ENUM (
  'tien_mat',
  'chuyen_khoan'
);


-- ============================================================================
-- PART 2 — TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 don_vi — CDBP / To CD (phai tao truoc profiles vi profiles references don_vi)
-- ----------------------------------------------------------------------------
CREATE TABLE don_vi (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ma_don_vi TEXT UNIQUE NOT NULL,
  ten_don_vi TEXT NOT NULL,
  loai_don_vi loai_don_vi_type NOT NULL,
  so_doan_vien INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE don_vi IS 'Danh sach don vi Cong doan co so phan (CDBP) va To Cong doan (ToCD)';

-- ----------------------------------------------------------------------------
-- 2.2 profiles — Thong tin nguoi dung (self-contained, khong phu thuoc auth.users)
-- ----------------------------------------------------------------------------
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ho_ten TEXT NOT NULL,
  email TEXT UNIQUE,
  password_hash TEXT,
  vai_tro vai_tro_type NOT NULL DEFAULT 'nguoi_de_nghi',
  don_vi_id UUID REFERENCES don_vi(id),
  chuc_vu TEXT,
  don_vi_ten TEXT,
  active BOOLEAN DEFAULT true,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE profiles IS 'Thong tin nguoi dung voi xac thuc local (bcrypt password hash)';

-- ----------------------------------------------------------------------------
-- 2.3 ho_so_tam_ung — Bang ho so tam ung chinh
-- ----------------------------------------------------------------------------
CREATE TABLE ho_so_tam_ung (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ma_ho_so TEXT UNIQUE NOT NULL,
  nguoi_de_nghi_id UUID NOT NULL REFERENCES profiles(id),
  don_vi_id UUID REFERENCES don_vi(id),
  ly_do TEXT NOT NULL,
  so_tien_de_nghi NUMERIC(15,0) NOT NULL DEFAULT 0,
  so_tien_duyet NUMERIC(15,0),
  trang_thai trang_thai_type NOT NULL DEFAULT 'nhap',
  loai_du_tru TEXT DEFAULT 'HSTU-01',
  thang_nam TEXT,
  ten_phong_trao TEXT,
  thoi_han_thanh_toan DATE,
  ly_do_bo_sung TEXT,
  ly_do_tu_choi TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE ho_so_tam_ung IS 'Ho so de nghi tam ung tai chinh cong doan';

-- ----------------------------------------------------------------------------
-- 2.4 du_tru_item — Hang muc du tru kinh phi (thanh_tien = don_gia * so_luong)
-- ----------------------------------------------------------------------------
CREATE TABLE du_tru_item (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ho_so_id UUID NOT NULL REFERENCES ho_so_tam_ung(id) ON DELETE CASCADE,
  stt INTEGER NOT NULL,
  noi_dung TEXT NOT NULL,
  don_gia NUMERIC(15,0) NOT NULL DEFAULT 0,
  so_luong INTEGER NOT NULL DEFAULT 1,
  don_vi_tinh TEXT DEFAULT 'Cai',
  thanh_tien NUMERIC(15,0) GENERATED ALWAYS AS (don_gia * so_luong) STORED,
  ghi_chu TEXT
);

COMMENT ON TABLE du_tru_item IS 'Chi tiet du tru kinh phi cho ho so tam ung';

-- ----------------------------------------------------------------------------
-- 2.5 ky_nhan_item — Danh sach ky nhan (thanh_tien = so_tien * so_ngay)
-- ----------------------------------------------------------------------------
CREATE TABLE ky_nhan_item (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ho_so_id UUID NOT NULL REFERENCES ho_so_tam_ung(id) ON DELETE CASCADE,
  stt INTEGER NOT NULL,
  ho_ten TEXT NOT NULL,
  so_tien NUMERIC(15,0) NOT NULL DEFAULT 0,
  so_ngay INTEGER NOT NULL DEFAULT 1,
  thanh_tien NUMERIC(15,0) GENERATED ALWAYS AS (so_tien * so_ngay) STORED,
  da_ky BOOLEAN DEFAULT false
);

COMMENT ON TABLE ky_nhan_item IS 'Danh sach nguoi ky nhan tien tam ung';

-- ----------------------------------------------------------------------------
-- 2.6 phieu_chi — Phieu chi C41-BB (hach toan don — KHONG co TK No / TK Co)
-- ----------------------------------------------------------------------------
CREATE TABLE phieu_chi (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ma_phieu_chi TEXT UNIQUE NOT NULL,
  ho_so_id UUID NOT NULL REFERENCES ho_so_tam_ung(id),
  quyen_so TEXT DEFAULT '01',
  ngay_chi DATE NOT NULL DEFAULT CURRENT_DATE,
  nguoi_nhan TEXT NOT NULL,
  don_vi_nhan TEXT,
  noi_dung TEXT,
  so_tien NUMERIC(15,0) NOT NULL,
  bang_chu TEXT,
  hinh_thuc hinh_thuc_chi_type DEFAULT 'tien_mat',
  ngan_hang TEXT,
  so_tai_khoan TEXT,
  ten_tai_khoan TEXT,
  nguoi_tao_id UUID REFERENCES profiles(id),
  xac_nhan_boi TEXT,
  xac_nhan_luc TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE phieu_chi IS 'Phieu chi C41-BB — hach toan don, mac dinh tien mat';

-- ----------------------------------------------------------------------------
-- 2.7 lich_su_phe_duyet — Lich su phe duyet ho so
-- ----------------------------------------------------------------------------
CREATE TABLE lich_su_phe_duyet (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ho_so_id UUID NOT NULL REFERENCES ho_so_tam_ung(id) ON DELETE CASCADE,
  buoc INTEGER NOT NULL,
  hanh_dong TEXT NOT NULL,
  nguoi_xu_ly_id UUID REFERENCES profiles(id),
  ten_nguoi_xu_ly TEXT,
  ghi_chu TEXT,
  thoi_gian TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE lich_su_phe_duyet IS 'Lich su cac buoc xu ly phe duyet ho so';

-- ----------------------------------------------------------------------------
-- 2.8 thong_bao — Thong bao he thong
-- ----------------------------------------------------------------------------
CREATE TABLE thong_bao (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ho_so_id UUID REFERENCES ho_so_tam_ung(id) ON DELETE CASCADE,
  noi_dung TEXT NOT NULL,
  gui_den_id UUID REFERENCES profiles(id),
  gui_den_vai_tro vai_tro_type,
  da_doc BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE thong_bao IS 'Thong bao gui den nguoi dung hoac vai tro';

-- ----------------------------------------------------------------------------
-- 2.9 file_dinh_kem — File dinh kem ho so
-- ----------------------------------------------------------------------------
CREATE TABLE file_dinh_kem (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ho_so_id UUID NOT NULL REFERENCES ho_so_tam_ung(id) ON DELETE CASCADE,
  ten_file TEXT NOT NULL,
  duong_dan TEXT NOT NULL,
  loai_file TEXT,
  kich_thuoc BIGINT,
  nguoi_tai_len_id UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE file_dinh_kem IS 'File dinh kem (chung tu, bang du tru) cua ho so';

-- ----------------------------------------------------------------------------
-- 2.10 cau_hinh — Cau hinh SLA he thong
-- ----------------------------------------------------------------------------
CREATE TABLE cau_hinh (
  id TEXT PRIMARY KEY,
  ten TEXT NOT NULL,
  gia_tri JSONB NOT NULL DEFAULT '{}',
  mo_ta TEXT,
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE cau_hinh IS 'Cau hinh SLA va tham so he thong';

-- ----------------------------------------------------------------------------
-- 2.11 counter — Bo dem tu dong tang ma ho so / phieu chi
-- ----------------------------------------------------------------------------
CREATE TABLE counter (
  loai TEXT NOT NULL,
  nam INTEGER NOT NULL,
  so_hien_tai INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (loai, nam)
);

COMMENT ON TABLE counter IS 'Bo dem tu dong cho ma ho so (TU-YYYY-XXXX) va phieu chi (PC-YYYY-XXXX)';


-- ============================================================================
-- PART 3 — INDEXES
-- ============================================================================

CREATE INDEX idx_ho_so_nguoi_de_nghi ON ho_so_tam_ung(nguoi_de_nghi_id);
CREATE INDEX idx_ho_so_trang_thai ON ho_so_tam_ung(trang_thai);
CREATE INDEX idx_ho_so_don_vi ON ho_so_tam_ung(don_vi_id);
CREATE INDEX idx_du_tru_ho_so ON du_tru_item(ho_so_id);
CREATE INDEX idx_ky_nhan_ho_so ON ky_nhan_item(ho_so_id);
CREATE INDEX idx_phieu_chi_ho_so ON phieu_chi(ho_so_id);
CREATE INDEX idx_lich_su_ho_so ON lich_su_phe_duyet(ho_so_id);
CREATE INDEX idx_thong_bao_gui_den ON thong_bao(gui_den_id);
CREATE INDEX idx_thong_bao_chua_doc ON thong_bao(gui_den_id) WHERE da_doc = false;
CREATE INDEX idx_file_ho_so ON file_dinh_kem(ho_so_id);


-- ============================================================================
-- PART 4 — HELPER FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 4.1 update_updated_at() — Tu dong cap nhat updated_at khi UPDATE
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


-- ============================================================================
-- PART 5 — BUSINESS LOGIC FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 5.1 get_next_code() — Tao ma tu dong TU-YYYY-XXXX / PC-YYYY-XXXX
--     Su dung UPSERT (INSERT ... ON CONFLICT DO UPDATE)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_next_code(p_loai TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_nam INTEGER := EXTRACT(YEAR FROM now())::INTEGER;
  v_so INTEGER;
  v_prefix TEXT;
BEGIN
  INSERT INTO counter (loai, nam, so_hien_tai)
  VALUES (p_loai, v_nam, 1)
  ON CONFLICT (loai, nam)
  DO UPDATE SET so_hien_tai = counter.so_hien_tai + 1, updated_at = now()
  RETURNING so_hien_tai INTO v_so;

  IF p_loai = 'TU' THEN v_prefix := 'TU';
  ELSIF p_loai = 'PC' THEN v_prefix := 'PC';
  ELSE v_prefix := p_loai;
  END IF;

  RETURN v_prefix || '-' || v_nam || '-' || LPAD(v_so::TEXT, 4, '0');
END;
$$;

-- ----------------------------------------------------------------------------
-- 5.2 so_thanh_chu() — Chuyen so thanh chu tieng Viet
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION so_thanh_chu(p_so NUMERIC)
RETURNS TEXT
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
  v_so BIGINT;
  v_ket_qua TEXT := '';
  v_don_vi TEXT[] := ARRAY['', 'nghìn', 'triệu', 'tỷ'];
  v_chu_so TEXT[] := ARRAY['không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
  v_temp BIGINT;
  v_tram INTEGER;
  v_chuc INTEGER;
  v_donvi INTEGER;
  v_nhom_str TEXT;
  v_count INTEGER;
BEGIN
  IF p_so IS NULL OR p_so = 0 THEN
    RETURN 'Không đồng';
  END IF;

  v_so := ABS(p_so::BIGINT);

  v_count := 0;
  WHILE v_so > 0 LOOP
    v_temp := v_so % 1000;
    v_tram := (v_temp / 100)::INTEGER;
    v_chuc := ((v_temp % 100) / 10)::INTEGER;
    v_donvi := (v_temp % 10)::INTEGER;

    v_nhom_str := '';

    IF v_temp > 0 OR (v_count = 0) THEN
      IF v_tram > 0 THEN
        v_nhom_str := v_chu_so[v_tram + 1] || ' trăm';
      ELSIF v_count > 0 AND (v_chuc > 0 OR v_donvi > 0) THEN
        v_nhom_str := 'không trăm';
      END IF;

      IF v_chuc > 1 THEN
        v_nhom_str := v_nhom_str || ' ' || v_chu_so[v_chuc + 1] || ' mươi';
      ELSIF v_chuc = 1 THEN
        v_nhom_str := v_nhom_str || ' mười';
      ELSIF v_chuc = 0 AND v_tram > 0 AND v_donvi > 0 THEN
        v_nhom_str := v_nhom_str || ' lẻ';
      END IF;

      IF v_donvi > 0 THEN
        IF v_donvi = 1 AND v_chuc > 1 THEN
          v_nhom_str := v_nhom_str || ' mốt';
        ELSIF v_donvi = 5 AND v_chuc > 0 THEN
          v_nhom_str := v_nhom_str || ' lăm';
        ELSIF v_donvi = 4 AND v_chuc > 1 THEN
          v_nhom_str := v_nhom_str || ' tư';
        ELSE
          v_nhom_str := v_nhom_str || ' ' || v_chu_so[v_donvi + 1];
        END IF;
      END IF;

      IF v_count > 0 AND v_count <= 3 THEN
        v_nhom_str := TRIM(v_nhom_str) || ' ' || v_don_vi[v_count + 1];
      ELSIF v_count > 3 THEN
        v_nhom_str := TRIM(v_nhom_str) || ' tỷ';
      END IF;
    END IF;

    IF v_nhom_str != '' THEN
      IF v_ket_qua = '' THEN
        v_ket_qua := TRIM(v_nhom_str);
      ELSE
        v_ket_qua := TRIM(v_nhom_str) || ' ' || v_ket_qua;
      END IF;
    END IF;

    v_so := v_so / 1000;
    v_count := v_count + 1;
  END LOOP;

  v_ket_qua := UPPER(LEFT(v_ket_qua, 1)) || SUBSTRING(v_ket_qua FROM 2);

  IF p_so::BIGINT % 1000 = 0 AND p_so > 0 THEN
    v_ket_qua := v_ket_qua || ' đồng chẵn';
  ELSE
    v_ket_qua := v_ket_qua || ' đồng';
  END IF;

  IF p_so < 0 THEN
    v_ket_qua := 'Âm ' || LOWER(LEFT(v_ket_qua, 1)) || SUBSTRING(v_ket_qua FROM 2);
  END IF;

  RETURN v_ket_qua;
END;
$$;

-- ----------------------------------------------------------------------------
-- 5.3 chuyen_trang_thai() — May trang thai quy trinh phe duyet
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION chuyen_trang_thai(
  p_ho_so_id UUID,
  p_hanh_dong TEXT,
  p_nguoi_xu_ly_id UUID,
  p_ghi_chu TEXT DEFAULT NULL,
  p_so_tien_duyet NUMERIC DEFAULT NULL
)
RETURNS ho_so_tam_ung
LANGUAGE plpgsql
AS $$
DECLARE
  v_ho_so ho_so_tam_ung%ROWTYPE;
  v_vai_tro vai_tro_type;
  v_ten_nguoi TEXT;
  v_new_status trang_thai_type;
  v_buoc INTEGER;
  v_thong_bao_noi_dung TEXT;
  v_thong_bao_nguoi UUID;
  v_thong_bao_vai_tro vai_tro_type;
BEGIN
  SELECT * INTO v_ho_so FROM ho_so_tam_ung WHERE id = p_ho_so_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Hồ sơ không tồn tại';
  END IF;

  SELECT vai_tro, ho_ten INTO v_vai_tro, v_ten_nguoi FROM profiles WHERE id = p_nguoi_xu_ly_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Người dùng không tồn tại';
  END IF;

  CASE p_hanh_dong

    WHEN 'nop_ho_so' THEN
      IF v_ho_so.trang_thai NOT IN ('nhap', 'can_bo_sung') THEN
        RAISE EXCEPTION 'Không thể nộp hồ sơ ở trạng thái hiện tại';
      END IF;
      IF v_vai_tro != 'nguoi_de_nghi' OR v_ho_so.nguoi_de_nghi_id != p_nguoi_xu_ly_id THEN
        RAISE EXCEPTION 'Chỉ người đề nghị mới có thể nộp hồ sơ này';
      END IF;
      v_new_status := 'cho_tiep_nhan';
      v_buoc := 1;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' vừa được nộp — chờ tiếp nhận';
      v_thong_bao_vai_tro := 'chuyen_vien';

    WHEN 'tiep_nhan' THEN
      IF v_ho_so.trang_thai != 'cho_tiep_nhan' THEN
        RAISE EXCEPTION 'Hồ sơ không ở trạng thái chờ tiếp nhận';
      END IF;
      IF v_vai_tro != 'chuyen_vien' THEN
        RAISE EXCEPTION 'Chỉ Chuyên viên VPCĐ mới có thể tiếp nhận';
      END IF;
      v_new_status := 'cho_kiem_tra';
      v_buoc := 2;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' đã tiếp nhận — chờ kiểm tra';
      v_thong_bao_vai_tro := 'ke_toan';

    WHEN 'hop_le' THEN
      IF v_ho_so.trang_thai != 'cho_kiem_tra' THEN
        RAISE EXCEPTION 'Hồ sơ không ở trạng thái chờ kiểm tra';
      END IF;
      IF v_vai_tro != 'ke_toan' THEN
        RAISE EXCEPTION 'Chỉ Kế toán mới có thể kiểm tra hồ sơ';
      END IF;
      v_new_status := 'cho_duyet';
      v_buoc := 3;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' hợp lệ — chờ Chủ tịch phê duyệt';
      v_thong_bao_vai_tro := 'chu_tich';

    WHEN 'yeu_cau_bo_sung' THEN
      IF v_ho_so.trang_thai NOT IN ('cho_kiem_tra', 'cho_duyet') THEN
        RAISE EXCEPTION 'Không thể yêu cầu bổ sung ở trạng thái hiện tại';
      END IF;
      IF v_vai_tro NOT IN ('ke_toan', 'chu_tich') THEN
        RAISE EXCEPTION 'Không có quyền yêu cầu bổ sung';
      END IF;
      IF p_ghi_chu IS NULL OR TRIM(p_ghi_chu) = '' THEN
        RAISE EXCEPTION 'Vui lòng nhập lý do yêu cầu bổ sung';
      END IF;
      v_new_status := 'can_bo_sung';
      v_buoc := CASE WHEN v_ho_so.trang_thai = 'cho_kiem_tra' THEN 3 ELSE 4 END;
      UPDATE ho_so_tam_ung SET ly_do_bo_sung = p_ghi_chu WHERE id = p_ho_so_id;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' cần bổ sung: ' || p_ghi_chu;
      v_thong_bao_nguoi := v_ho_so.nguoi_de_nghi_id;

    WHEN 'phe_duyet' THEN
      IF v_ho_so.trang_thai != 'cho_duyet' THEN
        RAISE EXCEPTION 'Hồ sơ không ở trạng thái chờ duyệt';
      END IF;
      IF v_vai_tro != 'chu_tich' THEN
        RAISE EXCEPTION 'Chỉ Chủ tịch mới có thể phê duyệt';
      END IF;
      IF p_so_tien_duyet IS NULL OR p_so_tien_duyet <= 0 THEN
        RAISE EXCEPTION 'Vui lòng nhập số tiền duyệt hợp lệ';
      END IF;
      v_new_status := 'da_duyet';
      v_buoc := 4;
      UPDATE ho_so_tam_ung SET so_tien_duyet = p_so_tien_duyet WHERE id = p_ho_so_id;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' đã được phê duyệt ' || TO_CHAR(p_so_tien_duyet, 'FM999,999,999,999') || 'đ';
      v_thong_bao_vai_tro := 'thu_quy';
      INSERT INTO thong_bao (ho_so_id, noi_dung, gui_den_vai_tro, da_doc)
      VALUES (p_ho_so_id, v_thong_bao_noi_dung, 'ke_toan', false);

    WHEN 'tu_choi' THEN
      IF v_ho_so.trang_thai != 'cho_duyet' THEN
        RAISE EXCEPTION 'Hồ sơ không ở trạng thái chờ duyệt';
      END IF;
      IF v_vai_tro != 'chu_tich' THEN
        RAISE EXCEPTION 'Chỉ Chủ tịch mới có thể từ chối';
      END IF;
      IF p_ghi_chu IS NULL OR TRIM(p_ghi_chu) = '' THEN
        RAISE EXCEPTION 'Vui lòng nhập lý do từ chối';
      END IF;
      v_new_status := 'tu_choi';
      v_buoc := 4;
      UPDATE ho_so_tam_ung SET ly_do_tu_choi = p_ghi_chu WHERE id = p_ho_so_id;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' bị từ chối: ' || p_ghi_chu;
      v_thong_bao_nguoi := v_ho_so.nguoi_de_nghi_id;

    WHEN 'da_chi' THEN
      IF v_ho_so.trang_thai != 'da_duyet' THEN
        RAISE EXCEPTION 'Hồ sơ chưa được duyệt';
      END IF;
      IF v_vai_tro NOT IN ('thu_quy', 'ke_toan') THEN
        RAISE EXCEPTION 'Chỉ Thủ quỹ hoặc Kế toán mới có thể xác nhận chi';
      END IF;
      v_new_status := 'da_chi';
      v_buoc := 5;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' đã chi thành công';
      v_thong_bao_nguoi := v_ho_so.nguoi_de_nghi_id;

    WHEN 'hoan_tat' THEN
      IF v_ho_so.trang_thai != 'da_chi' THEN
        RAISE EXCEPTION 'Hồ sơ chưa chi tiền';
      END IF;
      IF v_vai_tro NOT IN ('ke_toan', 'chuyen_vien') THEN
        RAISE EXCEPTION 'Chỉ Kế toán hoặc Chuyên viên mới có thể hoàn tất';
      END IF;
      v_new_status := 'hoan_tat';
      v_buoc := 6;
      v_thong_bao_noi_dung := 'Hồ sơ ' || v_ho_so.ma_ho_so || ' đã hoàn tất lưu trữ';
      v_thong_bao_nguoi := v_ho_so.nguoi_de_nghi_id;

    ELSE
      RAISE EXCEPTION 'Hành động không hợp lệ: %', p_hanh_dong;
  END CASE;

  UPDATE ho_so_tam_ung
  SET trang_thai = v_new_status, updated_at = now()
  WHERE id = p_ho_so_id
  RETURNING * INTO v_ho_so;

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu)
  VALUES (p_ho_so_id, v_buoc, p_hanh_dong, p_nguoi_xu_ly_id, v_ten_nguoi, COALESCE(p_ghi_chu, ''));

  IF v_thong_bao_nguoi IS NOT NULL THEN
    INSERT INTO thong_bao (ho_so_id, noi_dung, gui_den_id, da_doc)
    VALUES (p_ho_so_id, v_thong_bao_noi_dung, v_thong_bao_nguoi, false);
  ELSIF v_thong_bao_vai_tro IS NOT NULL THEN
    INSERT INTO thong_bao (ho_so_id, noi_dung, gui_den_vai_tro, da_doc)
    VALUES (p_ho_so_id, v_thong_bao_noi_dung, v_thong_bao_vai_tro, false);
  END IF;

  RETURN v_ho_so;
END;
$$;

-- ----------------------------------------------------------------------------
-- 5.4 tao_phieu_chi() — Tao phieu chi C41-BB tu ho so da duyet
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tao_phieu_chi(
  p_ho_so_id UUID,
  p_nguoi_tao_id UUID,
  p_quyen_so TEXT DEFAULT '01',
  p_hinh_thuc hinh_thuc_chi_type DEFAULT 'tien_mat',
  p_ngan_hang TEXT DEFAULT NULL,
  p_so_tai_khoan TEXT DEFAULT NULL,
  p_ten_tai_khoan TEXT DEFAULT NULL
)
RETURNS phieu_chi
LANGUAGE plpgsql
AS $$
DECLARE
  v_ho_so ho_so_tam_ung%ROWTYPE;
  v_nguoi profiles%ROWTYPE;
  v_nguoi_tao profiles%ROWTYPE;
  v_ma_phieu TEXT;
  v_phieu phieu_chi%ROWTYPE;
BEGIN
  SELECT * INTO v_ho_so FROM ho_so_tam_ung WHERE id = p_ho_so_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Hồ sơ không tồn tại';
  END IF;

  IF v_ho_so.trang_thai != 'da_duyet' THEN
    RAISE EXCEPTION 'Chỉ có thể tạo phiếu chi cho hồ sơ đã duyệt';
  END IF;

  SELECT * INTO v_nguoi_tao FROM profiles WHERE id = p_nguoi_tao_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Người tạo không tồn tại';
  END IF;
  IF v_nguoi_tao.vai_tro NOT IN ('thu_quy', 'ke_toan') THEN
    RAISE EXCEPTION 'Chỉ Thủ quỹ hoặc Kế toán mới có thể tạo phiếu chi';
  END IF;

  IF EXISTS (SELECT 1 FROM phieu_chi WHERE ho_so_id = p_ho_so_id) THEN
    RAISE EXCEPTION 'Hồ sơ này đã có phiếu chi';
  END IF;

  SELECT * INTO v_nguoi FROM profiles WHERE id = v_ho_so.nguoi_de_nghi_id;

  v_ma_phieu := get_next_code('PC');

  INSERT INTO phieu_chi (
    ma_phieu_chi, ho_so_id, quyen_so, ngay_chi,
    nguoi_nhan, don_vi_nhan, noi_dung, so_tien, bang_chu,
    hinh_thuc, ngan_hang, so_tai_khoan, ten_tai_khoan,
    nguoi_tao_id
  ) VALUES (
    v_ma_phieu,
    p_ho_so_id,
    p_quyen_so,
    CURRENT_DATE,
    v_nguoi.ho_ten,
    v_nguoi.don_vi_ten,
    v_ho_so.ly_do,
    COALESCE(v_ho_so.so_tien_duyet, v_ho_so.so_tien_de_nghi),
    so_thanh_chu(COALESCE(v_ho_so.so_tien_duyet, v_ho_so.so_tien_de_nghi)),
    p_hinh_thuc,
    p_ngan_hang,
    p_so_tai_khoan,
    p_ten_tai_khoan,
    p_nguoi_tao_id
  )
  RETURNING * INTO v_phieu;

  RETURN v_phieu;
END;
$$;


-- ============================================================================
-- PART 6 — TRIGGERS
-- ============================================================================

CREATE TRIGGER tr_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_ho_so_updated_at
  BEFORE UPDATE ON ho_so_tam_ung
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_cau_hinh_updated_at
  BEFORE UPDATE ON cau_hinh
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_counter_updated_at
  BEFORE UPDATE ON counter
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();


-- ============================================================================
-- PART 7 — VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 7.1 v_ho_so_full — Hien thi ho so kem thong tin nguoi de nghi va don vi
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_ho_so_full AS
SELECT
  hs.id,
  hs.ma_ho_so,
  hs.nguoi_de_nghi_id,
  p.ho_ten AS ten_nguoi_de_nghi,
  p.email AS email_nguoi_de_nghi,
  p.chuc_vu AS chuc_vu_nguoi_de_nghi,
  hs.don_vi_id,
  dv.ten_don_vi,
  dv.ma_don_vi,
  dv.loai_don_vi,
  hs.ly_do,
  hs.so_tien_de_nghi,
  hs.so_tien_duyet,
  hs.trang_thai,
  hs.loai_du_tru,
  hs.thang_nam,
  hs.ten_phong_trao,
  hs.thoi_han_thanh_toan,
  hs.ly_do_bo_sung,
  hs.ly_do_tu_choi,
  hs.created_at,
  hs.updated_at,
  (SELECT COUNT(*) FROM file_dinh_kem f WHERE f.ho_so_id = hs.id) AS so_file_dinh_kem,
  (SELECT COALESCE(SUM(dt.thanh_tien), 0) FROM du_tru_item dt WHERE dt.ho_so_id = hs.id) AS tong_du_tru,
  (SELECT COALESCE(SUM(kn.thanh_tien), 0) FROM ky_nhan_item kn WHERE kn.ho_so_id = hs.id) AS tong_ky_nhan
FROM ho_so_tam_ung hs
LEFT JOIN profiles p ON p.id = hs.nguoi_de_nghi_id
LEFT JOIN don_vi dv ON dv.id = hs.don_vi_id;

-- ----------------------------------------------------------------------------
-- 7.2 v_thong_bao_full — Thong bao kem thong tin ho so
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_thong_bao_full AS
SELECT
  tb.id,
  tb.ho_so_id,
  tb.noi_dung,
  tb.gui_den_id,
  tb.gui_den_vai_tro,
  tb.da_doc,
  tb.created_at,
  hs.ma_ho_so,
  hs.trang_thai AS trang_thai_ho_so,
  hs.ly_do AS ly_do_ho_so
FROM thong_bao tb
LEFT JOIN ho_so_tam_ung hs ON hs.id = tb.ho_so_id;


-- ============================================================================
-- PART 8 — SAMPLE DATA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 8.1 Don vi — 9 CDBP + 17 To CD (26 don vi)
-- ----------------------------------------------------------------------------
INSERT INTO don_vi (ma_don_vi, ten_don_vi, loai_don_vi, so_doan_vien) VALUES
  ('CDBP-01', 'CĐBP Trường Y', 'CDBP', 150),
  ('CDBP-02', 'CĐBP Khoa Răng Hàm Mặt', 'CDBP', 80),
  ('CDBP-03', 'CĐBP Trường Dược', 'CDBP', 120),
  ('CDBP-04', 'CĐBP Khoa Y tế công cộng', 'CDBP', 60),
  ('CDBP-05', 'CĐBP Trường Điều dưỡng - KTYH', 'CDBP', 90),
  ('CDBP-06', 'CĐBP Bệnh viện ĐHYD TPHCM', 'CDBP', 200),
  ('CDBP-07', 'CĐBP Khoa Y học cổ truyền', 'CDBP', 15),
  ('CDBP-08', 'CĐBP Khoa Khoa học cơ bản', 'CDBP', 20),
  ('CDBP-09', 'CĐBP Ký túc xá', 'CDBP', 18),
  ('TCD-01', 'Tổ CĐ Phòng Hành chính tổng hợp', 'ToCD', 14),
  ('TCD-02', 'Tổ CĐ Phòng Thanh tra - Pháp chế', 'ToCD', 10),
  ('TCD-03', 'Tổ CĐ Phòng Đào tạo đại học', 'ToCD', 18),
  ('TCD-04', 'Tổ CĐ Phòng Khoa học công nghệ', 'ToCD', 12),
  ('TCD-05', 'Tổ CĐ Phòng Công tác sinh viên', 'ToCD', 8),
  ('TCD-06', 'Tổ CĐ Phòng Đào tạo sau đại học', 'ToCD', 16),
  ('TCD-07', 'Tổ CĐ Phòng Đảm bảo chất lượng giáo dục và Khảo thí', 'ToCD', 12),
  ('TCD-08', 'Tổ CĐ Phòng Hợp tác quốc tế', 'ToCD', 10),
  ('TCD-09', 'Tổ CĐ Phòng Tổ chức cán bộ', 'ToCD', 15),
  ('TCD-10', 'Tổ CĐ Phòng Kế hoạch tài chính', 'ToCD', 20),
  ('TCD-11', 'Tổ CĐ Phòng Quản trị giáo tài', 'ToCD', 25),
  ('TCD-12', 'Tổ CĐ Trung tâm Công nghệ thông tin', 'ToCD', 15),
  ('TCD-13', 'Tổ CĐ Trung tâm Y sinh học phân tử', 'ToCD', 22),
  ('TCD-14', 'Tổ CĐ Trung tâm Kiểm chuẩn chất lượng xét nghiệm y học', 'ToCD', 18),
  ('TCD-15', 'Tổ CĐ Trung tâm Giáo dục Y học - Phẫu thuật thực nghiệm', 'ToCD', 10),
  ('TCD-16', 'Tổ CĐ Thư viện - Tạp chí y học', 'ToCD', 20),
  ('TCD-17', 'Tổ CĐ Trung tâm Đào tạo nhân lực y tế theo nhu cầu xã hội', 'ToCD', 14);

-- ----------------------------------------------------------------------------
-- 8.2 Cau hinh SLA mac dinh
-- ----------------------------------------------------------------------------
INSERT INTO cau_hinh (id, ten, gia_tri, mo_ta) VALUES
  ('SLA-tiep-nhan',  'Tiếp nhận hồ sơ',  '{"so_ngay": 1}',  'Chuyên viên VPCĐ tiếp nhận — tối đa 1 ngày làm việc'),
  ('SLA-kiem-tra',   'Kiểm tra hợp lệ',   '{"so_ngay": 3}',  'Kế toán kiểm tra chứng từ — tối đa 3 ngày làm việc'),
  ('SLA-phe-duyet',  'Phê duyệt',         '{"so_ngay": 1}',  'Chủ tịch CĐCS phê duyệt — tối đa 1 ngày làm việc'),
  ('SLA-chi-tien',   'Chi tạm ứng',       '{"so_ngay": 3}',  'Thủ quỹ chi tiền + Kế toán ghi sổ — tối đa 3 ngày làm việc'),
  ('SLA-luu-ho-so',  'Lưu hồ sơ',         '{"so_ngay": 3}',  'Kế toán + Chuyên viên lưu trữ — tối đa 3 ngày làm việc');

-- ----------------------------------------------------------------------------
-- 8.3 Khoi tao counter
-- ----------------------------------------------------------------------------
INSERT INTO counter (loai, nam, so_hien_tai) VALUES
  ('TU', 2026, 0),
  ('PC', 2026, 0);

-- ----------------------------------------------------------------------------
-- 8.4 Nguoi dung mau — 5 tai khoan demo + 15 nguoi de nghi
-- Mat khau duoc hash bang pgcrypto (bcrypt)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
  v_cdbp01 UUID;
  v_cdbp02 UUID;
  v_cdbp03 UUID;
  v_cdbp04 UUID;
  v_cdbp05 UUID;
  v_cdbp06 UUID;
  v_cdbp07 UUID;
  v_cdbp08 UUID;
  v_cdbp09 UUID;
  v_tcd01  UUID;
  v_tcd02  UUID;
  v_tcd03  UUID;
  v_tcd04  UUID;
  v_tcd05  UUID;
  v_tcd06  UUID;
BEGIN
  -- Lay UUID cac don vi
  SELECT id INTO v_cdbp01 FROM don_vi WHERE ma_don_vi = 'CDBP-01';
  SELECT id INTO v_cdbp02 FROM don_vi WHERE ma_don_vi = 'CDBP-02';
  SELECT id INTO v_cdbp03 FROM don_vi WHERE ma_don_vi = 'CDBP-03';
  SELECT id INTO v_cdbp04 FROM don_vi WHERE ma_don_vi = 'CDBP-04';
  SELECT id INTO v_cdbp05 FROM don_vi WHERE ma_don_vi = 'CDBP-05';
  SELECT id INTO v_cdbp06 FROM don_vi WHERE ma_don_vi = 'CDBP-06';
  SELECT id INTO v_cdbp07 FROM don_vi WHERE ma_don_vi = 'CDBP-07';
  SELECT id INTO v_cdbp08 FROM don_vi WHERE ma_don_vi = 'CDBP-08';
  SELECT id INTO v_cdbp09 FROM don_vi WHERE ma_don_vi = 'CDBP-09';
  SELECT id INTO v_tcd01  FROM don_vi WHERE ma_don_vi = 'TCD-01';
  SELECT id INTO v_tcd02  FROM don_vi WHERE ma_don_vi = 'TCD-02';
  SELECT id INTO v_tcd03  FROM don_vi WHERE ma_don_vi = 'TCD-03';
  SELECT id INTO v_tcd04  FROM don_vi WHERE ma_don_vi = 'TCD-04';
  SELECT id INTO v_tcd05  FROM don_vi WHERE ma_don_vi = 'TCD-05';
  SELECT id INTO v_tcd06  FROM don_vi WHERE ma_don_vi = 'TCD-06';

  -- 5 tai khoan demo chinh (mat khau rieng cho moi vai tro)
  INSERT INTO profiles (ho_ten, email, password_hash, vai_tro, chuc_vu) VALUES
    ('PGS.TS. Trần Quốc Bảo',   'bao.tq@ump.edu.vn',   crypt('ct123456', gen_salt('bf')), 'chu_tich', 'Chủ tịch CĐCS');
  INSERT INTO profiles (ho_ten, email, password_hash, vai_tro, chuc_vu) VALUES
    ('ThS. Lê Thị Thanh Hà',     'ha.ltt@ump.edu.vn',   crypt('kt123456', gen_salt('bf')), 'ke_toan', 'Phụ trách Kế toán CĐ');
  INSERT INTO profiles (ho_ten, email, password_hash, vai_tro, chuc_vu) VALUES
    ('CN. Võ Minh Tuấn',         'tuan.vm@ump.edu.vn',   crypt('cv123456', gen_salt('bf')), 'chuyen_vien', 'Chuyên viên VPCĐ');
  INSERT INTO profiles (ho_ten, email, password_hash, vai_tro, chuc_vu) VALUES
    ('CN. Đặng Thị Kim Ngân',    'ngan.dtk@ump.edu.vn',  crypt('tq123456', gen_salt('bf')), 'thu_quy', 'Thủ quỹ CĐ');
  INSERT INTO profiles (ho_ten, email, password_hash, vai_tro, don_vi_id, chuc_vu, don_vi_ten) VALUES
    ('TS. Phạm Hoàng Long',      'long.ph@ump.edu.vn',   crypt('ky123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp01, 'Chủ tịch CĐBP', 'CĐBP Trường Y');

  -- 15 nguoi de nghi them (mat khau chung: 123456)
  INSERT INTO profiles (ho_ten, email, password_hash, vai_tro, don_vi_id, chuc_vu, don_vi_ten) VALUES
    ('TS. Nguyễn Thị Mai Anh',   'anh.ntm@ump.edu.vn',   crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp01, 'Chủ tịch CĐBP',   'CĐBP Trường Y'),
    ('ThS. Trần Văn Khoa',       'khoa.tv@ump.edu.vn',   crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp02, 'Chủ tịch CĐBP',   'CĐBP Khoa Răng Hàm Mặt'),
    ('ThS. Lý Thanh Phương',     'phuong.lt@ump.edu.vn', crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp03, 'Chủ tịch CĐBP',   'CĐBP Trường Dược'),
    ('PGS.TS. Huỳnh Văn Đạt',    'dat.hv@ump.edu.vn',    crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp04, 'Chủ tịch CĐBP',   'CĐBP Khoa Y tế công cộng'),
    ('ThS. Ngô Thị Hương Giang', 'giang.nth@ump.edu.vn', crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp05, 'Chủ tịch CĐBP',   'CĐBP Trường Điều dưỡng - KTYH'),
    ('TS. Phan Quốc Việt',       'viet.pq@ump.edu.vn',   crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp06, 'Chủ tịch CĐBP',   'CĐBP Bệnh viện ĐHYD TPHCM'),
    ('ThS. Đỗ Thị Bích Ngọc',    'ngoc.dtb@ump.edu.vn',  crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp07, 'Chủ tịch CĐBP',   'CĐBP Khoa Y học cổ truyền'),
    ('CN. Bùi Minh Châu',        'chau.bm@ump.edu.vn',   crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp08, 'Chủ tịch CĐBP',   'CĐBP Khoa Khoa học cơ bản'),
    ('ThS. Vương Thế Hùng',      'hung.vt@ump.edu.vn',   crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_cdbp09, 'Chủ tịch CĐBP',   'CĐBP Ký túc xá'),
    ('CN. Trịnh Thị Diệu Linh',  'linh.ttd@ump.edu.vn',  crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_tcd01,  'Tổ trưởng CĐ',   'Tổ CĐ Phòng Hành chính tổng hợp'),
    ('ThS. Lâm Quang Minh',      'minh.lq@ump.edu.vn',   crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_tcd02,  'Tổ trưởng CĐ',   'Tổ CĐ Phòng Thanh tra - Pháp chế'),
    ('TS. Đinh Thị Thu Thảo',    'thao.dtt@ump.edu.vn',  crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_tcd03,  'Tổ trưởng CĐ',   'Tổ CĐ Phòng Đào tạo đại học'),
    ('CN. Hoàng Đức Thịnh',      'thinh.hd@ump.edu.vn',  crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_tcd04,  'Tổ trưởng CĐ',   'Tổ CĐ Phòng Khoa học công nghệ'),
    ('ThS. Mai Xuân Trường',     'truong.mx@ump.edu.vn', crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_tcd05,  'Tổ trưởng CĐ',   'Tổ CĐ Phòng Công tác sinh viên'),
    ('CN. Tạ Thị Mỹ Duyên',     'duyen.ttm@ump.edu.vn', crypt('123456', gen_salt('bf')), 'nguoi_de_nghi', v_tcd06,  'Tổ trưởng CĐ',   'Tổ CĐ Phòng Đào tạo sau đại học');
END;
$$;


-- ============================================================================
-- PART 9 — DU LIEU MAU HO SO TAM UNG (12 ho so)
-- ============================================================================

DO $$
DECLARE
  -- Staff IDs
  v_chutich   UUID;
  v_ketoan    UUID;
  v_chuyenvien UUID;
  v_thuquy    UUID;
  -- Nguoi de nghi IDs
  v_minh   UUID;
  v_duc    UUID;
  v_hoa    UUID;
  v_huy    UUID;
  v_lan    UUID;
  v_bvminh UUID;
  v_ngoc   UUID;
  v_phuc   UUID;
  v_quynh  UUID;
  v_son    UUID;
  v_tam    UUID;
  v_uy     UUID;
  -- Don vi IDs
  v_dv01 UUID; v_dv02 UUID; v_dv03 UUID; v_dv04 UUID;
  v_dv05 UUID; v_dv06 UUID; v_dv07 UUID; v_dv08 UUID;
  v_dv09 UUID; v_t01 UUID; v_t02 UUID;
  -- Ho so IDs
  v_hs01 UUID; v_hs02 UUID; v_hs03 UUID; v_hs04 UUID;
  v_hs05 UUID; v_hs06 UUID; v_hs07 UUID; v_hs08 UUID;
  v_hs09 UUID; v_hs10 UUID; v_hs11 UUID; v_hs12 UUID;
BEGIN
  -- === Lookup staff profiles ===
  SELECT id INTO v_chutich    FROM profiles WHERE email = 'bao.tq@ump.edu.vn';
  SELECT id INTO v_ketoan     FROM profiles WHERE email = 'ha.ltt@ump.edu.vn';
  SELECT id INTO v_chuyenvien FROM profiles WHERE email = 'tuan.vm@ump.edu.vn';
  SELECT id INTO v_thuquy     FROM profiles WHERE email = 'ngan.dtk@ump.edu.vn';

  -- === Lookup nguoi de nghi ===
  SELECT id INTO v_minh   FROM profiles WHERE email = 'long.ph@ump.edu.vn';
  SELECT id INTO v_duc    FROM profiles WHERE email = 'anh.ntm@ump.edu.vn';
  SELECT id INTO v_hoa    FROM profiles WHERE email = 'khoa.tv@ump.edu.vn';
  SELECT id INTO v_huy    FROM profiles WHERE email = 'phuong.lt@ump.edu.vn';
  SELECT id INTO v_lan    FROM profiles WHERE email = 'dat.hv@ump.edu.vn';
  SELECT id INTO v_bvminh FROM profiles WHERE email = 'giang.nth@ump.edu.vn';
  SELECT id INTO v_ngoc   FROM profiles WHERE email = 'viet.pq@ump.edu.vn';
  SELECT id INTO v_phuc   FROM profiles WHERE email = 'ngoc.dtb@ump.edu.vn';
  SELECT id INTO v_quynh  FROM profiles WHERE email = 'chau.bm@ump.edu.vn';
  SELECT id INTO v_son    FROM profiles WHERE email = 'hung.vt@ump.edu.vn';
  SELECT id INTO v_tam    FROM profiles WHERE email = 'linh.ttd@ump.edu.vn';
  SELECT id INTO v_uy     FROM profiles WHERE email = 'minh.lq@ump.edu.vn';

  -- === Lookup don vi ===
  SELECT id INTO v_dv01 FROM don_vi WHERE ma_don_vi = 'CDBP-01';
  SELECT id INTO v_dv02 FROM don_vi WHERE ma_don_vi = 'CDBP-02';
  SELECT id INTO v_dv03 FROM don_vi WHERE ma_don_vi = 'CDBP-03';
  SELECT id INTO v_dv04 FROM don_vi WHERE ma_don_vi = 'CDBP-04';
  SELECT id INTO v_dv05 FROM don_vi WHERE ma_don_vi = 'CDBP-05';
  SELECT id INTO v_dv06 FROM don_vi WHERE ma_don_vi = 'CDBP-06';
  SELECT id INTO v_dv07 FROM don_vi WHERE ma_don_vi = 'CDBP-07';
  SELECT id INTO v_dv08 FROM don_vi WHERE ma_don_vi = 'CDBP-08';
  SELECT id INTO v_dv09 FROM don_vi WHERE ma_don_vi = 'CDBP-09';
  SELECT id INTO v_t01  FROM don_vi WHERE ma_don_vi = 'TCD-01';
  SELECT id INTO v_t02  FROM don_vi WHERE ma_don_vi = 'TCD-02';

  -- =========================================================================
  -- HS 01: TU-2026-0001 | Nguyen Van Minh | Hoi thao khoa hoc | 15M | hoan_tat
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet, trang_thai, thang_nam, created_at, updated_at)
  VALUES ('TU-2026-0001', v_minh, v_dv01, 'Tổ chức Hội thảo Khoa học thường niên Khoa Y', 15000000, 14500000, 'hoan_tat', '09/2026', NOW() - INTERVAL '45 days', NOW() - INTERVAL '5 days')
  RETURNING id INTO v_hs01;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs01, 1, 'Thuê hội trường', 5000000, 1, 'Buổi', 'Hội trường 200 chỗ'),
    (v_hs01, 2, 'In tài liệu hội thảo', 50000, 100, 'Bộ', NULL),
    (v_hs01, 3, 'Nước uống, tea break', 30000, 100, 'Phần', NULL),
    (v_hs01, 4, 'Banner, backdrop', 2000000, 1, 'Bộ', 'Thiết kế + in ấn');

  INSERT INTO ky_nhan_item (ho_so_id, stt, ho_ten, so_tien, so_ngay, da_ky) VALUES
    (v_hs01, 1, 'Phạm Hoàng Long', 14500000, 1, true);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs01, 1, 'Nộp hồ sơ',    v_minh,       'TS. Phạm Hoàng Long',        NULL,                                  NOW() - INTERVAL '45 days'),
    (v_hs01, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Hồ sơ đầy đủ',                        NOW() - INTERVAL '44 days'),
    (v_hs01, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Đã kiểm tra chứng từ',                NOW() - INTERVAL '42 days'),
    (v_hs01, 4, 'Phê duyệt',     v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Duyệt 14.500.000đ',                   NOW() - INTERVAL '41 days'),
    (v_hs01, 5, 'Đã chi',        v_thuquy,     'CN. Đặng Thị Kim Ngân',         'Chi tiền mặt',                         NOW() - INTERVAL '38 days'),
    (v_hs01, 6, 'Hoàn tất',      v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Đã lưu hồ sơ',                        NOW() - INTERVAL '35 days');

  INSERT INTO phieu_chi (ma_phieu_chi, ho_so_id, quyen_so, ngay_chi, nguoi_nhan, don_vi_nhan, noi_dung, so_tien, bang_chu, hinh_thuc, nguoi_tao_id)
  VALUES ('PC-2026-0001', v_hs01, '01', (NOW() - INTERVAL '38 days')::DATE, 'TS. Phạm Hoàng Long', 'CĐBP Trường Y', 'Tổ chức Hội thảo Khoa học thường niên Khoa Y', 14500000, 'Mười bốn triệu năm trăm nghìn đồng', 'tien_mat', v_thuquy);

  -- =========================================================================
  -- HS 02: TU-2026-0002 | Hoang Minh Duc | Tham doan vien | 5M | da_chi
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet, trang_thai, thang_nam, created_at, updated_at)
  VALUES ('TU-2026-0002', v_duc, v_dv01, 'Thăm hỏi đoàn viên ốm đau dài ngày', 5000000, 5000000, 'da_chi', '08/2026', NOW() - INTERVAL '30 days', NOW() - INTERVAL '20 days')
  RETURNING id INTO v_hs02;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs02, 1, 'Quà thăm đoàn viên', 500000, 5, 'Phần', 'Đoàn viên Khoa Y nằm viện'),
    (v_hs02, 2, 'Chi phí đi lại', 200000, 5, 'Lượt', NULL),
    (v_hs02, 3, 'Tiền mặt hỗ trợ', 1500000, 1, 'Lần', 'Hỗ trợ đoàn viên khó khăn');

  INSERT INTO ky_nhan_item (ho_so_id, stt, ho_ten, so_tien, so_ngay, da_ky) VALUES
    (v_hs02, 1, 'Nguyễn Thị Mai Anh', 5000000, 1, true);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs02, 1, 'Nộp hồ sơ',    v_duc,        'TS. Nguyễn Thị Mai Anh',          NULL,                                  NOW() - INTERVAL '30 days'),
    (v_hs02, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Đủ hồ sơ',                            NOW() - INTERVAL '29 days'),
    (v_hs02, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Hợp lệ theo quy chế',                 NOW() - INTERVAL '27 days'),
    (v_hs02, 4, 'Phê duyệt',     v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Đồng ý duyệt đủ số tiền',            NOW() - INTERVAL '26 days'),
    (v_hs02, 5, 'Đã chi',        v_thuquy,     'CN. Đặng Thị Kim Ngân',         'Chi tiền mặt theo phiếu chi',          NOW() - INTERVAL '24 days');

  INSERT INTO phieu_chi (ma_phieu_chi, ho_so_id, quyen_so, ngay_chi, nguoi_nhan, don_vi_nhan, noi_dung, so_tien, bang_chu, hinh_thuc, nguoi_tao_id)
  VALUES ('PC-2026-0002', v_hs02, '01', (NOW() - INTERVAL '24 days')::DATE, 'TS. Nguyễn Thị Mai Anh', 'CĐBP Trường Y', 'Thăm hỏi đoàn viên ốm đau dài ngày', 5000000, 'Năm triệu đồng', 'tien_mat', v_thuquy);

  -- =========================================================================
  -- HS 03: TU-2026-0003 | Ngo Thi Hoa | To chuc 8/3 | 8M | da_duyet
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet, trang_thai, thang_nam, ten_phong_trao, created_at, updated_at)
  VALUES ('TU-2026-0003', v_hoa, v_dv02, 'Tổ chức lễ kỷ niệm Ngày Quốc tế Phụ nữ 8/3', 8000000, 7500000, 'da_duyet', '03/2026', 'Ngày 8/3', NOW() - INTERVAL '20 days', NOW() - INTERVAL '14 days')
  RETURNING id INTO v_hs03;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs03, 1, 'Quà tặng nữ đoàn viên', 100000, 40, 'Phần', 'Hoa + quà'),
    (v_hs03, 2, 'Trang trí hội trường', 1500000, 1, 'Gói', NULL),
    (v_hs03, 3, 'Bánh kem, nước ngọt', 50000, 50, 'Phần', NULL);

  INSERT INTO ky_nhan_item (ho_so_id, stt, ho_ten, so_tien, so_ngay, da_ky) VALUES
    (v_hs03, 1, 'Trần Văn Khoa', 4000000, 1, false),
    (v_hs03, 2, 'Nguyễn Thị Hạnh', 3500000, 1, false);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs03, 1, 'Nộp hồ sơ',    v_hoa,        'ThS. Trần Văn Khoa',             NULL,                                  NOW() - INTERVAL '20 days'),
    (v_hs03, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Hồ sơ đầy đủ',                        NOW() - INTERVAL '19 days'),
    (v_hs03, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Chứng từ hợp lệ',                     NOW() - INTERVAL '17 days'),
    (v_hs03, 4, 'Phê duyệt',     v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Duyệt 7.500.000đ cho phù hợp ngân sách', NOW() - INTERVAL '16 days');

  -- =========================================================================
  -- HS 04: TU-2026-0004 | Vu Quang Huy | Mua VPP | 3.5M | cho_duyet
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, created_at, updated_at)
  VALUES ('TU-2026-0004', v_huy, v_dv03, 'Mua văn phòng phẩm phục vụ hoạt động Công đoàn quý III', 3500000, 'cho_duyet', '09/2026', NOW() - INTERVAL '10 days', NOW() - INTERVAL '7 days')
  RETURNING id INTO v_hs04;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs04, 1, 'Giấy A4', 80000, 10, 'Ram', NULL),
    (v_hs04, 2, 'Bút bi', 5000, 100, 'Cây', NULL),
    (v_hs04, 3, 'Kẹp hồ sơ, bìa lá', 300000, 5, 'Hộp', NULL),
    (v_hs04, 4, 'Mực in', 350000, 2, 'Hộp', 'Mực in HP LaserJet');

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs04, 1, 'Nộp hồ sơ',    v_huy,        'ThS. Lý Thanh Phương',           NULL,                                  NOW() - INTERVAL '10 days'),
    (v_hs04, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Đã nhận hồ sơ',                       NOW() - INTERVAL '9 days'),
    (v_hs04, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Đủ chứng từ, chuyển Chủ tịch duyệt', NOW() - INTERVAL '8 days');

  -- =========================================================================
  -- HS 05: TU-2026-0005 | Do Thi Lan | Tap huan | 12M | cho_kiem_tra
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, created_at, updated_at)
  VALUES ('TU-2026-0005', v_lan, v_dv04, 'Tập huấn nghiệp vụ công đoàn cho cán bộ CĐCS', 12000000, 'cho_kiem_tra', '09/2026', NOW() - INTERVAL '7 days', NOW() - INTERVAL '5 days')
  RETURNING id INTO v_hs05;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs05, 1, 'Thuê phòng tập huấn', 3000000, 1, 'Ngày', '2 ngày x 1.5M'),
    (v_hs05, 2, 'Thù lao giảng viên', 2000000, 2, 'Người', NULL),
    (v_hs05, 3, 'Tài liệu tập huấn', 30000, 60, 'Bộ', NULL),
    (v_hs05, 4, 'Cơm trưa', 50000, 60, 'Suất', '2 ngày');

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs05, 1, 'Nộp hồ sơ',    v_lan,        'PGS.TS. Huỳnh Văn Đạt',          NULL,                                  NOW() - INTERVAL '7 days'),
    (v_hs05, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Hồ sơ đầy đủ, chuyển kế toán',        NOW() - INTERVAL '6 days');

  -- =========================================================================
  -- HS 06: TU-2026-0006 | Bui Van Minh | Giai the thao | 20M | cho_tiep_nhan
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, ten_phong_trao, created_at, updated_at)
  VALUES ('TU-2026-0006', v_bvminh, v_dv05, 'Tổ chức Giải thể thao chào mừng Ngày thành lập Công đoàn', 20000000, 'cho_tiep_nhan', '10/2026', 'Hội thao CĐ', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days')
  RETURNING id INTO v_hs06;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs06, 1, 'Thuê sân bóng đá', 2000000, 2, 'Buổi', NULL),
    (v_hs06, 2, 'Cúp, huy chương', 3000000, 1, 'Bộ', '3 cúp + 30 huy chương'),
    (v_hs06, 3, 'Nước uống, khăn lạnh', 20000, 200, 'Phần', NULL),
    (v_hs06, 4, 'Trang phục thi đấu', 150000, 60, 'Bộ', 'Áo đội');

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs06, 1, 'Nộp hồ sơ',    v_bvminh,     'ThS. Ngô Thị Hương Giang',           'Đề nghị tạm ứng tổ chức hội thao',   NOW() - INTERVAL '3 days');

  -- =========================================================================
  -- HS 07: TU-2026-0007 | Ly Thi Ngoc | To chuc 1/6 | 10M | nhap
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, ten_phong_trao, created_at, updated_at)
  VALUES ('TU-2026-0007', v_ngoc, v_dv06, 'Tổ chức vui chơi Ngày Quốc tế Thiếu nhi 1/6 cho con em đoàn viên', 10000000, 'nhap', '06/2026', 'Ngày 1/6', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day')
  RETURNING id INTO v_hs07;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs07, 1, 'Quà tặng thiếu nhi', 100000, 50, 'Phần', 'Bánh kẹo + đồ chơi'),
    (v_hs07, 2, 'Thuê nhà phao, trò chơi', 4000000, 1, 'Gói', NULL),
    (v_hs07, 3, 'Trang trí sân khấu', 1000000, 1, 'Gói', NULL);

  -- =========================================================================
  -- HS 08: TU-2026-0008 | Truong Van Phuc | Ho tro DV kho khan | 7M | can_bo_sung
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, ly_do_bo_sung, created_at, updated_at)
  VALUES ('TU-2026-0008', v_phuc, v_dv07, 'Hỗ trợ đoàn viên có hoàn cảnh khó khăn đột xuất', 7000000, 'can_bo_sung', '09/2026', 'Cần bổ sung danh sách đoàn viên được hỗ trợ kèm xác nhận của Trưởng đơn vị', NOW() - INTERVAL '12 days', NOW() - INTERVAL '8 days')
  RETURNING id INTO v_hs08;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs08, 1, 'Tiền mặt hỗ trợ', 1000000, 5, 'Người', 'Đoàn viên khó khăn đột xuất'),
    (v_hs08, 2, 'Quà thăm hỏi', 400000, 5, 'Phần', NULL);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs08, 1, 'Nộp hồ sơ',         v_phuc,       'ThS. Đỗ Thị Bích Ngọc',        NULL,                                  NOW() - INTERVAL '12 days'),
    (v_hs08, 2, 'Tiếp nhận',          v_chuyenvien, 'CN. Võ Minh Tuấn',             'Đã nhận',                              NOW() - INTERVAL '11 days'),
    (v_hs08, 3, 'Hợp lệ',             v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Chuyển Chủ tịch',                      NOW() - INTERVAL '10 days'),
    (v_hs08, 4, 'Yêu cầu bổ sung',   v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Cần bổ sung danh sách đoàn viên được hỗ trợ kèm xác nhận của Trưởng đơn vị', NOW() - INTERVAL '9 days');

  -- =========================================================================
  -- HS 09: TU-2026-0009 | Mai Thi Quynh | Dao tao ky nang | 6M | tu_choi
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, ly_do_tu_choi, created_at, updated_at)
  VALUES ('TU-2026-0009', v_quynh, v_dv08, 'Tổ chức khóa đào tạo kỹ năng mềm cho đoàn viên', 6000000, 'tu_choi', '08/2026', 'Nội dung đào tạo trùng lặp với chương trình của Phòng TCCB đã tổ chức tháng 7. Đề nghị phối hợp với Phòng TCCB thay vì tổ chức riêng.', NOW() - INTERVAL '25 days', NOW() - INTERVAL '20 days')
  RETURNING id INTO v_hs09;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs09, 1, 'Thù lao giảng viên bên ngoài', 3000000, 1, 'Buổi', 'Chuyên gia kỹ năng mềm'),
    (v_hs09, 2, 'Tài liệu học viên', 20000, 50, 'Bộ', NULL),
    (v_hs09, 3, 'Tea break', 30000, 50, 'Phần', NULL);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs09, 1, 'Nộp hồ sơ',    v_quynh,      'CN. Bùi Minh Châu',            NULL,                                  NOW() - INTERVAL '25 days'),
    (v_hs09, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Đã tiếp nhận',                         NOW() - INTERVAL '24 days'),
    (v_hs09, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Hồ sơ đầy đủ',                        NOW() - INTERVAL '23 days'),
    (v_hs09, 4, 'Từ chối',       v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Nội dung trùng lặp với chương trình Phòng TCCB tháng 7', NOW() - INTERVAL '22 days');

  -- =========================================================================
  -- HS 10: TU-2026-0010 | Dinh Cong Son | Hoi nghi tong ket | 18M | da_chi
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet, trang_thai, thang_nam, created_at, updated_at)
  VALUES ('TU-2026-0010', v_son, v_dv09, 'Tổ chức Hội nghị tổng kết hoạt động Công đoàn năm học', 18000000, 17000000, 'da_chi', '08/2026', NOW() - INTERVAL '35 days', NOW() - INTERVAL '22 days')
  RETURNING id INTO v_hs10;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs10, 1, 'Thuê hội trường', 4000000, 1, 'Buổi', 'Hội trường 150 chỗ'),
    (v_hs10, 2, 'Phần ăn nhẹ', 60000, 100, 'Phần', NULL),
    (v_hs10, 3, 'In ấn tài liệu, báo cáo', 40000, 80, 'Bộ', NULL),
    (v_hs10, 4, 'Quà khen thưởng cá nhân', 300000, 10, 'Phần', 'Đoàn viên xuất sắc');

  INSERT INTO ky_nhan_item (ho_so_id, stt, ho_ten, so_tien, so_ngay, da_ky) VALUES
    (v_hs10, 1, 'Vương Thế Hùng', 17000000, 1, true);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs10, 1, 'Nộp hồ sơ',    v_son,        'ThS. Vương Thế Hùng',           NULL,                                  NOW() - INTERVAL '35 days'),
    (v_hs10, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Tiếp nhận hồ sơ',                     NOW() - INTERVAL '34 days'),
    (v_hs10, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Kiểm tra xong, hợp lệ',              NOW() - INTERVAL '32 days'),
    (v_hs10, 4, 'Phê duyệt',     v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Duyệt 17.000.000đ',                   NOW() - INTERVAL '30 days'),
    (v_hs10, 5, 'Đã chi',        v_thuquy,     'CN. Đặng Thị Kim Ngân',         'Chuyển khoản',                         NOW() - INTERVAL '27 days');

  INSERT INTO phieu_chi (ma_phieu_chi, ho_so_id, quyen_so, ngay_chi, nguoi_nhan, don_vi_nhan, noi_dung, so_tien, bang_chu, hinh_thuc, ngan_hang, so_tai_khoan, ten_tai_khoan, nguoi_tao_id)
  VALUES ('PC-2026-0003', v_hs10, '01', (NOW() - INTERVAL '27 days')::DATE, 'ThS. Vương Thế Hùng', 'CĐBP Ký túc xá', 'Tổ chức Hội nghị tổng kết hoạt động CĐ', 17000000, 'Mười bảy triệu đồng', 'chuyen_khoan', 'Vietcombank', '0123456789', 'Vương Thế Hùng', v_thuquy);

  -- =========================================================================
  -- HS 11: TU-2026-0011 | Phan Thi Tam | Tham quan hoc tap | 25M | da_duyet
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, so_tien_duyet, trang_thai, thang_nam, ten_phong_trao, created_at, updated_at)
  VALUES ('TU-2026-0011', v_tam, v_t01, 'Tổ chức chuyến tham quan học tập kinh nghiệm hoạt động Công đoàn', 25000000, 24000000, 'da_duyet', '10/2026', 'Tham quan học tập', NOW() - INTERVAL '8 days', NOW() - INTERVAL '4 days')
  RETURNING id INTO v_hs11;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs11, 1, 'Thuê xe 45 chỗ', 8000000, 1, 'Chuyến', 'Khứ hồi'),
    (v_hs11, 2, 'Ăn trưa', 100000, 40, 'Suất', NULL),
    (v_hs11, 3, 'Nước uống, bánh', 30000, 40, 'Phần', NULL),
    (v_hs11, 4, 'Quà lưu niệm đơn vị bạn', 2000000, 1, 'Bộ', NULL),
    (v_hs11, 5, 'Chi phí phát sinh', 2800000, 1, 'Gói', 'Dự phòng');

  INSERT INTO ky_nhan_item (ho_so_id, stt, ho_ten, so_tien, so_ngay, da_ky) VALUES
    (v_hs11, 1, 'Trịnh Thị Diệu Linh', 15000000, 1, false),
    (v_hs11, 2, 'Lê Văn Phúc', 9000000, 1, false);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs11, 1, 'Nộp hồ sơ',    v_tam,        'CN. Trịnh Thị Diệu Linh',             NULL,                                  NOW() - INTERVAL '8 days'),
    (v_hs11, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Đã nhận hồ sơ',                       NOW() - INTERVAL '7 days'),
    (v_hs11, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Đã kiểm tra, chuyển duyệt',           NOW() - INTERVAL '5 days'),
    (v_hs11, 4, 'Phê duyệt',     v_chutich,    'PGS.TS. Trần Quốc Bảo',    'Duyệt 24.000.000đ — giảm chi phí phát sinh', NOW() - INTERVAL '4 days');

  -- =========================================================================
  -- HS 12: TU-2026-0012 | Ho Van Uy | Mua thiet bi VP | 4.5M | cho_duyet
  -- =========================================================================
  INSERT INTO ho_so_tam_ung (ma_ho_so, nguoi_de_nghi_id, don_vi_id, ly_do, so_tien_de_nghi, trang_thai, thang_nam, created_at, updated_at)
  VALUES ('TU-2026-0012', v_uy, v_t02, 'Mua thiết bị văn phòng phục vụ công tác Công đoàn', 4500000, 'cho_duyet', '09/2026', NOW() - INTERVAL '6 days', NOW() - INTERVAL '4 days')
  RETURNING id INTO v_hs12;

  INSERT INTO du_tru_item (ho_so_id, stt, noi_dung, don_gia, so_luong, don_vi_tinh, ghi_chu) VALUES
    (v_hs12, 1, 'Máy in HP LaserJet', 3500000, 1, 'Cái', 'Thay máy in cũ hỏng'),
    (v_hs12, 2, 'Mực in dự phòng', 500000, 2, 'Hộp', NULL);

  INSERT INTO lich_su_phe_duyet (ho_so_id, buoc, hanh_dong, nguoi_xu_ly_id, ten_nguoi_xu_ly, ghi_chu, thoi_gian) VALUES
    (v_hs12, 1, 'Nộp hồ sơ',    v_uy,         'ThS. Lâm Quang Minh',               NULL,                                  NOW() - INTERVAL '6 days'),
    (v_hs12, 2, 'Tiếp nhận',     v_chuyenvien, 'CN. Võ Minh Tuấn',             'Hồ sơ đầy đủ',                        NOW() - INTERVAL '5 days'),
    (v_hs12, 3, 'Hợp lệ',        v_ketoan,     'ThS. Lê Thị Thanh Hà',        'Đã kiểm tra, đề nghị duyệt',         NOW() - INTERVAL '4 days');

  -- === Cap nhat counter ===
  UPDATE counter SET so_hien_tai = 12 WHERE loai = 'TU' AND nam = 2026;
  UPDATE counter SET so_hien_tai = 3  WHERE loai = 'PC' AND nam = 2026;
END;
$$;


-- ============================================================================
-- HOAN TAT INIT
-- ============================================================================
-- Chay file nay tu dong khi Docker container khoi tao lan dau:
--   volumes:
--     - ./db/init.sql:/docker-entrypoint-initdb.d/01-init.sql
--
-- Tai khoan demo:
--   bao.tq@ump.edu.vn / ct123456    (Chu tich CDCS)
--   ha.ltt@ump.edu.vn / kt123456    (Ke toan)
--   tuan.vm@ump.edu.vn / cv123456   (Chuyen vien VPCD)
--   ngan.dtk@ump.edu.vn / tq123456  (Thu quy)
--   long.ph@ump.edu.vn / ky123456   (Nguoi de nghi — CD Khoa Y)
--   Cac tai khoan nguoi de nghi khac: mat khau 123456
--
-- Du lieu mau: 12 ho so tam ung o cac trang thai khac nhau
-- ============================================================================
