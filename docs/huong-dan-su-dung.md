# Hướng dẫn Sử dụng Hệ thống Quản lý Tạm ứng

**Hệ thống Quản lý Tạm ứng Tài chính Công đoàn — CĐCS ĐH Y Dược TP.HCM**

---

## 1. Đăng nhập hệ thống

1. Truy cập địa chỉ hệ thống: `http://localhost:8080`
2. Nhập **Email** và **Mật khẩu** được cấp.
3. Nhấn **Đăng nhập**.
4. Hệ thống sẽ tự động chuyển đến trang **Tổng quan** phù hợp với vai trò của bạn.

### Tài khoản demo

| Vai trò | Email | Mật khẩu | Mô tả |
|---------|-------|-----------|-------|
| Chủ tịch CĐCS | `bao.tq@ump.edu.vn` | `ct123456` | Phê duyệt, quản trị hệ thống |
| Kế toán CĐ | `ha.ltt@ump.edu.vn` | `kt123456` | Kiểm tra hợp lệ, báo cáo |
| Chuyên viên VPCĐ | `tuan.vm@ump.edu.vn` | `cv123456` | Tiếp nhận hồ sơ |
| Thủ quỹ CĐ | `ngan.dtk@ump.edu.vn` | `tq123456` | Chi tiền, lập phiếu chi |
| Người đề nghị | `long.ph@ump.edu.vn` | `ky123456` | Tạo và theo dõi hồ sơ |

> Các tài khoản người đề nghị khác sử dụng mật khẩu chung: `123456`

---

## 2. Giao diện chung

Sau khi đăng nhập, giao diện gồm:

- **Thanh điều hướng bên trái**: menu chức năng theo vai trò.
- **Thanh trên cùng**: tên hệ thống, nút thông báo (chuông), thông tin người dùng và nút đăng xuất.
- **Vùng nội dung chính**: hiển thị trang đang xem.

---

## 3. Hướng dẫn theo vai trò

### 3.1. Người đề nghị

#### Tạo hồ sơ mới

1. Từ menu, chọn **Tạo hồ sơ mới**.
2. Hệ thống hiển thị biểu mẫu 4 bước:

   **Bước 1 — Thông tin cơ bản:**
   - Lý do tạm ứng (bắt buộc)
   - Tháng/Năm
   - Tên phong trào (nếu có)
   - Thời hạn thanh toán

   **Bước 2 — Bảng dự trù kinh phí:**
   - Thêm từng hạng mục: nội dung, đơn vị tính, đơn giá, số lượng
   - Hệ thống tự tính thành tiền = đơn giá × số lượng
   - Có thể thêm/xóa hạng mục

   **Bước 3 — Danh sách ký nhận:**
   - Thêm người ký nhận: họ tên, số tiền, số ngày
   - Dùng cho trường hợp nhiều người nhận tiền

   **Bước 4 — Xem lại và nộp:**
   - Kiểm tra lại toàn bộ thông tin
   - Nhấn **Lưu nháp** để lưu tạm hoặc **Nộp hồ sơ** để gửi

3. Sau khi nộp, hồ sơ chuyển sang trạng thái **Chờ tiếp nhận**.

#### Theo dõi hồ sơ

- Vào **Hồ sơ của tôi** để xem danh sách hồ sơ đã tạo.
- Nhấn vào mã hồ sơ để xem chi tiết, bao gồm: thông tin, dự trù, ký nhận, lịch sử xử lý.
- Khi hồ sơ ở trạng thái **Cần bổ sung**: nhấn **Sửa** để bổ sung thông tin theo yêu cầu, sau đó nộp lại.

### 3.2. Chuyên viên Văn phòng Công đoàn

#### Tiếp nhận hồ sơ

1. Vào **Hồ sơ tạm ứng** — danh sách hiển thị tất cả hồ sơ.
2. Lọc theo trạng thái **Chờ tiếp nhận** để thấy hồ sơ cần xử lý.
3. Nhấn vào hồ sơ → xem chi tiết.
4. Trong phần **Thao tác**:
   - Nhập ghi chú (tùy chọn)
   - Nhấn **Tiếp nhận** nếu hồ sơ đầy đủ → chuyển sang Kế toán
   - Nhấn **Yêu cầu bổ sung** nếu thiếu thông tin → trả lại người đề nghị

#### Lưu hồ sơ hoàn tất

- Khi hồ sơ ở trạng thái **Đã chi**, nhấn **Hoàn tất** để kết thúc quy trình và lưu trữ.

### 3.3. Kế toán Công đoàn

#### Kiểm tra hồ sơ hợp lệ

1. Vào **Hồ sơ tạm ứng**, lọc trạng thái **Chờ kiểm tra**.
2. Xem chi tiết hồ sơ: kiểm tra bảng dự trù, ký nhận, chứng từ đính kèm.
3. Trong phần **Thao tác**:
   - Nhấn **Hợp lệ** → chuyển sang Chủ tịch phê duyệt
   - Nhấn **Yêu cầu bổ sung** → trả lại người đề nghị

#### Xác nhận chi

- Khi hồ sơ **Đã duyệt**, kế toán nhấn **Xác nhận chi** để ghi nhận chi tiền.

#### Xem báo cáo

- Vào **Báo cáo** để xem thống kê tổng hợp, lọc theo ngày và trạng thái.
- Xuất dữ liệu ra **Excel** hoặc **PDF** bằng các nút tương ứng.

