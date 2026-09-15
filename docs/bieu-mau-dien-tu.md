# Biểu mẫu Điện tử đã Xây dựng và Số hóa

**Hệ thống Quản lý Tạm ứng Tài chính Công đoàn — CĐCS ĐH Y Dược TP.HCM**

> Căn cứ Quy trình tạm ứng tài chính công đoàn, mã số **ĐHYD-CĐ/QT.02**, phiên bản 1.0, ngày hiệu lực 16/7/2025.

---

## Tổng quan

Hệ thống đã số hóa toàn bộ **5 biểu mẫu giấy chính thức** trong quy trình tạm ứng tài chính công đoàn (C42-HD, C41-BB, HSTU-01, HSTU-02, HSTU-03), đồng thời bổ sung **3 biểu mẫu quy trình nội bộ** để số hóa các bước tiếp nhận, kiểm tra, phê duyệt và lưu trữ — tổng cộng **8 biểu mẫu điện tử**.

### Quy trình 6 bước (theo ĐHYD-CĐ/QT.02)

| Bước | Tên bước | Trách nhiệm | Thời gian giải quyết | Biểu mẫu |
|------|----------|-------------|----------------------|-----------|
| 1 | Nộp hồ sơ tạm ứng | Người có nhu cầu tạm ứng | — | C42-HD, HSTU-01/02, HSTU-03 |
| 2 | Tiếp nhận hồ sơ | Chuyên viên VPCĐ | 1 ngày làm việc | — |
| 3 | Kiểm tra tính hợp lệ | Phụ trách Kế toán CĐCS | 3 ngày làm việc | — |
| 4 | Duyệt hồ sơ tạm ứng | Chủ tịch CĐCS | 1 ngày làm việc | — |
| 5 | Thực hiện chi tạm ứng | Thủ quỹ / Kế toán | 3 ngày làm việc | C41-BB |
| 6 | Kiểm tra, lưu hồ sơ | Kế toán + Chuyên viên VPCĐ | 3 ngày làm việc | — |

---

## Biểu mẫu chính thức (theo quy trình)

### 1. Giấy đề nghị tạm ứng (Mẫu C42-HD)

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mã biểu mẫu gốc** | C42-HD |
| **Tên chính thức** | Giấy đề nghị tạm ứng |
| **Bước quy trình** | Bước 1 — Người đề nghị tạo hồ sơ |
| **Đường dẫn** | `/requests/new` (Bước 1 của stepper) |

**So sánh trường thông tin:**

| Trường (biểu mẫu giấy) | Trường (hệ thống số) | Ghi chú |
|------------------------|---------------------|---------|
| Kính gửi | *(tự động)* | Mặc định gửi Chủ tịch CĐCS |
| Tên tôi là | *(tự động)* | Lấy từ tài khoản đăng nhập |
| CĐBP/Tổ CĐ | `don_vi_id` | Chọn từ danh sách đơn vị |
| Lý do tạm ứng | `ly_do` | Bắt buộc |
| Đề nghị tạm ứng số tiền | `so_tien_de_nghi` | Tự tính từ bảng dự trù |
| Số tiền bằng chữ | *(tự động)* | Hệ thống tự chuyển đổi |
| Thời hạn thanh toán | `thoi_han_thanh_toan` | Bắt buộc |
| *(bổ sung)* | `loai_du_tru` | Chọn HSTU-01 hoặc HSTU-02 để xác định loại dự trù — bắt buộc |
| *(bổ sung)* | `thang_nam` | Áp dụng khi chọn HSTU-01 |
| *(bổ sung)* | `ten_phong_trao` | Áp dụng khi chọn HSTU-02 |

**Phần ký duyệt (biểu mẫu giấy):**

| Người ký | Số hóa |
|----------|--------|
| Người đề nghị | Tự động ghi nhận khi nộp hồ sơ |
| Chủ tịch CĐBP / Tổ trưởng CĐ | *(không áp dụng — quy trình số bỏ qua bước ký duyệt đơn vị)* |
| Phụ trách Kế toán | Ghi nhận tại Bước 3 (kiểm tra hợp lệ) |
| Chủ tịch CĐCS — Duyệt tạm ứng | Ghi nhận tại Bước 4 (phê duyệt) |

---

### 2. Dự trù kinh phí hoạt động tháng (Mẫu HSTU-01)

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mã biểu mẫu gốc** | HSTU-01 |
| **Tên chính thức** | Dự trù kinh phí hoạt động tháng |
| **Bước quy trình** | Bước 1 — Đính kèm trong hồ sơ đề nghị |
| **Đường dẫn** | `/requests/new` (Bước 2 của stepper) |
| **Điều kiện** | Hiển thị khi `loai_du_tru = HSTU-01` |

**So sánh cột:**

