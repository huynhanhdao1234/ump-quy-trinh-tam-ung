export const STATUS_LABELS = {
  nhap: 'Nháp',
  cho_tiep_nhan: 'Chờ tiếp nhận',
  cho_kiem_tra: 'Chờ kiểm tra',
  can_bo_sung: 'Cần bổ sung',
  cho_duyet: 'Chờ duyệt',
  da_duyet: 'Đã duyệt',
  tu_choi: 'Từ chối',
  da_chi: 'Đã chi',
  hoan_tat: 'Hoàn tất',
}

export const STATUS_COLORS = {
  nhap: 'grey',
  cho_tiep_nhan: 'blue-lighten-1',
  cho_kiem_tra: 'orange',
  can_bo_sung: 'deep-orange',
  cho_duyet: 'purple',
  da_duyet: 'teal',
  tu_choi: 'red',
  da_chi: 'green',
  hoan_tat: 'blue-grey',
}

export const STATUS_ICONS = {
  nhap: 'mdi-file-edit-outline',
  cho_tiep_nhan: 'mdi-inbox-arrow-down',
  cho_kiem_tra: 'mdi-clipboard-check-outline',
  can_bo_sung: 'mdi-alert-circle-outline',
  cho_duyet: 'mdi-account-check-outline',
  da_duyet: 'mdi-check-circle-outline',
  tu_choi: 'mdi-close-circle-outline',
  da_chi: 'mdi-cash-check',
  hoan_tat: 'mdi-archive-check-outline',
}

export const ROLE_LABELS = {
  chu_tich: 'Chủ tịch CĐCS',
  ke_toan: 'Phụ trách Kế toán',
  chuyen_vien: 'Chuyên viên VPCĐ',
  thu_quy: 'Thủ quỹ',
  nguoi_de_nghi: 'Người đề nghị',
}

export const ROLE_COLORS = {
  chu_tich: 'red',
  ke_toan: 'blue',
  chuyen_vien: 'teal',
  thu_quy: 'orange',
  nguoi_de_nghi: 'green',
}

export const ESTIMATE_TYPES = [
  { value: 'HSTU-01', title: 'HSTU-01 — Dự trù kinh phí hoạt động tháng' },
  { value: 'HSTU-02', title: 'HSTU-02 — Dự trù kinh phí hoạt động phong trào/chuyên đề' },
]

export const DEMO_ACCOUNTS = [
  { name: 'Trần Quốc Bảo', role: 'Chủ tịch CĐCS', email: 'bao.tq@ump.edu.vn', password: 'ct123456', color: 'red' },
  { name: 'Lê Thị Thanh Hà', role: 'Kế toán', email: 'ha.ltt@ump.edu.vn', password: 'kt123456', color: 'blue' },
  { name: 'Võ Minh Tuấn', role: 'Chuyên viên', email: 'tuan.vm@ump.edu.vn', password: 'cv123456', color: 'teal' },
  { name: 'Đặng Thị Kim Ngân', role: 'Thủ quỹ', email: 'ngan.dtk@ump.edu.vn', password: 'tq123456', color: 'orange' },
  { name: 'Phạm Hoàng Long', role: 'Người đề nghị', email: 'long.ph@ump.edu.vn', password: 'ky123456', color: 'green' },
]
