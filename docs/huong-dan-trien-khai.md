# Hướng dẫn Triển khai Hệ thống

**Hệ thống Quản lý Tạm ứng Tài chính Công đoàn — CĐCS ĐH Y Dược TP.HCM**

---

## 1. Yêu cầu hệ thống

| Thành phần | Yêu cầu tối thiểu |
|-----------|-------------------|
| Docker Desktop | Phiên bản 4.0+ (hỗ trợ Docker Compose V2) |
| Node.js | Phiên bản 20 LTS trở lên |
| Git | Phiên bản 2.30+ |
| RAM | 4 GB trở lên |
| Ổ cứng | 2 GB trống |
| Trình duyệt | Chrome, Firefox, Edge (phiên bản mới nhất) |

---

## 2. Cấu trúc dự án

```
quy-trinh-tam-ung/
├── client/                 # Vue 3 + Vuetify 4 Frontend
│   ├── src/
│   │   ├── api/            # Gọi API (axios)
│   │   ├── components/     # Components dùng chung
│   │   ├── plugins/        # Vuetify config
│   │   ├── router/         # Vue Router
│   │   ├── stores/         # Pinia stores
│   │   ├── utils/          # Tiện ích (format tiền, constants)
│   │   ├── views/          # Các trang chính
│   │   ├── App.vue
│   │   └── main.js
│   ├── package.json
│   └── vite.config.js
├── server/                 # Express.js REST API
│   ├── routes/             # Route handlers
│   ├── middleware/         # JWT auth middleware
│   ├── app.js             # Entry point
│   ├── db.js              # PostgreSQL connection pool
│   ├── Dockerfile
│   └── package.json
├── db/
│   └── init.sql           # Database schema + seed data
├── docs/                   # Tài liệu
│   ├── screenshots/        # Ảnh chụp màn hình thật
│   ├── quy-trinh-tam-ung.md
│   ├── huong-dan-su-dung.md
│   └── huong-dan-trien-khai.md
├── Dockerfile              # Multi-stage build (Railway/Cloud)
├── railway.toml            # Cấu hình Railway
├── docker-compose.yml      # Orchestration (local)
└── .env                    # Biến môi trường (tạo thủ công)
```

---

## 3. Cài đặt và khởi chạy

### Bước 1: Clone dự án

```bash
git clone https://github.com/huynhanhdao1234/ump-quy-trinh-tam-ung.git
cd ump-quy-trinh-tam-ung
```

### Bước 2: Tạo file biến môi trường

Tạo file `.env` tại thư mục gốc:

```env
# Google Gemini API (cho chức năng AI)
GEMINI_API_KEY=your-google-gemini-api-key

# JWT Secret (thay đổi cho production)
JWT_SECRET=ump-tam-ung-jwt-secret-change-in-production

# Database
DB_PASSWORD=change_me
```

> **Lấy Gemini API Key:** Truy cập https://aistudio.google.com/apikey → tạo API key miễn phí.

### Bước 3: Khởi chạy backend (Docker)

```bash
docker compose up -d
```

Lệnh này sẽ:
- Tạo container **PostgreSQL 17** (port 5432) với database `tam_ung`
- Tự động chạy `db/init.sql` để tạo schema và dữ liệu mẫu
- Tạo container **API server** (port 3000) kết nối PostgreSQL

Kiểm tra trạng thái:

```bash
docker compose ps        # Xem trạng thái containers
docker compose logs api  # Xem log API server
```

### Bước 4: Khởi chạy frontend

```bash
cd client
npm install
npm run dev
```

### Bước 5: Truy cập hệ thống

Mở trình duyệt tại: **http://localhost:5173**

