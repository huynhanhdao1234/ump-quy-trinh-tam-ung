# Hệ thống Quản lý Tạm ứng Tài chính Công đoàn

**CĐCS Đại học Y Dược TP. Hồ Chí Minh**

> Sản phẩm dự thi **"Ứng dụng AI Tự động hóa Công việc tại ĐH Y Dược TP.HCM"**

**Live Demo:** [https://web-production-404e7.up.railway.app](https://web-production-404e7.up.railway.app)

---

## Demo

| Màn hình | Ảnh chụp |
|----------|----------|
| Đăng nhập | ![Login](docs/screenshots/01-login.png?v=4) |
| Tổng quan (Chủ tịch) | ![Dashboard](docs/screenshots/02-dashboard.png?v=4) |
| Danh sách hồ sơ | ![Requests](docs/screenshots/03-requests.png?v=4) |
| Chi tiết hồ sơ + Workflow | ![Detail](docs/screenshots/04-request-detail.png?v=4) |
| AI Tóm tắt & Kiểm tra | ![AI Features](docs/screenshots/05-ai-features.png?v=4) |
| AI Chatbot | ![Chatbot](docs/screenshots/06-ai-chatbot.png?v=4) |
| Báo cáo & Biểu đồ | ![Reports](docs/screenshots/07-reports.png?v=4) |
| Quản trị hệ thống | ![Admin](docs/screenshots/08-admin.png?v=4) |

---

## 1. Quy trình hành chính được số hóa

### 1.1. Hiện trạng (trước khi số hóa)

Quy trình tạm ứng tài chính công đoàn (mã số **ĐHYD-CĐ/QT.02**) hiện đang thực hiện hoàn toàn bằng **giấy tờ thủ công**:

- Người đề nghị **viết tay** hoặc in Giấy đề nghị tạm ứng (C42-HD), bảng dự trù kinh phí (HSTU-01/02), danh sách ký nhận (HSTU-03).
- Hồ sơ giấy được **chuyển tay** qua 5 người (Người đề nghị → Chuyên viên VPCĐ → Kế toán → Chủ tịch CĐCS → Thủ quỹ).
- Theo dõi tiến độ bằng **sổ tay ghi chép**, không có hệ thống tra cứu.
- Thủ quỹ **in** Phiếu chi (C41-BB) từ mẫu giấy, điền thông tin thủ công, dễ sai sót.
- Lưu trữ **bản giấy** trong tủ hồ sơ, khó tìm kiếm, rủi ro mất mát.

### 1.2. Điểm nghẽn

| # | Điểm nghẽn | Hệ quả |
|---|-----------|--------|
| 1 | **Chuyển hồ sơ giấy qua nhiều người** | Mất 2-3 ngày chỉ để hồ sơ đến đúng người xử lý, tổng quy trình có thể kéo dài 3-4 tuần |
| 2 | **Không theo dõi được tiến độ** | Người đề nghị không biết hồ sơ đang ở bước nào, ai đang giữ, phải liên hệ từng người hỏi |
| 3 | **Kiểm tra thủ công** | Kế toán phải kiểm tra từng dòng dự trù, tính toán lại bằng tay, dễ sai sót số liệu |
| 4 | **Thiếu minh bạch** | Không có bằng chứng ai duyệt khi nào, khó quy trách nhiệm khi có vấn đề |
| 5 | **Lưu trữ bản giấy** | Hồ sơ 10 năm chiếm nhiều không gian, khó tìm kiếm, rủi ro cháy/mất/hư hỏng |
| 6 | **Không có SLA** | Không có cơ chế cảnh báo khi quá hạn xử lý, hồ sơ có thể bị "quên" |

### 1.3. Giải pháp số hóa

Hệ thống **số hóa toàn bộ quy trình** xử lý trực tuyến, đồng thời hỗ trợ **in ấn biểu mẫu giấy** khi cần lưu trữ bản cứng theo quy định:

```
Tạo hồ sơ → Tiếp nhận → Kiểm tra → Phê duyệt → Chi tiền → Lưu trữ
(Đoàn viên)  (Chuyên viên) (Kế toán)  (Chủ tịch)  (Thủ quỹ)  (Chuyên viên)
```

- **Mỗi bước** tự động chuyển đến đúng người xử lý tiếp theo
- **Thông báo** gửi ngay khi hồ sơ cần xử lý
- **SLA** cấu hình thời hạn xử lý từng bước (Chủ tịch quản lý)
- **AI** hỗ trợ kiểm tra, tóm tắt, gợi ý nhận xét
- **Xuất biểu mẫu** — hệ thống tự động điền dữ liệu vào biểu mẫu, hỗ trợ in bản giấy khi cần lưu trữ theo quy định

> Chi tiết quy trình: [`docs/quy-trinh-tam-ung.md`](docs/quy-trinh-tam-ung.md)

---

## 2. Biểu mẫu điện tử đã xây dựng và số hóa

Hệ thống đã số hóa **5 biểu mẫu giấy chính thức** theo quy trình ĐHYD-CĐ/QT.02 và bổ sung **3 biểu mẫu nội bộ**:

| # | Mã biểu mẫu | Tên biểu mẫu | Bước | Người thực hiện | Loại |
|---|-------------|--------------|------|-----------------|------|
| 1 | C42-HD | Giấy đề nghị tạm ứng | 1 | Người đề nghị | Chính thức |
| 2 | HSTU-01 | Dự trù kinh phí hoạt động tháng | 1 | Người đề nghị | Chính thức |
| 3 | HSTU-02 | Dự trù kinh phí phong trào/chuyên đề | 1 | Người đề nghị | Chính thức |
| 4 | HSTU-03 | Danh sách ký nhận | 1 | Người đề nghị | Chính thức |
| 5 | C41-BB | Phiếu chi | 5 | Thủ quỹ | Chính thức |
| 6 | — | Phiếu tiếp nhận hồ sơ | 2 | Chuyên viên VPCĐ | Bổ sung |
| 7 | — | Phiếu kiểm tra hợp lệ | 3 | Phụ trách Kế toán | Bổ sung |
| 8 | — | Phiếu phê duyệt | 4 | Chủ tịch CĐCS | Bổ sung |

**Cải tiến so với biểu mẫu giấy:**
- Tự động tính thành tiền, tổng cộng, số tiền bằng chữ
- Tự động điền tên người đề nghị, đơn vị, nội dung chi từ hồ sơ
- Mã phiếu chi tự sinh theo năm, hỗ trợ chi tiền mặt + chuyển khoản
- Thêm/xóa dòng linh hoạt trong bảng dự trù và danh sách ký nhận

> Chi tiết so sánh từng trường: [`docs/bieu-mau-dien-tu.md`](docs/bieu-mau-dien-tu.md)

---

## 3. Dữ liệu giả lập để demo

Hệ thống **tự động tạo dữ liệu mẫu** khi khởi tạo database, bao gồm:

### 3.1. Cơ cấu tổ chức

| Loại | Số lượng | Chi tiết |
|------|----------|---------|
| Công đoàn Bộ phận (CĐBP) | 9 | Trường Y, Khoa RHM, Trường Dược, Khoa YTCC, Trường ĐD-KTYH, BV ĐHYD, Khoa YHCT, Khoa KHCB, KTX |
| Tổ Công đoàn (Tổ CĐ) | 17 | Các Phòng/Trung tâm/Thư viện |
| **Tổng đơn vị** | **26** | |

### 3.2. Người dùng

| Loại | Số lượng | Chi tiết |
|------|----------|---------|
| Tài khoản quản trị (5 vai trò) | 5 | Chủ tịch, Kế toán, Chuyên viên, Thủ quỹ, Người đề nghị |
| Tài khoản người đề nghị | 15 | Từ các CĐBP và Tổ CĐ khác nhau |
| **Tổng tài khoản** | **20** | |

### 3.3. Hồ sơ tạm ứng

| Loại | Số lượng | Chi tiết |
|------|----------|---------|
| Hồ sơ mẫu | 12 | Đại diện **9 trạng thái** khác nhau trong quy trình |
| Dự trù kinh phí | ~40 dòng | Đính kèm trong các hồ sơ |
| Danh sách ký nhận | ~25 dòng | Đính kèm trong các hồ sơ |
| Phiếu chi C41-BB | 3 | Cho các hồ sơ đã chi/hoàn tất |
| Lịch sử xử lý | ~50 bản ghi | Ghi nhận toàn bộ quá trình xử lý |
| Thông báo | ~30 bản ghi | Thông báo tự động từ database triggers |

### 3.4. Cấu hình SLA

| Bước | Thời hạn |
|------|----------|
| Tiếp nhận hồ sơ | 1 ngày làm việc |
| Kiểm tra hợp lệ | 3 ngày làm việc |
| Phê duyệt | 1 ngày làm việc |
| Chi tạm ứng | 3 ngày làm việc |
| Lưu hồ sơ | 3 ngày làm việc |

> Toàn bộ dữ liệu mẫu được khởi tạo từ: [`db/init.sql`](db/init.sql)

---

## 4. Các trạng thái xử lý của hồ sơ

Mỗi hồ sơ tạm ứng đi qua các trạng thái sau:

```
                                    ┌─────────────┐
                                    │  Cần bổ sung │◄──── Kế toán/Chủ tịch yêu cầu bổ sung
                                    └──────┬──────┘
                                           │ Người đề nghị bổ sung & nộp lại
                                           ▼
┌───────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Nháp  │───►│ Chờ tiếp nhận│───►│ Chờ kiểm tra│───►│ Chờ duyệt│───►│ Đã duyệt │───►│  Đã chi  │───►│ Hoàn tất │
└───────┘    └──────────────┘    └─────────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
 Người         Chuyên viên          Kế toán          Chủ tịch        Thủ quỹ        Kế toán +
 đề nghị       VPCĐ tiếp nhận       kiểm tra         phê duyệt       chi tiền       Chuyên viên
                                                        │                            lưu hồ sơ
                                                        │
                                                        ▼
                                                   ┌──────────┐
                                                   │ Từ chối  │
                                                   └──────────┘
```

| Trạng thái | Mã hệ thống | Ý nghĩa | Người xử lý tiếp |
|-----------|-------------|---------|-------------------|
| Nháp | `nhap` | Hồ sơ đang soạn, chưa nộp | Người đề nghị |
| Chờ tiếp nhận | `cho_tiep_nhan` | Đã nộp, chờ kiểm tra đầy đủ | Chuyên viên VPCĐ |
| Chờ kiểm tra | `cho_kiem_tra` | Đã tiếp nhận, chờ kiểm tra hợp lệ | Kế toán CĐ |
| Cần bổ sung | `can_bo_sung` | Bị trả lại, cần bổ sung thông tin | Người đề nghị |
| Chờ duyệt | `cho_duyet` | Kế toán đã xác nhận, chờ phê duyệt | Chủ tịch CĐCS |
| Đã duyệt | `da_duyet` | Chủ tịch đã phê duyệt, chờ chi tiền | Thủ quỹ + Kế toán |
| Từ chối | `tu_choi` | Chủ tịch từ chối — kết thúc | — |
| Đã chi | `da_chi` | Đã chi tiền cho người đề nghị | Kế toán + Chuyên viên |
| Hoàn tất | `hoan_tat` | Đã lưu trữ, quy trình kết thúc | — |

---

## 5. Luồng tự động hóa

### 5.1. Tự động chuyển bước

Khi người dùng thực hiện thao tác (nhấn nút), hệ thống **tự động**:

| Thao tác | Chuyển trạng thái | Thông báo tự động |
|----------|-------------------|-------------------|
| Nộp hồ sơ | Nháp → Chờ tiếp nhận | Gửi cho Chuyên viên VPCĐ |
| Tiếp nhận | Chờ tiếp nhận → Chờ kiểm tra | Gửi cho Kế toán |
| Xác nhận hợp lệ | Chờ kiểm tra → Chờ duyệt | Gửi cho Chủ tịch CĐCS |
| Yêu cầu bổ sung | Chờ kiểm tra/Chờ duyệt → Cần bổ sung | Gửi cho Người đề nghị |
| Phê duyệt | Chờ duyệt → Đã duyệt | Gửi cho Thủ quỹ + Kế toán |
| Từ chối | Chờ duyệt → Từ chối | Gửi cho Người đề nghị |
| Xác nhận chi | Đã duyệt → Đã chi | Gửi cho Kế toán + Chuyên viên |
| Hoàn tất lưu trữ | Đã chi → Hoàn tất | Gửi cho Người đề nghị |
| Nộp lại sau bổ sung | Cần bổ sung → Chờ tiếp nhận | Gửi cho Chuyên viên VPCĐ |

### 5.2. Database Triggers (PL/pgSQL)

Hệ thống sử dụng **PostgreSQL triggers** để tự động hóa ở tầng database:

| Trigger | Sự kiện | Hành động tự động |
|---------|---------|-------------------|
| `trigger_tao_thong_bao` | Hồ sơ chuyển trạng thái | Tạo thông báo cho người xử lý tiếp theo |
| `trigger_ghi_lich_su` | Hồ sơ thay đổi | Ghi lịch sử xử lý (ai, khi nào, thao tác gì) |
| `trigger_cap_nhat_counter` | Tạo hồ sơ/phiếu chi mới | Tự sinh mã hồ sơ (TU-2026-0001) và mã phiếu chi (PC-2026-0001) |

### 5.3. Cấu hình SLA

- Mỗi bước có **thời hạn tối đa** (cấu hình bởi Chủ tịch CĐCS trong tab Quản trị)
- Tổng thời gian xử lý tối đa: **11 ngày làm việc** (mặc định)
- Chủ tịch có thể điều chỉnh số ngày cho từng bước theo nhu cầu thực tế

---

## 6. Chức năng AI đã tích hợp

Hệ thống tích hợp **4 chức năng AI** sử dụng Google Gemini, tất cả đều có **kiểm soát con người** — kết quả AI chỉ mang tính tham khảo, người dùng luôn xem xét trước khi sử dụng.

### 6.1. AI Tóm tắt hồ sơ

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mục đích** | Tóm tắt nhanh nội dung hồ sơ giúp Chủ tịch nắm bắt thông tin khi phê duyệt |
| **Đầu vào** | Lý do tạm ứng, bảng dự trù, danh sách ký nhận, lịch sử xử lý |
| **Đầu ra** | Đoạn tóm tắt ngắn gọn (3-5 câu) bao gồm: mục đích, tổng số tiền, số hạng mục, trạng thái |
| **Người dùng** | Chủ tịch CĐCS, Kế toán |
| **Kiểm soát** | Kết quả hiển thị trong panel riêng, không ảnh hưởng đến quyết định hệ thống |

### 6.2. AI Kiểm tra bất thường

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mục đích** | Phát hiện các dấu hiệu bất thường trong hồ sơ để hỗ trợ Kế toán kiểm tra |
| **Đầu vào** | Toàn bộ dữ liệu hồ sơ (lý do, dự trù, ký nhận, lịch sử) |
| **Đầu ra** | JSON gồm: điểm hợp lệ (1-10), danh sách cảnh báo, đề xuất |
| **Tiêu chí kiểm tra** | Lý do rõ ràng, dự trù đầy đủ, số tiền hợp lý, tổng khớp, dấu hiệu bất thường |
| **Người dùng** | Kế toán CĐ |
| **Kiểm soát** | Kết quả chỉ tham khảo — Kế toán tự quyết định hợp lệ hay yêu cầu bổ sung |

### 6.3. AI Gợi ý nhận xét

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mục đích** | Dự thảo nhận xét phê duyệt/từ chối phù hợp ngữ cảnh, tiết kiệm thời gian soạn văn bản |
| **Đầu vào** | Nội dung hồ sơ + hành động dự kiến (duyệt/từ chối/bổ sung) |
| **Đầu ra** | 2-3 mẫu nhận xét phù hợp, sẵn sàng chỉnh sửa |
| **Người dùng** | Chủ tịch CĐCS |
| **Kiểm soát** | Nhận xét AI chỉ là gợi ý — Chủ tịch chỉnh sửa trước khi sử dụng |

### 6.4. AI Chatbot tra cứu quy trình

| Thuộc tính | Chi tiết |
|------------|---------|
| **Mục đích** | Tra cứu quy trình, quy định, thời hạn xử lý qua hội thoại tự nhiên |
| **Đầu vào** | Câu hỏi của người dùng |
| **Đầu ra** | Trả lời dựa trên dữ liệu quy trình nội bộ |
| **Người dùng** | Tất cả vai trò |
| **Kiểm soát** | Chatbot trả lời tham khảo, có nút liên hệ VPCĐ nếu cần hỗ trợ thêm |

---

## 7. Đường dẫn sản phẩm và tài khoản demo

### Đường dẫn sản phẩm

**URL:** [https://web-production-404e7.up.railway.app](https://web-production-404e7.up.railway.app)

### Tài khoản demo cho Ban Giám khảo

| Vai trò | Họ tên | Email | Mật khẩu |
|---------|--------|-------|-----------|
| **Chủ tịch CĐCS** | PGS.TS. Trần Quốc Bảo | `bao.tq@ump.edu.vn` | `ct123456` |
| **Kế toán CĐ** | ThS. Lê Thị Thanh Hà | `ha.ltt@ump.edu.vn` | `kt123456` |
| **Chuyên viên VPCĐ** | CN. Võ Minh Tuấn | `tuan.vm@ump.edu.vn` | `cv123456` |
| **Thủ quỹ CĐ** | CN. Đặng Thị Kim Ngân | `ngan.dtk@ump.edu.vn` | `tq123456` |
| **Người đề nghị** | Phạm Hoàng Long | `long.ph@ump.edu.vn` | `ky123456` |

> Các tài khoản người đề nghị khác: mật khẩu chung `123456`

**Gợi ý trải nghiệm cho Ban Giám khảo:**

1. Đăng nhập bằng tài khoản **Chủ tịch** để xem Dashboard tổng quan, phê duyệt hồ sơ, sử dụng AI tóm tắt & gợi ý nhận xét
2. Đăng nhập bằng tài khoản **Người đề nghị** để tạo hồ sơ tạm ứng mới với stepper 4 bước
3. Đăng nhập bằng tài khoản **Kế toán** để kiểm tra hồ sơ, sử dụng AI kiểm tra bất thường
4. Thử **AI Chatbot** (biểu tượng chat góc dưới phải) để tra cứu quy trình

---

## 8. Lợi ích ước tính

### 8.1. Tiết kiệm thời gian

| Hạng mục | Quy trình giấy | Quy trình số | Giảm |
|----------|----------------|-------------|------|
| Chuyển hồ sơ giữa các bước | 2-3 ngày (chuyển tay) | Tức thì (tự động) | **~95%** |
| Kiểm tra dự trù kinh phí | 30-60 phút/hồ sơ (tính tay) | 5-10 phút (AI hỗ trợ + tự động tính) | **~80%** |
| Lập phiếu chi C41-BB | 15-20 phút (viết tay) | 2-3 phút (tự động điền) | **~85%** |
| Tra cứu hồ sơ cũ | 30-60 phút (lục tủ hồ sơ) | < 1 phút (tìm kiếm online) | **~98%** |
| Tổng thời gian quy trình | 15-20 ngày (thực tế) | 3-5 ngày (SLA 11 ngày tối đa) | **~70%** |

### 8.2. Giảm giấy tờ và công sức soạn thảo

| Hạng mục | Trước | Sau | Cải thiện |
|----------|-------|-----|-----------|
| Soạn biểu mẫu | Điền tay hoặc soạn từ đầu trên máy | Hệ thống tự điền dữ liệu, chỉ cần in | **~90%** công sức soạn thảo |
| Sai sót khi điền | Thường xuyên (sai số, thiếu thông tin) | Tự động tính toán, validation bắt buộc | **~95%** sai sót |
| Số lần in/photo | 2-3 bản mỗi biểu mẫu (nháp + chính thức) | In 1 lần bản chính thức từ hệ thống | **~60%** giấy in |
| Lưu trữ điện tử | Chỉ bản giấy, phải scan riêng | Lưu sẵn trên hệ thống, in bản giấy khi cần | Đáp ứng lưu trữ kép (giấy + điện tử) |
| Tra cứu hồ sơ | Lục tủ hồ sơ 30-60 phút | Tìm kiếm online < 1 phút | **~98%** thời gian |

> **Lưu ý:** Bản giấy vẫn cần thiết để ký duyệt và lưu trữ theo quy định. Hệ thống hỗ trợ tạo và in biểu mẫu với dữ liệu đã được điền sẵn, giảm thiểu công sức soạn thảo và sai sót.

### 8.3. Giảm sai sót

| Loại sai sót | Quy trình giấy | Quy trình số | Giải pháp |
|-------------|----------------|-------------|-----------|
| Tính toán sai thành tiền | Thường xuyên | Không xảy ra | Tự động tính |
| Tổng dự trù không khớp | Thỉnh thoảng | Không xảy ra | Tự động cộng |
| Thiếu thông tin bắt buộc | Thường xuyên | Không xảy ra | Validation bắt buộc |
| Mất/thất lạc hồ sơ | Rủi ro cao | Không xảy ra | Lưu trữ cloud |
| Quên xử lý hồ sơ | Thỉnh thoảng | Giảm đáng kể | Thông báo tự động khi có hồ sơ cần xử lý |
| Ghi nhầm số tiền phiếu chi | Có thể | Không xảy ra | Tự động điền từ hồ sơ |

### 8.4. Tóm tắt lợi ích

| Chỉ số | Ước tính |
|--------|----------|
| Thời gian xử lý mỗi hồ sơ | Giảm **~70%** (từ 15-20 ngày xuống 3-5 ngày) |
| Công sức soạn biểu mẫu | Giảm **~90%** (hệ thống tự điền, chỉ cần in bản chính thức) |
| Sai sót tính toán | Giảm **~100%** (tự động tính) |
| Minh bạch quy trình | **Toàn diện** — lịch sử xử lý ghi nhận chi tiết ai/khi nào/thao tác gì |
| Khả năng tra cứu | **Tức thì** — tìm kiếm, lọc, báo cáo online |

---

## Công nghệ

### Backend
- **Runtime:** Node.js + Express.js
- **Database:** PostgreSQL 17 (PL/pgSQL triggers, generated columns, custom enums)
- **Auth:** JWT + bcryptjs
- **AI:** Google Gemini API (`@google/generative-ai`)
- **Security:** Helmet, CORS, role-based middleware

### Frontend
- **Framework:** Vue 3 (Composition API, `<script setup>`)
- **UI:** Vuetify 3 (Material Design)
- **Build:** Vite
- **State:** Pinia
- **Charts:** Chart.js + vue-chartjs
- **Export:** xlsx + file-saver (Excel), jsPDF + jspdf-autotable (PDF, hỗ trợ tiếng Việt)

### Infrastructure
- **Local:** Docker Compose (PostgreSQL + API)
- **Cloud:** Railway (PostgreSQL + Web service)
- **DB Init:** Tự động tạo schema + dữ liệu mẫu khi khởi động

---

## Cài đặt & Chạy

### Yêu cầu
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (bao gồm Docker Compose)
- [Node.js](https://nodejs.org/) >= 18
- [Google Gemini API Key](https://aistudio.google.com/apikey) (cho chức năng AI)

### Bước 1: Clone & cấu hình

```bash
git clone https://github.com/huynhanhdao1234/ump-quy-trinh-tam-ung.git
cd ump-quy-trinh-tam-ung
```

Tạo file `.env` ở thư mục gốc:

```env
GEMINI_API_KEY=your-google-gemini-api-key
```

### Bước 2: Khởi động Backend (Docker)

```bash
docker compose up -d
```

Lệnh này sẽ:
- Khởi tạo PostgreSQL 17 với schema + dữ liệu mẫu
- Chạy API server trên cổng `3000`

Kiểm tra: `docker compose ps` — cả 2 service `postgres` và `api` đều ở trạng thái `running`.

### Bước 3: Khởi động Frontend

```bash
cd client
npm install
npm run dev
```

Truy cập: **http://localhost:5173**

### Triển khai lên Railway (Cloud)

1. Fork repo này trên GitHub
2. Tạo tài khoản [Railway](https://railway.app) (đăng ký bằng GitHub)
3. Tạo project mới → **Add PostgreSQL** database
4. **Add Service** → chọn GitHub repo → Railway sẽ tự build bằng `Dockerfile`
5. Thêm biến môi trường cho web service:
   - `DATABASE_URL` → `${{Postgres.DATABASE_URL}}` (reference variable)
   - `JWT_SECRET` → một chuỗi bí mật bất kỳ
   - `GEMINI_API_KEY` → API key từ Google AI Studio
   - `PORT` → `3000`
6. **Generate Domain** → nhận URL public
7. Database sẽ tự khởi tạo schema + dữ liệu mẫu khi service khởi động lần đầu

---

## Cấu trúc dự án

```
quy-trinh-tam-ung/
├── client/                  # Vue 3 + Vuetify frontend
│   ├── src/
│   │   ├── api/             # HTTP client & API modules
│   │   ├── components/      # UI components (AI cards, charts, chips...)
│   │   ├── plugins/         # Vuetify config
│   │   ├── router/          # Vue Router
│   │   ├── stores/          # Pinia stores (auth, notifications)
│   │   ├── utils/           # Constants, export helpers, money format
│   │   └── views/           # Page components
│   └── vite.config.js
├── server/                  # Express.js API
│   ├── middleware/           # JWT auth middleware
│   ├── routes/              # REST API routes (13 modules)
│   ├── app.js               # Entry point
│   ├── db.js                # PostgreSQL connection pool
│   └── Dockerfile
├── db/
│   └── init.sql             # Schema + triggers + sample data
├── docs/                    # Tài liệu tiếng Việt
│   ├── screenshots/         # Ảnh chụp màn hình thật
│   ├── quy-trinh-tam-ung.md
│   ├── bieu-mau-dien-tu.md
│   ├── huong-dan-su-dung.md
│   └── huong-dan-trien-khai.md
├── docker-compose.yml
└── .env.example
```

---

## Tài liệu

| Tài liệu | File |
|-----------|------|
| Sơ đồ quy trình | [`docs/quy-trinh-tam-ung.md`](docs/quy-trinh-tam-ung.md) |
| Biểu mẫu điện tử đã số hóa | [`docs/bieu-mau-dien-tu.md`](docs/bieu-mau-dien-tu.md) |
| Hướng dẫn sử dụng | [`docs/huong-dan-su-dung.md`](docs/huong-dan-su-dung.md) |
| Hướng dẫn triển khai | [`docs/huong-dan-trien-khai.md`](docs/huong-dan-trien-khai.md) |

---

## Tính năng nổi bật

- **Workflow trực quan** — Thanh tiến trình 6 bước hiển thị vị trí hồ sơ trong quy trình
- **Thông báo tự động** — Database triggers tự động tạo thông báo khi hồ sơ chuyển trạng thái
- **Xuất báo cáo** — Excel (.xlsx) và PDF (hỗ trợ đầy đủ tiếng Việt có dấu)
- **Biểu đồ thống kê** — Dashboard và báo cáo với biểu đồ Doughnut phân bổ trạng thái
- **Responsive** — Giao diện tương thích desktop và mobile
- **Phân quyền nghiêm ngặt** — 5 vai trò, mỗi vai trò chỉ thấy menu và thao tác phù hợp
- **Quản lý đơn vị** — 9 CĐBP + 17 Tổ CĐ, hiển thị đơn vị trên hồ sơ và tài khoản người dùng
- **Dữ liệu mẫu** — 12 hồ sơ ở 9 trạng thái khác nhau, sẵn sàng demo
- **SLA cấu hình** — Chủ tịch có thể điều chỉnh thời hạn xử lý từng bước

---

## API Endpoints

| Nhóm | Prefix | Mô tả |
|------|--------|-------|
| Auth | `/api/auth` | Đăng nhập, kiểm tra session |
| Requests | `/api/requests` | CRUD hồ sơ tạm ứng |
| Workflow | `/api/workflow` | Chuyển trạng thái hồ sơ |
| Estimates | `/api/requests/:id/estimates` | Bảng dự trù kinh phí |
| Sign List | `/api/requests/:id/signlist` | Danh sách ký nhận |
| History | `/api/requests/:id/history` | Lịch sử xử lý |
| Payments | `/api/requests/:id/payment` | Phiếu chi C41-BB |
| Files | `/api/requests/:id/files` | Upload/download đính kèm |
| Users | `/api/users` | Quản lý người dùng |
| Units | `/api/units` | Quản lý đơn vị |
| Notifications | `/api/notifications` | Thông báo |
| Config | `/api/config` | Cấu hình SLA |
| AI | `/api/ai` | 4 endpoints AI (Gemini) |

---

## License

Dự án phục vụ cuộc thi nội bộ tại Đại học Y Dược TP. Hồ Chí Minh.