| Cột (biểu mẫu giấy) | Cột (hệ thống số) | Ghi chú |
|---------------------|-------------------|---------|
| STT | STT | Tự động đánh số |
| Nội dung | `noi_dung` | — |
| Số tiền | `don_gia` | Đã thống nhất tên hiển thị "Số tiền" theo biểu mẫu giấy |
| Số lượng | `so_luong` | — |
| ĐVT | `don_vi_tinh` | — |
| Thành tiền | *(tự tính)* | = Số tiền × Số lượng |
| Ghi chú | `ghi_chu` | — |

**Footer:** Tổng cộng (tự động), Số tiền bằng chữ (tự động)

---

### 3. Dự trù kinh phí hoạt động phong trào/chuyên đề (Mẫu HSTU-02)

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mã biểu mẫu gốc** | HSTU-02 |
| **Tên chính thức** | Dự trù kinh phí hoạt động phong trào/chuyên đề |
| **Bước quy trình** | Bước 1 — Đính kèm trong hồ sơ đề nghị |
| **Đường dẫn** | `/requests/new` (Bước 2 của stepper) |
| **Điều kiện** | Hiển thị khi `loai_du_tru = HSTU-02` |

Cấu trúc cột giống HSTU-01. Khác biệt ở phần tiêu đề: hiển thị tên phong trào/chuyên đề thay vì tháng/năm.

---

### 4. Danh sách ký nhận (Mẫu HSTU-03)

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mã biểu mẫu gốc** | HSTU-03 |
| **Tên chính thức** | Danh sách ký nhận |
| **Bước quy trình** | Bước 1 — Đính kèm trong hồ sơ (nếu có ký nhận) |
| **Đường dẫn** | `/requests/new` (Bước 3 của stepper) |
| **Điều kiện** | Tùy chọn — chỉ bắt buộc khi có người nhận trực tiếp |

**So sánh cột:**

| Cột (biểu mẫu giấy) | Cột (hệ thống số) | Ghi chú |
|---------------------|-------------------|---------|
| STT | STT | Tự động đánh số |
| Họ tên | `ho_ten` | — |
| Số tiền (đ) | `so_tien` | — |
| Số ngày | `so_ngay` | — |
| Thành tiền (đ) | *(tự tính)* | = Số tiền × Số ngày |
| Ký nhận | *(không áp dụng)* | Biểu mẫu giấy yêu cầu ký tay; hệ thống số ghi nhận điện tử |

**Footer:** Cộng (tự động), Số tiền bằng chữ (tự động)

---

### 5. Phiếu chi (Mẫu C41-BB)

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mã biểu mẫu gốc** | C41-BB |
| **Tên chính thức** | Phiếu chi |
| **Bước quy trình** | Bước 5 — Thủ quỹ lập phiếu chi sau khi hồ sơ được phê duyệt |
| **Đường dẫn** | `/requests/:id` (Tab thao tác khi trạng thái "Đã duyệt") |

**So sánh trường thông tin:**

| Trường (biểu mẫu giấy) | Trường (hệ thống số) | Ghi chú |
|------------------------|---------------------|---------|
| Ngày...tháng...năm | `ngay_chi` | — |
| Số | `ma_phieu_chi` | Tự sinh theo năm |
| Quyển số | `quyen_so` | — |
| Nợ / Có | *(không áp dụng)* | Tài khoản kế toán — xử lý ngoài hệ thống |
| Họ và tên người nhận tiền | *(tự động)* | Lấy từ hồ sơ đề nghị |
| CĐBP/Tổ CĐ | *(tự động)* | Lấy từ đơn vị trong hồ sơ |
| Nội dung | *(tự động)* | Lấy từ lý do tạm ứng |
| Số tiền | `so_tien` | — |
| Số tiền bằng chữ | *(tự động)* | Hệ thống tự chuyển đổi |
| Kèm theo | *(không áp dụng)* | — |
| *(bổ sung)* | `hinh_thuc_chi` | Tiền mặt / Chuyển khoản |
| *(bổ sung)* | Thông tin ngân hàng | Áp dụng khi chuyển khoản |

**Phần ký duyệt (biểu mẫu giấy):**

| Người ký | Số hóa |
|----------|--------|
| Chủ tịch CĐCS | Đã duyệt ở Bước 4 |
| Phụ trách Kế toán | Đã kiểm tra ở Bước 3 |
| Người lập (Thủ quỹ) | Ghi nhận khi lập phiếu chi |
| Thủ quỹ — Đã nhận đủ số tiền | Ghi nhận khi xác nhận chi |
| Người nhận tiền | *(không áp dụng — xác nhận ngoài hệ thống)* |

---

## Biểu mẫu quy trình nội bộ (bổ sung số hóa)

Các biểu mẫu sau không có mẫu giấy trong quy trình chính thức, được hệ thống bổ sung để số hóa hoàn toàn các bước trung gian:

### 6. Phiếu tiếp nhận hồ sơ

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | *(Không có — bổ sung số hóa)* |
| **Bước quy trình** | Bước 2 — Chuyên viên VPCĐ tiếp nhận |
| **Đường dẫn** | `/requests/:id` (Nút "Tiếp nhận" khi trạng thái "Chờ tiếp nhận") |
| **Các trường thông tin** | Ghi chú tiếp nhận, thời gian tiếp nhận (tự động) |
| **Tính năng** | Ghi nhận lịch sử, tự động thông báo cho kế toán |
| **SLA** | 1 ngày làm việc (theo quy trình) |

