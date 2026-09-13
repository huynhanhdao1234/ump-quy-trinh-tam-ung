---
name: UMP Trade Union Finance System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#424751'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#727782'
  outline-variant: '#c2c6d3'
  surface-tint: '#1d5fa9'
  primary: '#003b73'
  on-primary: '#ffffff'
  primary-container: '#00529c'
  on-primary-container: '#a5c7ff'
  inverse-primary: '#a7c8ff'
  secondary: '#785900'
  on-secondary: '#ffffff'
  secondary-container: '#fdc003'
  on-secondary-container: '#6c5000'
  tertiary: '#00451e'
  on-tertiary: '#ffffff'
  tertiary-container: '#005f2b'
  on-tertiary-container: '#59de81'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d5e3ff'
  primary-fixed-dim: '#a7c8ff'
  on-primary-fixed: '#001b3b'
  on-primary-fixed-variant: '#004788'
  secondary-fixed: '#ffdf9e'
  secondary-fixed-dim: '#fabd00'
  on-secondary-fixed: '#261a00'
  on-secondary-fixed-variant: '#5b4300'
  tertiary-fixed: '#78fc9c'
  tertiary-fixed-dim: '#5adf82'
  on-tertiary-fixed: '#00210b'
  on-tertiary-fixed-variant: '#005225'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.5px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 20px
  margin-safe: 24px
---

## Brand & Style

Giao diện được thiết kế dựa trên triết lý **Corporate Modern**, kết hợp giữa sự nghiêm túc của môi trường sư phạm y khoa và tính hiệu quả của các công cụ tài chính hiện đại. Mục tiêu tối thượng là tạo ra sự tin cậy, minh bạch và chính xác trong mọi thao tác quản lý tạm ứng.

Phong cách chủ đạo tập trung vào:
- **Sự chuyên nghiệp:** Sử dụng lưới hệ thống chặt chẽ, khoảng trắng rộng rãi để giảm bớt sự căng thẳng khi xử lý số liệu.
- **Tính hệ thống:** Mọi thành phần được module hóa cao, đảm bảo trải nghiệm đồng nhất từ các biểu mẫu (forms) đến các bảng dữ liệu (tables) phức tạp.
- **Phân cấp thị giác:** Sử dụng độ tương phản màu sắc và trọng lượng chữ để hướng dẫn người dùng qua các quy trình phê duyệt đa bước.

## Colors

Hệ thống màu sắc được tinh chỉnh để phản ánh bản sắc của tổ chức Công đoàn trong môi trường Đại học Y Dược:

