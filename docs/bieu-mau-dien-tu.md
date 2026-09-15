# Biểu mẫu Điện tử đã Xây dựng và Số hóa

**Hệ thống Quản lý Tạm ứng Tài chính Công đoàn — CĐCS ĐH Y Dược TP.HCM**

---

## Tổng quan

Hệ thống đã số hóa toàn bộ biểu mẫu giấy trong quy trình tạm ứng tài chính công đoàn, chuyển đổi từ quy trình thủ công sang quy trình điện tử hoàn toàn. Dưới đây là danh sách các biểu mẫu đã được xây dựng và tích hợp vào hệ thống.

---

## 1. Giấy đề nghị tạm ứng

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Giấy đề nghị tạm ứng kinh phí công đoàn |
| **Bước quy trình** | Bước 1 — Người đề nghị tạo hồ sơ |
| **Đường dẫn** | `/requests/new` |
| **Các trường thông tin** | Lý do tạm ứng, đơn vị, loại dự trù, tháng/năm, tên phong trào, thời hạn thanh toán |
| **Xác thực** | Lý do, đơn vị, loại dự trù, thời hạn thanh toán là bắt buộc |

---

## 2. Bảng dự trù kinh phí

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Bảng kê chi tiết dự trù kinh phí |
| **Bước quy trình** | Bước 1 — Đính kèm trong hồ sơ đề nghị |
| **Đường dẫn** | `/requests/new` (Bước 2 của stepper) |
| **Các trường thông tin** | STT, nội dung chi, đơn giá, số lượng, đơn vị tính, thành tiền (tự tính), ghi chú |
| **Tính năng** | Thêm/xóa dòng, tự động tính tổng cộng |

---

## 3. Danh sách ký nhận

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Danh sách ký nhận tiền tạm ứng |
| **Bước quy trình** | Bước 1 — Đính kèm trong hồ sơ đề nghị |
| **Đường dẫn** | `/requests/new` (Bước 3 của stepper) |
| **Các trường thông tin** | STT, họ tên người nhận, số tiền, số ngày, thành tiền (tự tính) |
| **Tính năng** | Thêm/xóa dòng, tự động tính tổng cộng |

---

## 4. Phiếu chi C41-BB

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Phiếu chi tiền mặt C41-BB (Biểu mẫu kế toán) |
| **Bước quy trình** | Bước 5 — Thủ quỹ lập phiếu chi sau khi hồ sơ được phê duyệt |
| **Đường dẫn** | `/requests/:id` (Tab thao tác khi trạng thái "Đã duyệt") |
| **Các trường thông tin** | Mã phiếu chi (tự sinh), quyển số, ngày chi, người nhận, đơn vị nhận, nội dung chi, số tiền, số tiền bằng chữ, hình thức chi (tiền mặt/chuyển khoản), thông tin ngân hàng |
| **Tính năng** | Tự động điền thông tin từ hồ sơ, mã phiếu chi tự sinh theo năm |

---

## 5. Phiếu tiếp nhận hồ sơ

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Biên nhận tiếp nhận hồ sơ tạm ứng |
| **Bước quy trình** | Bước 2 — Chuyên viên VPCĐ tiếp nhận |
| **Đường dẫn** | `/requests/:id` (Nút "Tiếp nhận" khi trạng thái "Chờ tiếp nhận") |
| **Các trường thông tin** | Ghi chú tiếp nhận, thời gian tiếp nhận (tự động) |
| **Tính năng** | Ghi nhận lịch sử, tự động thông báo cho kế toán |

---

## 6. Phiếu kiểm tra hợp lệ

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Biên bản kiểm tra tính hợp lệ của hồ sơ |
| **Bước quy trình** | Bước 3 — Kế toán kiểm tra |
| **Đường dẫn** | `/requests/:id` (Nút "Hợp lệ" / "Yêu cầu bổ sung" khi trạng thái "Chờ kiểm tra") |
| **Các trường thông tin** | Ghi chú kiểm tra, kết quả (hợp lệ/cần bổ sung), lý do bổ sung |
| **Tính năng** | AI hỗ trợ kiểm tra bất thường, tự động thông báo cho chủ tịch hoặc người đề nghị |

---

## 7. Phiếu phê duyệt

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Phiếu phê duyệt tạm ứng của Chủ tịch CĐCS |
| **Bước quy trình** | Bước 4 — Chủ tịch CĐCS phê duyệt |
| **Đường dẫn** | `/requests/:id` (Nút "Phê duyệt" / "Từ chối" khi trạng thái "Chờ duyệt") |
| **Các trường thông tin** | Ghi chú phê duyệt, số tiền duyệt (có thể điều chỉnh), kết quả (duyệt/từ chối/yêu cầu bổ sung) |
| **Tính năng** | AI gợi ý nhận xét, AI tóm tắt hồ sơ, tự động thông báo cho thủ quỹ và kế toán |

---

## 8. Biên bản hoàn tất lưu trữ

| Thuộc tính | Chi tiết |
|------------|---------|
| **Biểu mẫu gốc** | Biên bản xác nhận hoàn tất và lưu trữ hồ sơ |
| **Bước quy trình** | Bước 6 — Chuyên viên/Kế toán xác nhận hoàn tất |
| **Đường dẫn** | `/requests/:id` (Nút "Hoàn tất" khi trạng thái "Đã chi") |
| **Các trường thông tin** | Ghi chú lưu trữ, thời gian hoàn tất (tự động) |
| **Tính năng** | Đánh dấu kết thúc quy trình, ghi nhận ngày hoàn thành |

---

## Tổng hợp

| # | Biểu mẫu | Bước | Người thực hiện | Trạng thái số hóa |
|---|----------|------|-----------------|-------------------|
| 1 | Giấy đề nghị tạm ứng | Bước 1 | Người đề nghị | Hoàn thành |
| 2 | Bảng dự trù kinh phí | Bước 1 | Người đề nghị | Hoàn thành |
| 3 | Danh sách ký nhận | Bước 1 | Người đề nghị | Hoàn thành |
| 4 | Phiếu chi C41-BB | Bước 5 | Thủ quỹ | Hoàn thành |
| 5 | Phiếu tiếp nhận hồ sơ | Bước 2 | Chuyên viên VPCĐ | Hoàn thành |
| 6 | Phiếu kiểm tra hợp lệ | Bước 3 | Kế toán CĐ | Hoàn thành |
| 7 | Phiếu phê duyệt | Bước 4 | Chủ tịch CĐCS | Hoàn thành |
| 8 | Biên bản hoàn tất lưu trữ | Bước 6 | Chuyên viên/Kế toán | Hoàn thành |

> Tất cả 8 biểu mẫu đã được số hóa 100%, tích hợp vào quy trình 6 bước với phân quyền, thông báo tự động, và hỗ trợ AI.