---

### 7. Phiếu kiểm tra hợp lệ

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | *(Không có — bổ sung số hóa)* |
| **Bước quy trình** | Bước 3 — Phụ trách Kế toán kiểm tra |
| **Đường dẫn** | `/requests/:id` (Nút "Hợp lệ" / "Yêu cầu bổ sung" khi trạng thái "Chờ kiểm tra") |
| **Các trường thông tin** | Ghi chú kiểm tra, kết quả (hợp lệ/cần bổ sung), lý do bổ sung |
| **Tính năng** | AI hỗ trợ kiểm tra bất thường, tự động thông báo cho chủ tịch hoặc người đề nghị |
| **SLA** | 3 ngày làm việc (theo quy trình) |

---

### 8. Phiếu phê duyệt

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | *(Không có — bổ sung số hóa)* |
| **Bước quy trình** | Bước 4 — Chủ tịch CĐCS phê duyệt |
| **Đường dẫn** | `/requests/:id` (Nút "Phê duyệt" / "Từ chối" khi trạng thái "Chờ duyệt") |
| **Các trường thông tin** | Ghi chú phê duyệt, số tiền duyệt (có thể điều chỉnh), kết quả (duyệt/từ chối/yêu cầu bổ sung) |
| **Tính năng** | AI gợi ý nhận xét, AI tóm tắt hồ sơ, tự động thông báo cho thủ quỹ và kế toán |
| **SLA** | 1 ngày làm việc (theo quy trình) |

---

## Tổng hợp

| # | Mã biểu mẫu | Tên biểu mẫu | Bước | Người thực hiện | Loại | Trạng thái |
|---|-------------|--------------|------|-----------------|------|------------|
| 1 | C42-HD | Giấy đề nghị tạm ứng | 1 | Người đề nghị | Chính thức | Hoàn thành |
| 2 | HSTU-01 | Dự trù kinh phí hoạt động tháng | 1 | Người đề nghị | Chính thức | Hoàn thành |
| 3 | HSTU-02 | Dự trù kinh phí phong trào/chuyên đề | 1 | Người đề nghị | Chính thức | Hoàn thành |
| 4 | HSTU-03 | Danh sách ký nhận | 1 | Người đề nghị | Chính thức | Hoàn thành |
| 5 | C41-BB | Phiếu chi | 5 | Thủ quỹ | Chính thức | Hoàn thành |
| 6 | — | Phiếu tiếp nhận hồ sơ | 2 | Chuyên viên VPCĐ | Bổ sung | Hoàn thành |
| 7 | — | Phiếu kiểm tra hợp lệ | 3 | Phụ trách Kế toán | Bổ sung | Hoàn thành |
| 8 | — | Phiếu phê duyệt | 4 | Chủ tịch CĐCS | Bổ sung | Hoàn thành |

> **5 biểu mẫu chính thức** theo quy trình ĐHYD-CĐ/QT.02 đã được số hóa 100%.
> **3 biểu mẫu bổ sung** do hệ thống tạo ra để số hóa các bước trung gian không có mẫu giấy.

---

## Cải tiến so với quy trình giấy

| # | Cải tiến | Mô tả |
|---|----------|-------|
| 1 | Tự động tính toán | Thành tiền, tổng cộng, số tiền bằng chữ được tự động tính |
| 2 | Tự động điền thông tin | Tên người đề nghị, đơn vị, nội dung chi tự động lấy từ hồ sơ |
| 3 | Phân quyền chặt chẽ | 5 vai trò, mỗi vai trò chỉ thấy và thao tác phần mình phụ trách |
| 4 | Theo dõi SLA | Hệ thống cảnh báo khi sắp hết hạn xử lý theo thời gian quy định |
| 5 | Thông báo tự động | Tự động thông báo cho người liên quan khi hồ sơ chuyển trạng thái |
| 6 | Hỗ trợ AI | Tóm tắt, kiểm tra bất thường, gợi ý nhận xét bằng AI |
| 7 | Lưu trữ điện tử | Đáp ứng yêu cầu lưu trữ 10 năm theo quy trình |
| 8 | Hỗ trợ chuyển khoản | Bổ sung hình thức chi chuyển khoản ngoài tiền mặt |

---

## Tài liệu tham khảo

- Quy trình tạm ứng tài chính công đoàn — Mã số: ĐHYD-CĐ/QT.02, Phiên bản 1.0
- Quyết định số 4290/QĐ-TLĐ ngày 01/3/2022 của Tổng LĐLĐ Việt Nam
- Hướng dẫn số 47/HD-TLĐ ngày 30/12/2021 của Tổng LĐLĐ Việt Nam
- Quyết định 7201/QĐ-TLĐ ngày 18/5/2023 của Tổng LĐLĐ Việt Nam
- Thông tư số 24/2024/TT-BTC ngày 17/4/2024 của Bộ Tài chính
