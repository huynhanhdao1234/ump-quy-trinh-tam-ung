<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getRequests } from '@/api/requests'
import { formatCurrency } from '@/utils/money'
import { STATUS_LABELS, STATUS_COLORS } from '@/utils/constants'
import StatsCard from '@/components/StatsCard.vue'
import RequestStatusChip from '@/components/RequestStatusChip.vue'
import { Doughnut } from 'vue-chartjs'
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

ChartJS.register(ArcElement, Tooltip, Legend)

const vuetifyToHex = {
  grey: '#9E9E9E',
  'blue-lighten-1': '#42A5F5',
  orange: '#FF9800',
  'deep-orange': '#FF5722',
  purple: '#9C27B0',
  teal: '#009688',
  red: '#F44336',
  green: '#4CAF50',
  'blue-grey': '#607D8B',
}

const router = useRouter()
const auth = useAuthStore()
const requests = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    requests.value = await getRequests()
  } finally {
    loading.value = false
  }
})

const stats = computed(() => {
  const all = requests.value
  const pending = all.filter(r => auth.getActionableStatuses().includes(r.trang_thai))
  const approved = all.filter(r => ['da_duyet', 'da_chi', 'hoan_tat'].includes(r.trang_thai))
  const totalApproved = approved.reduce((s, r) => s + (Number(r.so_tien_duyet || r.so_tien_de_nghi) || 0), 0)
  return {
    total: all.length,
    pending: pending.length,
    approved: approved.length,
    totalAmount: totalApproved,
  }
})

const statusCounts = computed(() => {
  const counts = {}
  requests.value.forEach(r => {
    counts[r.trang_thai] = (counts[r.trang_thai] || 0) + 1
  })
  return Object.entries(counts).map(([k, v]) => ({
    status: k,
    label: STATUS_LABELS[k] || k,
    color: STATUS_COLORS[k] || 'grey',
    count: v,
  }))
})

const chartData = computed(() => ({
  labels: statusCounts.value.map(s => s.label),
  datasets: [{
    data: statusCounts.value.map(s => s.count),
    backgroundColor: statusCounts.value.map(s => vuetifyToHex[s.color] || '#9E9E9E'),
    borderWidth: 1,
  }],
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'bottom', labels: { boxWidth: 12, padding: 10, font: { size: 11 } } },
  },
}

const recentRequests = computed(() => requests.value.slice(0, 8))
</script>

<template>
  <div>
    <h1 class="text-h6 font-weight-bold mb-2">Tổng quan</h1>

    <v-row dense class="mb-2">
      <v-col cols="12" sm="6" md="3">
        <StatsCard title="Tổng hồ sơ" :value="stats.total" icon="mdi-file-document-multiple" color="primary" gradient="linear-gradient(135deg, #1A73E8, #3B82F6)" />
      </v-col>
      <v-col cols="12" sm="6" md="3">
        <StatsCard title="Chờ xử lý" :value="stats.pending" icon="mdi-clock-outline" color="warning" gradient="linear-gradient(135deg, #F97316, #FB923C)" />
      </v-col>
      <v-col cols="12" sm="6" md="3">
        <StatsCard title="Đã duyệt" :value="stats.approved" icon="mdi-check-circle" color="success" gradient="linear-gradient(135deg, #10B981, #34D399)" />
      </v-col>
      <v-col cols="12" sm="6" md="3">
        <StatsCard title="Tổng chi" :value="formatCurrency(stats.totalAmount) + 'đ'" icon="mdi-cash-multiple" color="info" gradient="linear-gradient(135deg, #0F172A, #1E3A5F)" />
      </v-col>
    </v-row>

    <v-row dense>
      <v-col cols="12" md="4">
        <v-card class="dashboard-card">
          <v-card-title>Theo trạng thái</v-card-title>
          <v-card-text>
            <div v-if="statusCounts.length > 0" style="height: 220px">
              <Doughnut :data="chartData" :options="chartOptions" />
            </div>
            <v-list density="compact" class="mt-2">
              <v-list-item v-for="s in statusCounts" :key="s.status">
                <template #prepend>
                  <v-chip :color="s.color" size="x-small" variant="flat" class="mr-2">{{ s.count }}</v-chip>
                </template>
                <v-list-item-title class="text-body-2">{{ s.label }}</v-list-item-title>
              </v-list-item>
              <v-list-item v-if="statusCounts.length === 0">
                <v-list-item-title class="text-body-2 text-medium-emphasis">Chưa có dữ liệu</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="8">
        <v-card class="dashboard-card">
          <v-card-title class="d-flex align-center">
            <span>Hồ sơ gần đây</span>
            <v-spacer />
            <v-btn variant="text" color="primary" size="small" to="/requests">Xem tất cả</v-btn>
          </v-card-title>
          <v-card-text class="pa-0">
            <v-table density="comfortable" hover v-if="!loading" class="dashboard-table">
              <thead>
                <tr>
                  <th>Mã hồ sơ</th>
                  <th>Người đề nghị</th>
                  <th>Đơn vị</th>
                  <th class="text-right">Số tiền</th>
                  <th>Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="r in recentRequests"
                  :key="r.id || r.ma_ho_so"
                  class="cursor-pointer"
                  @click="router.push(`/requests/${r.ma_ho_so || r.id}`)"
                >
                  <td class="font-weight-medium">{{ r.ma_ho_so }}</td>
                  <td>{{ r.nguoi_de_nghi?.ho_ten || r.ten_nguoi_de_nghi || '' }}</td>
                  <td>{{ r.don_vi?.ten_don_vi || '' }}</td>
                  <td class="text-right">{{ formatCurrency(r.so_tien_de_nghi) }}đ</td>
                  <td><RequestStatusChip :status="r.trang_thai" size="small" /></td>
                </tr>
                <tr v-if="recentRequests.length === 0">
                  <td colspan="5" class="text-center text-medium-emphasis py-8">Chưa có hồ sơ nào</td>
                </tr>
              </tbody>
            </v-table>
            <div v-else class="d-flex justify-center py-8">
              <v-progress-circular indeterminate color="primary" />
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<style scoped>
.cursor-pointer { cursor: pointer; }

.dashboard-card {
  background: #FFFFFF !important;
  border-radius: 12px !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06) !important;
}

.dashboard-table thead tr {
  background: #EBF5FF !important;
}
.dashboard-table thead th {
  background: transparent !important;
}
.dashboard-table tbody tr:nth-child(even) {
  background: #FAFCFF;
}
.dashboard-table tbody tr:hover {
  background: #F0F7FF !important;
}
</style>