- **Primary (Professional Blue - #00529C):** Màu xanh chủ đạo đại diện cho sự ổn định, tin cậy và chuyên môn y khoa. Được sử dụng cho các hành động chính, thanh điều hướng và nhận diện thương hiệu.
- **Secondary (Union Gold - #FFC107):** Màu vàng đặc trưng của Công đoàn, được sử dụng làm điểm nhấn cho các thông tin quan trọng, trạng thái chờ và các chỉ báo cần sự chú ý.
- **Semantic Colors:**
    - **Success (#00A651):** Dành cho trạng thái "Đã duyệt" và các thông báo thành công.
    - **Error (#D32F2F):** Dành cho trạng thái "Từ chối" và các cảnh báo lỗi.
    - **Neutral (#F8FAFC / #64748B):** Hệ thống xám nhạt làm nền để tôn vinh dữ liệu và nội dung chữ.

## Typography

Sử dụng phông chữ **Inter** - một phông chữ sans-serif hiện đại, được tối ưu hóa cho màn hình máy tính với độ đọc cao trong các bảng dữ liệu dày đặc.

- **Headline:** Sử dụng trọng lượng Bold (700) cho tiêu đề trang và Semi-bold (600) cho tiêu đề các phân khu (Cards).
- **Body:** Sử dụng kích thước 14px cho dữ liệu bảng để tối ưu không gian hiển thị, và 16px cho các đoạn văn bản hướng dẫn.
- **Labels:** Các nhãn trạng thái (Badges) và tiêu đề cột sử dụng chữ in hoa nhẹ hoặc Semi-bold để phân biệt với dữ liệu động.

## Layout & Spacing

Hệ thống sử dụng **Fluid Grid** 12 cột cho các trang Dashboard và **Fixed Center Layout** (1200px) cho các biểu mẫu nhập liệu để tập trung sự chú ý.

- **Spacing Rhythm:** Dựa trên hệ đơn vị 4px. Khoảng cách 16px (md) là tiêu chuẩn cho padding của card và khoảng cách giữa các phần tử form.
- **Responsive:** 
    - **Desktop (>1024px):** Hiển thị đầy đủ sidebar điều hướng bên trái.
    - **Tablet (768px - 1023px):** Sidebar thu gọn thành icons, bảng dữ liệu cho phép cuộn ngang.
    - **Mobile (<768px):** Chuyển từ bảng sang dạng danh sách thẻ (list cards), form chuyển sang hiển thị 1 cột duy nhất.

## Elevation & Depth

Độ sâu trong thiết kế này được xử lý theo phương pháp **Tonal Layering** để giữ cho giao diện luôn sạch sẽ và chuyên nghiệp:

- **Mặt nền (Level 0):** Sử dụng màu `#F8FAFC`, tạo cảm giác nhẹ nhàng, không gây mỏi mắt.
- **Thẻ nội dung (Level 1):** Màu trắng tinh khiết với shadow cực nhẹ (Blur 10px, Opacity 4%) và viền mỏng 1px màu `#E2E8F0`.
- **Phần tử nổi (Level 2):** Các dropdown, modal phê duyệt sử dụng shadow đậm hơn để tách biệt hẳn với nội dung bên dưới.
- **Trạng thái Focus:** Các ô nhập liệu khi được chọn sẽ có viền màu Primary và một lớp glow nhẹ (halo) để chỉ dẫn vị trí con trỏ.

## Shapes

Hệ thống sử dụng bo góc mức độ **Soft (4px - 12px)** để cân bằng giữa sự nghiêm túc và hiện đại:

- **Buttons & Inputs:** Bo góc 6px (sm) tạo cảm giác chắc chắn, chuyên nghiệp.
- **Cards & Containers:** Bo góc 12px (lg) để làm mềm các khối nội dung lớn.
- **Badges/Status:** Bo góc tròn hoàn toàn (Pill-shaped) để dễ dàng nhận diện là các nhãn chỉ báo trạng thái.

## Components

Các thành phần cốt lõi được thiết kế riêng cho nghiệp vụ tài chính:

### 1. Bảng dữ liệu (Modern Table)
- Hàng tiêu đề có nền xám nhạt, chữ in đậm.
- Hàng dữ liệu có hiệu ứng hover đổi màu nền nhẹ để dễ theo dõi dòng.
- Tích hợp bộ lọc nhanh (Filter) ngay trên đầu cột.

### 2. Biểu mẫu nhiều bước (Multi-step Form)
- Thanh tiến trình (Stepper) nằm ngang phía trên, hiển thị rõ các giai đoạn: *Khởi tạo -> Thông tin tạm ứng -> Chứng từ đính kèm -> Hoàn tất*.
- Chỉ cho phép chuyển bước khi dữ liệu bắt buộc đã hợp lệ.

### 3. Trạng thái (Badges)
- **Chờ duyệt:** Nền vàng nhạt, chữ vàng đậm.
- **Đã duyệt:** Nền xanh lá nhạt, chữ xanh lá đậm.
- **Từ chối:** Nền đỏ nhạt, chữ đỏ đậm.

### 4. Timeline phê duyệt (Approval Timeline)
- Hiển thị theo trục dọc. Mỗi nút thắt (node) thể hiện: Người phê duyệt, Thời gian, Trạng thái (đã ký/đang chờ) và Ghi chú (nếu có).

### 5. Thẻ thống kê (Stats Cards)
- Sử dụng icon tối giản kết hợp với số liệu lớn (Bold). Ví dụ: "Tổng ngân sách", "Đã chi tạm ứng", "Số hồ sơ tồn đọng".