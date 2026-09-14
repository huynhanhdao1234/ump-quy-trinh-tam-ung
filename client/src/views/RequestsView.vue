<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getRequests } from '@/api/requests'
import { getUnits } from '@/api/units'
import { formatCurrency } from '@/utils/money'
import { STATUS_LABELS, STATUS_COLORS } from '@/utils/constants'
import RequestStatusChip from '@/components/RequestStatusChip.vue'

const router = useRouter()
const auth = useAuthStore()
const requests = ref([])
const units = ref([])
const loading = ref(true)
const search = ref('')
const filterStatus = ref(null)

const statusOptions = computed(() => [
  { title: 'Tất cả', value: null },
  ...Object.entries(STATUS_LABELS).map(([k, v]) => ({ title: v, value: k })),
])

onMounted(async () => {
  try {
    const [reqData, unitData] = await Promise.all([getRequests(), getUnits()])
    requests.value = reqData
    units.value = unitData
  } finally {
    loading.value = false
  }
})

const filteredRequests = computed(() => {
  let list = requests.value
  if (filterStatus.value) {
    list = list.filter(r => r.trang_thai === filterStatus.value)
  }
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter(r =>
      (r.ma_ho_so || '').toLowerCase().includes(q) ||
      (r.nguoi_de_nghi?.ho_ten || r.ten_nguoi_de_nghi || '').toLowerCase().includes(q) ||
      (r.ly_do || '').toLowerCase().includes(q)
    )
  }
  return list
})

function formatDate(dt) {
  if (!dt) return ''
  return new Date(dt).toLocaleDateString('vi-VN')
}

function addWorkingDays(date, days) {
  const result = new Date(date)
  let added = 0
  while (added < days) {
    result.setDate(result.getDate() + 1)
    const dow = result.getDay()
    if (dow !== 0 && dow !== 6) added++
  }
  return result
}

function formatDeadline(r) {
  if (!r.created_at) return ''
  if (r.trang_thai === 'hoan_tat') return new Date(r.updated_at).toLocaleDateString('vi-VN')
  return addWorkingDays(new Date(r.created_at), 11).toLocaleDateString('vi-VN')
}

function isOverdue(r) {
  if (!r.created_at || ['hoan_tat', 'tu_choi'].includes(r.trang_thai)) return false
  return new Date() > addWorkingDays(new Date(r.created_at), 11)
}

function getDeadlineClass(r) {
  if (r.trang_thai === 'hoan_tat') return 'text-success'
  if (isOverdue(r)) return 'text-error'
  return ''
}
</script>

<template>
  <div>
    <div class="d-flex align-center mb-2">
      <h1 class="text-h6 font-weight-bold">
        {{ auth.isNguoiDenghi ? 'Hồ sơ của tôi' : 'Hồ sơ tạm ứng' }}
      </h1>
      <v-spacer />
      <v-btn v-if="auth.isNguoiDenghi" color="primary" prepend-icon="mdi-plus" to="/requests/new">
        Tạo hồ sơ mới
      </v-btn>
    </div>

    <v-card>
      <v-card-text class="pb-0">
        <v-row>
          <v-col cols="12" sm="6" md="4">
            <v-text-field
              v-model="search"
              prepend-inner-icon="mdi-magnify"
              label="Tìm kiếm..."
              clearable
              hide-details
              density="compact"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <v-select
              v-model="filterStatus"
              :items="statusOptions"
              label="Trạng thái"
              hide-details
              density="compact"
              clearable
            />
          </v-col>
        </v-row>
      </v-card-text>

      <v-card-text class="pa-0 pt-2">
        <v-table density="comfortable" hover v-if="!loading">
          <thead>
            <tr>
              <th>Mã hồ sơ</th>
              <th>Người đề nghị</th>
              <th>Đơn vị</th>
              <th>Lý do</th>
              <th class="text-right">Số tiền</th>
              <th>Trạng thái</th>
              <th>Ngày tạo</th>
              <th>Hạn hoàn tất</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="r in filteredRequests"
              :key="r.id || r.ma_ho_so"
              class="cursor-pointer"
              @click="router.push(`/requests/${r.ma_ho_so || r.id}`)"
            >
              <td class="font-weight-medium text-primary">{{ r.ma_ho_so }}</td>
              <td>{{ r.nguoi_de_nghi?.ho_ten || r.ten_nguoi_de_nghi || '' }}</td>
              <td>{{ r.don_vi?.ten_don_vi || r.ten_don_vi || '' }}</td>
              <td class="text-truncate" style="max-width: 200px">{{ r.ly_do }}</td>
              <td class="text-right font-weight-medium">{{ formatCurrency(r.so_tien_de_nghi) }}đ</td>
              <td><RequestStatusChip :status="r.trang_thai" size="small" /></td>
              <td class="text-caption">{{ formatDate(r.created_at) }}</td>
              <td class="text-caption" :class="getDeadlineClass(r)">
                {{ formatDeadline(r) }}
                <v-chip v-if="isOverdue(r)" color="error" size="x-small" class="ml-1">Quá hạn</v-chip>
              </td>
            </tr>
            <tr v-if="filteredRequests.length === 0">
              <td colspan="8" class="text-center text-medium-emphasis py-8">
                {{ search || filterStatus ? 'Không tìm thấy hồ sơ phù hợp' : 'Chưa có hồ sơ nào' }}
              </td>
            </tr>
          </tbody>
        </v-table>
        <div v-else class="d-flex justify-center py-8">
          <v-progress-circular indeterminate color="primary" />
        </div>
      </v-card-text>
    </v-card>
  </div>
</template>

<style scoped>
.cursor-pointer { cursor: pointer; }
</style>