Đăng nhập với tài khoản demo (xem [Hướng dẫn sử dụng](huong-dan-su-dung.md#tài-khoản-demo)).

---

## 4. Biến môi trường

### API Server (docker-compose.yml / .env)

| Biến | Mô tả | Giá trị mặc định |
|------|--------|-------------------|
| `DATABASE_URL` | Connection string (Railway) | *(tự động từ Railway)* |
| `DB_HOST` | Hostname PostgreSQL | `postgres` (Docker) |
| `DB_PORT` | Port PostgreSQL | `5432` |
| `DB_NAME` | Tên database | `tam_ung` |
| `DB_USER` | User database | `appuser` |
| `DB_PASSWORD` | Mật khẩu database | `change_me` |
| `JWT_SECRET` | Secret key cho JWT | *(thay đổi cho production)* |
| `PORT` | Port API server | `3000` |
| `GEMINI_API_KEY` | Google Gemini API key | *(bắt buộc cho AI)* |

### Frontend (client/.env)

| Biến | Mô tả | Giá trị mặc định |
|------|--------|-------------------|
| `VITE_API_URL` | URL API server | `/api` (proxy qua Vite) |

---

## 5. Quản lý Database

### Kết nối trực tiếp

```bash
docker exec -it postgres psql -U appuser -d tam_ung
```

### Reset database (xóa toàn bộ dữ liệu và tạo lại)

```bash
docker compose down -v
docker compose up -d
```

> **Cảnh báo:** Lệnh `down -v` sẽ xóa toàn bộ volume, bao gồm dữ liệu database. Chỉ dùng khi muốn khởi tạo lại từ đầu.

### Sao lưu database

```bash
# Sao lưu toàn bộ database
docker exec postgres pg_dump -U appuser tam_ung > backup_$(date +%Y%m%d_%H%M%S).sql

# Khôi phục từ bản sao lưu
docker exec -i postgres psql -U appuser -d tam_ung < backup_20260913_120000.sql
```

### Sao lưu tự động (cron job — Linux/macOS)

```bash
# Thêm vào crontab: sao lưu hàng ngày lúc 2:00 AM
0 2 * * * docker exec postgres pg_dump -U appuser tam_ung > /backup/tam_ung_$(date +\%Y\%m\%d).sql
```

---

## 6. Triển khai lên Railway (Cloud)

Railway cho phép triển khai miễn phí với PostgreSQL + Web service.

### Bước 1: Chuẩn bị

1. Tạo tài khoản [Railway](https://railway.app) (khuyến nghị đăng ký bằng GitHub)
2. Fork hoặc push repo lên GitHub

### Bước 2: Tạo project

1. Vào Railway Dashboard → **New Project**
2. **Add PostgreSQL** → Railway tạo database tự động
3. **Add Service** → chọn **GitHub Repo** → chọn repo `ump-quy-trinh-tam-ung`

### Bước 3: Cấu hình biến môi trường

Chọn **web service** → tab **Variables** → thêm:

| Biến | Giá trị |
|------|---------|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` *(reference variable)* |
| `JWT_SECRET` | Chuỗi bí mật bất kỳ (32+ ký tự) |
| `GEMINI_API_KEY` | API key từ [Google AI Studio](https://aistudio.google.com/apikey) |
| `PORT` | `3000` |

### Bước 4: Generate domain

1. Web service → tab **Settings** → **Networking** → **Generate Domain**
2. Railway cung cấp URL dạng: `https://web-production-xxxxx.up.railway.app`

### Bước 5: Kiểm tra

- Database tự khởi tạo schema + dữ liệu mẫu khi service khởi động lần đầu
- Truy cập URL Railway → đăng nhập bằng tài khoản demo
- Railway tự động redeploy mỗi khi push code lên GitHub

---

## 7. Triển khai Production (Self-hosted)

### Build frontend

```bash
cd client
npm run build
```

Kết quả build nằm trong `client/dist/`.

### Phục vụ frontend qua Nginx

Tạo file `nginx.conf`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /var/www/tam-ung/client/dist;
    index index.html;

    location /api {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Checklist triển khai production

- [ ] Thay đổi `DB_PASSWORD` trong docker-compose.yml và .env
- [ ] Thay đổi `JWT_SECRET` thành chuỗi ngẫu nhiên dài (32+ ký tự)
- [ ] Cấu hình `GEMINI_API_KEY` hợp lệ
- [ ] Bật HTTPS (SSL/TLS) cho domain
- [ ] Cấu hình backup tự động
- [ ] Giới hạn CORS origin (thay `origin: true` bằng domain cụ thể)
- [ ] Cấu hình firewall: chỉ mở port 80/443, đóng port 5432/3000

---

## 8. An toàn dữ liệu

Hệ thống được thiết kế với các biện pháp bảo mật sau:

### Xác thực và phân quyền

- **JWT (JSON Web Token):** Mỗi request API đều yêu cầu token hợp lệ trong header `Authorization`.
- **Bcrypt password hashing:** Mật khẩu được hash bằng bcrypt (cost factor 10) trước khi lưu database. Không lưu mật khẩu dạng plain text.
- **Phân quyền theo vai trò (RBAC):** 5 vai trò với quyền hạn khác nhau. API kiểm tra vai trò trước khi cho phép thao tác.

### Bảo vệ dữ liệu

- **Parameterized SQL queries:** Tất cả truy vấn sử dụng tham số hóa (`$1, $2, ...`) để ngăn chặn SQL injection.
- **Input validation:** Dữ liệu đầu vào được kiểm tra trước khi xử lý.
- **Helmet.js:** Thiết lập các HTTP security headers (CSP, HSTS, X-Frame-Options, ...).
- **CORS:** Kiểm soát nguồn gốc request.

### Nhật ký kiểm toán (Audit Trail)

- Bảng `lich_su_phe_duyet` ghi lại mọi thao tác trên hồ sơ: ai làm, làm gì, khi nào, ghi chú.
- Bảng `thong_bao` lưu lịch sử thông báo.
- Timestamps (`created_at`, `updated_at`) trên tất cả bảng dữ liệu.

### Cách ly môi trường

- **Docker containers:** Database và API chạy trong container riêng biệt.
- **Docker volumes:** Dữ liệu database được lưu trên named volume, không mất khi restart container.
- **Network isolation:** Chỉ API container có thể truy cập database container.

### AI và quyền riêng tư

- Chức năng AI gọi Google Gemini API qua backend (không gọi trực tiếp từ browser).
- Dữ liệu gửi đến Gemini chỉ bao gồm nội dung hồ sơ cần xử lý, không gửi thông tin xác thực.
- Tất cả kết quả AI phải qua kiểm duyệt của người dùng trước khi được sử dụng.

---

## 9. Xử lý sự cố

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|------------|-----------|
| Không kết nối được database | Container chưa sẵn sàng | `docker compose ps` kiểm tra trạng thái, đợi healthcheck pass |
| Login thất bại | Sai email/mật khẩu | Kiểm tra lại tài khoản demo trong tài liệu |
| AI không hoạt động | Thiếu GEMINI_API_KEY | Tạo API key tại aistudio.google.com và cấu hình trong .env |
| Port 5432 đã dùng | PostgreSQL local đang chạy | Dừng PostgreSQL local hoặc đổi port trong docker-compose.yml |
| Frontend không load | Vite dev server chưa chạy | `cd client && npm run dev` |
| Dữ liệu không hiển thị | Database chưa được init | `docker compose down -v && docker compose up -d` |
