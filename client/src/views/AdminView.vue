<script setup>
import { ref, onMounted } from 'vue'
import * as usersApi from '@/api/users'
import * as unitsApi from '@/api/units'
import * as configApi from '@/api/config'
import { ROLE_LABELS } from '@/utils/constants'

const ROLE_BG = {
  nguoi_de_nghi: '#DBEAFE',
  thu_quy: '#CCFBF1',
  chu_tich: '#EDE9FE',
  ke_toan: '#FED7AA',
  chuyen_vien: '#E0E7FF',
}

const tab = ref('users')
const snackbar = ref(false)
const snackMsg = ref('')
const snackColor = ref('success')

function showMsg(msg, color = 'success') {
  snackMsg.value = msg
  snackColor.value = color
  snackbar.value = true
}

// ==================== USERS ====================
const users = ref([])
const usersLoading = ref(false)
const userDialog = ref(false)
const editingUser = ref({})

const userHeaders = [
  { title: 'Họ tên', key: 'ho_ten' },
  { title: 'Email', key: 'email' },
  { title: 'Vai trò', key: 'vai_tro' },
  { title: 'Đơn vị', key: 'don_vi_ten' },
  { title: 'Chức vụ', key: 'chuc_vu' },
  { title: 'Trạng thái', key: 'active', width: 100 },
  { title: '', key: 'actions', sortable: false, width: 80 },
]

const roleOptions = Object.entries(ROLE_LABELS).map(([value, title]) => ({ value, title }))

async function loadUsers() {
  usersLoading.value = true
  try { users.value = await usersApi.getUsers() } finally { usersLoading.value = false }
}

function editUser(user) {
  editingUser.value = { ...user }
  userDialog.value = true
}

async function saveUser() {
  try {
    await usersApi.saveUser(editingUser.value.id, editingUser.value)
    showMsg('Đã cập nhật người dùng')
    userDialog.value = false
    await loadUsers()
  } catch (err) {
    showMsg('Lỗi: ' + (err.response?.data?.error || err.message), 'error')
  }
}

// ==================== UNITS ====================
const units = ref([])
const unitsLoading = ref(false)
const unitDialog = ref(false)
const editingUnit = ref({})
const isNewUnit = ref(false)

const unitHeaders = [
  { title: 'Mã đơn vị', key: 'ma_don_vi' },
  { title: 'Tên đơn vị', key: 'ten_don_vi' },
  { title: 'Loại', key: 'loai_don_vi' },
  { title: 'Số đoàn viên', key: 'so_doan_vien', align: 'end' },
  { title: '', key: 'actions', sortable: false, width: 80 },
]

async function loadUnits() {
  unitsLoading.value = true
  try { units.value = await unitsApi.getUnits() } finally { unitsLoading.value = false }
}

function addUnit() {
  editingUnit.value = { ma_don_vi: '', ten_don_vi: '', loai_don_vi: 'CDBP', so_doan_vien: 0 }
  isNewUnit.value = true
  unitDialog.value = true
}

function editUnit(unit) {
  editingUnit.value = { ...unit }
  isNewUnit.value = false
  unitDialog.value = true
}

async function saveUnit() {
  try {
    await unitsApi.saveUnit(editingUnit.value)
    showMsg(isNewUnit.value ? 'Đã thêm đơn vị' : 'Đã cập nhật đơn vị')
    unitDialog.value = false
    await loadUnits()
  } catch (err) {
    showMsg('Lỗi: ' + (err.response?.data?.error || err.message), 'error')
  }
}

// ==================== SLA ====================
const sla = ref({ step2: 1, step3: 3, step4: 1, step5: 3, step6: 3 })
const slaLoading = ref(false)

async function loadSLA() {
  slaLoading.value = true
  try {
    const data = await configApi.getSLA()
    if (data) sla.value = { ...sla.value, ...data }
  } finally { slaLoading.value = false }
}

async function saveSLA() {
  try {
    await configApi.saveSLA(sla.value)
    showMsg('Đã cập nhật cấu hình SLA')
  } catch (err) {
    showMsg('Lỗi: ' + (err.response?.data?.error || err.message), 'error')
  }
}

onMounted(() => {
  loadUsers()
  loadUnits()
  loadSLA()
})
</script>