### 3.4. Thủ quỹ Công đoàn

#### Xác nhận chi tiền

1. Vào **Hồ sơ tạm ứng**, lọc trạng thái **Đã duyệt**.
2. Xem chi tiết hồ sơ → kiểm tra số tiền duyệt.
3. Nhấn **Xác nhận chi** → hệ thống tạo phiếu chi C41-BB tự động.
4. Có thể in phiếu chi từ tab **Phiếu chi** trong chi tiết hồ sơ.

### 3.5. Chủ tịch CĐCS

#### Phê duyệt hồ sơ

1. Vào **Hồ sơ tạm ứng**, lọc trạng thái **Chờ duyệt**.
2. Xem chi tiết hồ sơ: thông tin, dự trù, ký nhận, lịch sử.
3. Trong phần **Thao tác**:
   - Nhập **Số tiền duyệt** (có thể điều chỉnh so với đề nghị)
   - Nhập ghi chú
   - Nhấn **Phê duyệt** → chuyển sang bước chi tiền
   - Nhấn **Yêu cầu bổ sung** → trả lại kèm ghi chú
   - Nhấn **Từ chối** → kết thúc hồ sơ kèm lý do

#### Quản trị hệ thống

- Vào **Quản trị** (chỉ Chủ tịch mới thấy menu này):
  - **Tab Người dùng**: quản lý tài khoản, vai trò
  - **Tab Đơn vị**: quản lý danh sách CĐBP và Tổ CĐ
  - **Tab Cấu hình SLA**: điều chỉnh thời hạn xử lý từng bước

---

## 4. Chức năng AI hỗ trợ

Hệ thống tích hợp AI (Google Gemini) hỗ trợ người dùng trong quá trình xử lý hồ sơ:

### 4.1. AI Tóm tắt hồ sơ

- **Vị trí**: Trong trang chi tiết hồ sơ, nhấn nút **AI Tóm tắt**.
- **Chức năng**: Tóm tắt toàn bộ nội dung hồ sơ: lý do, dự trù, trạng thái hiện tại, lịch sử xử lý.
- **Đối tượng sử dụng**: Tất cả vai trò.

### 4.2. AI Kiểm tra hồ sơ

- **Vị trí**: Trong trang chi tiết hồ sơ, nhấn nút **AI Kiểm tra** (hiển thị khi hồ sơ đang chờ kiểm tra hoặc chờ duyệt).
- **Chức năng**: Phân tích hồ sơ và đưa ra nhận xét:
  - Hồ sơ đã đủ thông tin chưa?
  - Số tiền có hợp lý không?
  - Cảnh báo bất thường (nếu có)
- **Đối tượng sử dụng**: Kế toán, Chủ tịch.

### 4.3. AI Gợi ý nhận xét

- **Vị trí**: Trong phần thao tác khi phê duyệt/từ chối/yêu cầu bổ sung, nhấn nút **AI Gợi ý**.
- **Chức năng**: Tạo bản nháp nhận xét phù hợp với hành động và nội dung hồ sơ.
- **Cách dùng**: Nhận xét AI hiển thị trong ô ghi chú → người dùng chỉnh sửa trước khi gửi.

### 4.4. AI Chatbot tra cứu quy trình

- **Vị trí**: Nút chat hình tròn ở **góc phải dưới** màn hình (hiển thị trên mọi trang).
- **Chức năng**: Trả lời câu hỏi về quy trình tạm ứng, ví dụ:
  - "Quy trình tạm ứng gồm mấy bước?"
  - "Ai có quyền phê duyệt?"
  - "Thời hạn xử lý hồ sơ là bao lâu?"
  - "Khi nào cần bổ sung hồ sơ?"

> **Lưu ý quan trọng:** Tất cả kết quả từ AI chỉ mang tính **tham khảo**. Người dùng phải kiểm tra, đánh giá và chỉnh sửa nội dung AI trước khi sử dụng chính thức. Quyết định cuối cùng luôn thuộc về người dùng.

---

## 5. Báo cáo & Thống kê

1. Vào menu **Báo cáo**.
2. Sử dụng bộ lọc:
   - **Từ ngày / Đến ngày**: lọc theo khoảng thời gian
   - **Trạng thái**: chọn một hoặc nhiều trạng thái
3. Xem các chỉ số tổng hợp: tổng hồ sơ, tổng đề nghị, đã duyệt, đã chi.
4. Xem biểu đồ trực quan: phân bổ theo trạng thái, chi tiêu theo tháng.
5. Xuất dữ liệu:
   - **Xuất Excel**: tải file `.xlsx` chứa bảng dữ liệu đã lọc.
   - **Xuất PDF**: tải file `.pdf` báo cáo tổng hợp có tiêu đề, bảng dữ liệu, tổng cộng.

---

## 6. Thông báo

- Hệ thống **tự động gửi thông báo** khi hồ sơ chuyển trạng thái.
- Biểu tượng chuông trên thanh trên cùng hiển thị số thông báo chưa đọc.
- Vào **Thông báo** để xem danh sách đầy đủ.
- Nhấn vào thông báo để đánh dấu đã đọc, hoặc nhấn **Đánh dấu tất cả đã đọc**.

---

## 7. Đăng xuất

Nhấn vào tên người dùng ở góc phải trên → chọn **Đăng xuất**. Phiên đăng nhập sẽ kết thúc và chuyển về trang đăng nhập.
