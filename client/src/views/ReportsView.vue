<script setup>
import { ref, computed, onMounted } from 'vue'
import * as requestsApi from '@/api/requests'
import { formatCurrency, formatCurrencyFull } from '@/utils/money'
import { STATUS_LABELS, STATUS_COLORS } from '@/utils/constants'
import { exportToExcel, exportToPdf } from '@/utils/export'
import RequestStatusChip from '@/components/RequestStatusChip.vue'
import StatsCard from '@/components/StatsCard.vue'
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

const loading = ref(false)
const allRequests = ref([])
const dateFrom = ref('')
const dateTo = ref('')
const statusFilter = ref([])

const statusOptions = Object.entries(STATUS_LABELS).map(([value, title]) => ({ value, title }))

const filteredRequests = computed(() => {
  let list = allRequests.value
  if (dateFrom.value) {
    list = list.filter(r => r.created_at >= dateFrom.value)
  }
  if (dateTo.value) {
    const to = dateTo.value + 'T23:59:59'
    list = list.filter(r => r.created_at <= to)
  }
  if (statusFilter.value.length) {
    list = list.filter(r => statusFilter.value.includes(r.trang_thai))
  }
  return list
})

const totalRequests = computed(() => filteredRequests.value.length)

const totalAmount = computed(() =>
  filteredRequests.value.reduce((s, r) => s + (Number(r.so_tien_de_nghi) || 0), 0)
)

const totalApproved = computed(() =>
  filteredRequests.value
    .filter(r => ['da_duyet', 'da_chi', 'hoan_tat'].includes(r.trang_thai))
    .reduce((s, r) => s + (Number(r.so_tien_duyet || r.so_tien_de_nghi) || 0), 0)
)

const totalPaid = computed(() =>
  filteredRequests.value
    .filter(r => ['da_chi', 'hoan_tat'].includes(r.trang_thai))
    .reduce((s, r) => s + (Number(r.so_tien_duyet || r.so_tien_de_nghi) || 0), 0)
)

const statusCounts = computed(() => {
  const counts = {}
  filteredRequests.value.forEach(r => {
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
    legend: { position: 'right', labels: { boxWidth: 12, padding: 10, font: { size: 11 } } },
  },
}

const headers = [
  { title: 'Mã hồ sơ', key: 'ma_ho_so' },
  { title: 'Người đề nghị', key: 'nguoi_de_nghi' },
  { title: 'Đơn vị', key: 'don_vi' },
  { title: 'Số tiền đề nghị', key: 'so_tien_de_nghi', align: 'end' },
  { title: 'Số tiền duyệt', key: 'so_tien_duyet', align: 'end' },
  { title: 'Trạng thái', key: 'trang_thai' },
  { title: 'Ngày tạo', key: 'created_at' },
]

function formatDate(d) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('vi-VN')
}

function handleExportExcel() {
  exportToExcel(filteredRequests.value)
}

async function handleExportPdf() {
  await exportToPdf(filteredRequests.value)
}

onMounted(async () => {
  loading.value = true
  try {
    allRequests.value = await requestsApi.getRequests()
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <v-container fluid>
    <h1 class="text-h6 font-weight-bold mb-2">Báo cáo & Thống kê</h1>

    <!-- Filters -->
    <v-card class="mb-2">
      <v-card-text>
        <v-row align="center">
          <v-col cols="12" sm="4" md="3">
            <v-text-field v-model="dateFrom" label="Từ ngày" type="date" hide-details density="compact" clearable />
          </v-col>
          <v-col cols="12" sm="4" md="3">
            <v-text-field v-model="dateTo" label="Đến ngày" type="date" hide-details density="compact" clearable />
          </v-col>
          <v-col cols="12" sm="4" md="3">
            <v-select
              v-model="statusFilter"
              :items="statusOptions"
              label="Trạng thái"
              multiple
              chips
              closable-chips
              hide-details
              density="compact"
              clearable
            />
          </v-col>
          <v-col cols="12" md="3" class="d-flex ga-2 justify-end">
            <v-btn prepend-icon="mdi-file-excel" variant="outlined" size="small" color="success" @click="handleExportExcel">Excel</v-btn>
            <v-btn prepend-icon="mdi-file-pdf-box" variant="outlined" size="small" color="error" @click="handleExportPdf">PDF</v-btn>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- Stats -->
    <v-row dense class="mb-2">
      <v-col cols="6" md="3">
        <StatsCard title="Tổng hồ sơ" :value="totalRequests" icon="mdi-file-document-multiple" color="primary" />
      </v-col>
      <v-col cols="6" md="3">
        <StatsCard title="Tổng đề nghị" :value="formatCurrencyFull(totalAmount)" icon="mdi-cash" color="info" />
      </v-col>
      <v-col cols="6" md="3">
        <StatsCard title="Đã duyệt" :value="formatCurrencyFull(totalApproved)" icon="mdi-check-circle" color="success" />
      </v-col>
      <v-col cols="6" md="3">
        <StatsCard title="Đã chi" :value="formatCurrencyFull(totalPaid)" icon="mdi-cash-check" color="teal" />
      </v-col>
    </v-row>

    <!-- Chart -->
    <v-card v-if="statusCounts.length > 0" class="mb-2">
      <v-card-title>Phân bổ theo trạng thái</v-card-title>
      <v-card-text>
        <div style="height: 250px">
          <Doughnut :data="chartData" :options="chartOptions" />
        </div>
      </v-card-text>
    </v-card>

    <!-- Data table -->
    <v-data-table
      :headers="headers"
      :items="filteredRequests"
      :loading="loading"
      density="comfortable"
      items-per-page="20"
      class="elevation-1"
    >
      <template #item.nguoi_de_nghi="{ item }">
        {{ item.nguoi_de_nghi?.ho_ten || item.ten_nguoi_de_nghi || '-' }}
      </template>
      <template #item.don_vi="{ item }">
        {{ item.don_vi?.ten_don_vi || item.ten_don_vi || '-' }}
      </template>
      <template #item.so_tien_de_nghi="{ item }">
        {{ formatCurrency(item.so_tien_de_nghi) }}
      </template>
      <template #item.so_tien_duyet="{ item }">
        {{ item.so_tien_duyet ? formatCurrency(item.so_tien_duyet) : '-' }}
      </template>
      <template #item.trang_thai="{ item }">
        <RequestStatusChip :status="item.trang_thai" />
      </template>
      <template #item.created_at="{ item }">
        {{ formatDate(item.created_at) }}
      </template>
    </v-data-table>
  </v-container>
</template>