<template>
  <v-container fluid>
    <h1 class="text-h5 mb-4">Quản trị hệ thống</h1>

    <v-tabs v-model="tab" color="primary" class="admin-tabs">
      <v-tab value="users" prepend-icon="mdi-account-group">Người dùng</v-tab>
      <v-tab value="units" prepend-icon="mdi-domain">Đơn vị</v-tab>
      <v-tab value="sla" prepend-icon="mdi-clock-check-outline">Cấu hình SLA</v-tab>
    </v-tabs>

    <v-tabs-window v-model="tab" class="mt-4">
      <!-- USERS TAB -->
      <v-tabs-window-item value="users">
        <v-data-table
          :headers="userHeaders"
          :items="users"
          :loading="usersLoading"
          density="comfortable"
          items-per-page="15"
          class="admin-table"
        >
          <template #item.vai_tro="{ item }">
            <v-chip size="small" variant="tonal" :style="ROLE_BG[item.vai_tro] ? { background: ROLE_BG[item.vai_tro] } : {}">{{ ROLE_LABELS[item.vai_tro] || item.vai_tro }}</v-chip>
          </template>
          <template #item.active="{ item }">
            <v-chip :color="item.active ? 'success' : 'grey'" size="small" :style="item.active ? { background: '#D1FAE5' } : {}">{{ item.active ? 'Hoạt động' : 'Đã khóa' }}</v-chip>
          </template>
          <template #item.actions="{ item }">
            <v-btn icon="mdi-pencil" size="small" variant="text" class="edit-btn" @click="editUser(item)" />
          </template>
        </v-data-table>
      </v-tabs-window-item>

      <!-- UNITS TAB -->
      <v-tabs-window-item value="units">
        <div class="d-flex justify-end mb-3">
          <v-btn color="primary" prepend-icon="mdi-plus" @click="addUnit">Thêm đơn vị</v-btn>
        </div>
        <v-data-table
          :headers="unitHeaders"
          :items="units"
          :loading="unitsLoading"
          density="comfortable"
          items-per-page="15"
          class="admin-table"
        >
          <template #item.loai_don_vi="{ item }">
            <v-chip size="small" :color="item.loai_don_vi === 'CDBP' ? 'blue' : 'teal'" variant="tonal">
              {{ item.loai_don_vi === 'CDBP' ? 'CĐBP' : 'Tổ CĐ' }}
            </v-chip>
          </template>
          <template #item.actions="{ item }">
            <v-btn icon="mdi-pencil" size="small" variant="text" class="edit-btn" @click="editUnit(item)" />
          </template>
        </v-data-table>
      </v-tabs-window-item>

      <!-- SLA TAB -->
      <v-tabs-window-item value="sla">
        <v-card max-width="600" :loading="slaLoading" class="admin-table">
          <v-card-title>Cấu hình thời gian xử lý (SLA)</v-card-title>
          <v-card-subtitle>Thời gian tối đa cho mỗi bước (ngày làm việc)</v-card-subtitle>
          <v-card-text>
            <v-text-field v-model.number="sla.step2" type="number" min="1" label="Bước 2 — Tiếp nhận hồ sơ (Chuyên viên VPCĐ)" suffix="ngày" />
            <v-text-field v-model.number="sla.step3" type="number" min="1" label="Bước 3 — Kiểm tra hợp lệ (Kế toán)" suffix="ngày" />
            <v-text-field v-model.number="sla.step4" type="number" min="1" label="Bước 4 — Phê duyệt (Chủ tịch CĐCS)" suffix="ngày" />
            <v-text-field v-model.number="sla.step5" type="number" min="1" label="Bước 5 — Chi tạm ứng (Thủ quỹ / Kế toán)" suffix="ngày" />
            <v-text-field v-model.number="sla.step6" type="number" min="1" label="Bước 6 — Lưu hồ sơ (Kế toán / Chuyên viên)" suffix="ngày" />
          </v-card-text>
          <v-card-actions>
            <v-spacer />
            <v-btn color="primary" prepend-icon="mdi-content-save" @click="saveSLA">Lưu cấu hình</v-btn>
          </v-card-actions>
        </v-card>
      </v-tabs-window-item>
    </v-tabs-window>

    <!-- USER EDIT DIALOG -->
    <v-dialog v-model="userDialog" max-width="500">
      <v-card>
        <v-card-title>Chỉnh sửa người dùng</v-card-title>
        <v-card-text>
          <v-text-field v-model="editingUser.ho_ten" label="Họ tên" />
          <v-text-field v-model="editingUser.email" label="Email" disabled />
          <v-select v-model="editingUser.vai_tro" :items="roleOptions" label="Vai trò" />
          <v-text-field v-model="editingUser.chuc_vu" label="Chức vụ" />
          <v-switch v-model="editingUser.active" label="Hoạt động" color="success" />
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="userDialog = false">Hủy</v-btn>
          <v-btn color="primary" @click="saveUser">Lưu</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- UNIT EDIT DIALOG -->
    <v-dialog v-model="unitDialog" max-width="500">
      <v-card>
        <v-card-title>{{ isNewUnit ? 'Thêm đơn vị' : 'Chỉnh sửa đơn vị' }}</v-card-title>
        <v-card-text>
          <v-text-field v-model="editingUnit.ma_don_vi" label="Mã đơn vị" :disabled="!isNewUnit" />
          <v-text-field v-model="editingUnit.ten_don_vi" label="Tên đơn vị" />
          <v-select v-model="editingUnit.loai_don_vi" :items="[{value:'CDBP',title:'CĐBP'},{value:'ToCD',title:'Tổ CĐ'}]" label="Loại đơn vị" />
          <v-text-field v-model.number="editingUnit.so_doan_vien" type="number" label="Số đoàn viên" min="0" />
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="unitDialog = false">Hủy</v-btn>
          <v-btn color="primary" @click="saveUnit">{{ isNewUnit ? 'Thêm' : 'Lưu' }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar" :color="snackColor" timeout="3000">{{ snackMsg }}</v-snackbar>
  </v-container>
</template>

<style scoped>
.admin-table {
  background: #FFFFFF !important;
  border-radius: 12px !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06) !important;
}
.admin-table :deep(thead tr) {
  background: #EBF5FF !important;
}
.admin-table :deep(thead th) {
  background: transparent !important;
}
.admin-table :deep(tbody tr:hover) {
  background: #F0F7FF !important;
}

.admin-tabs :deep(.v-tab--selected) {
  background: #EBF5FF;
  border-bottom: 2.5px solid #1A73E8;
}
.admin-tabs :deep(.v-tab:hover:not(.v-tab--selected)) {
  background: #F0F7FF;
}

.edit-btn:hover {
  background: #DBEAFE !important;
  border-radius: 8px !important;
}
</style>
