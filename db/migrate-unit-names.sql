-- Migration: Update don_vi names to accurate names
-- Run this against the live database to update existing unit names

BEGIN;

-- 9 CĐBP (Grassroots Trade Union Divisions)
UPDATE don_vi SET ten_don_vi = 'CĐBP Trường Y' WHERE ma_don_vi = 'CDBP-01';
UPDATE don_vi SET ten_don_vi = 'CĐBP Khoa Răng Hàm Mặt' WHERE ma_don_vi = 'CDBP-02';
UPDATE don_vi SET ten_don_vi = 'CĐBP Trường Dược' WHERE ma_don_vi = 'CDBP-03';
UPDATE don_vi SET ten_don_vi = 'CĐBP Khoa Y tế công cộng' WHERE ma_don_vi = 'CDBP-04';
UPDATE don_vi SET ten_don_vi = 'CĐBP Trường Điều dưỡng - KTYH' WHERE ma_don_vi = 'CDBP-05';
UPDATE don_vi SET ten_don_vi = 'CĐBP Bệnh viện ĐHYD TPHCM' WHERE ma_don_vi = 'CDBP-06';
UPDATE don_vi SET ten_don_vi = 'CĐBP Khoa Y học cổ truyền' WHERE ma_don_vi = 'CDBP-07';
UPDATE don_vi SET ten_don_vi = 'CĐBP Khoa Khoa học cơ bản' WHERE ma_don_vi = 'CDBP-08';
UPDATE don_vi SET ten_don_vi = 'CĐBP Ký túc xá' WHERE ma_don_vi = 'CDBP-09';

-- 17 Tổ CĐ (Trade Union Groups)
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Hành chính tổng hợp' WHERE ma_don_vi = 'TCD-01';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Thanh tra - Pháp chế' WHERE ma_don_vi = 'TCD-02';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Đào tạo đại học' WHERE ma_don_vi = 'TCD-03';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Khoa học công nghệ' WHERE ma_don_vi = 'TCD-04';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Công tác sinh viên' WHERE ma_don_vi = 'TCD-05';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Đào tạo sau đại học' WHERE ma_don_vi = 'TCD-06';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Đảm bảo chất lượng giáo dục và Khảo thí' WHERE ma_don_vi = 'TCD-07';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Hợp tác quốc tế' WHERE ma_don_vi = 'TCD-08';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Tổ chức cán bộ' WHERE ma_don_vi = 'TCD-09';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Kế hoạch tài chính' WHERE ma_don_vi = 'TCD-10';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Phòng Quản trị giáo tài' WHERE ma_don_vi = 'TCD-11';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Trung tâm Công nghệ thông tin' WHERE ma_don_vi = 'TCD-12';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Trung tâm Y sinh học phân tử' WHERE ma_don_vi = 'TCD-13';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Trung tâm Kiểm chuẩn chất lượng xét nghiệm y học' WHERE ma_don_vi = 'TCD-14';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Trung tâm Giáo dục Y học - Phẫu thuật thực nghiệm' WHERE ma_don_vi = 'TCD-15';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Thư viện - Tạp chí y học' WHERE ma_don_vi = 'TCD-16';
UPDATE don_vi SET ten_don_vi = 'Tổ CĐ Trung tâm Đào tạo nhân lực y tế theo nhu cầu xã hội' WHERE ma_don_vi = 'TCD-17';

-- Also update denormalized don_vi_ten in profiles to match
UPDATE profiles p
SET don_vi_ten = dv.ten_don_vi
FROM don_vi dv
WHERE p.don_vi_id = dv.id AND p.don_vi_id IS NOT NULL;

-- Update don_vi_nhan in phieu_chi to match
UPDATE phieu_chi pc
SET don_vi_nhan = dv.ten_don_vi
FROM ho_so_tam_ung hs
JOIN don_vi dv ON dv.id = hs.don_vi_id
WHERE pc.ho_so_id = hs.id;

COMMIT;
