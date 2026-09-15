<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import * as requestsApi from '@/api/requests'
import * as unitsApi from '@/api/units'
import * as workflowApi from '@/api/workflow'
import { formatCurrency, formatCurrencyFull } from '@/utils/money'
import { ESTIMATE_TYPES } from '@/utils/constants'
import MoneyInput from '@/components/MoneyInput.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const isEdit = computed(() => !!route.params.id)
const step = ref(1)
const loading = ref(false)
const saving = ref(false)
const units = ref([])
const snackbar = ref(false)
const snackMsg = ref('')
const snackColor = ref('success')

const form = ref({
  ly_do: '',
  don_vi_id: null,
  loai_du_tru: 'HSTU-01',
  thang_nam: '',
  ten_phong_trao: '',
  thoi_han_thanh_toan: '',
})

const estimates = ref([
  { noi_dung: '', don_gia: 0, so_luong: 1, don_vi_tinh: 'Cái', ghi_chu: '' },
])

const signList = ref([
  { ho_ten: '', so_tien: 0, so_ngay: 1 },
])

const estimateTotal = computed(() =>
  estimates.value.reduce((s, r) => s + (r.don_gia || 0) * (r.so_luong || 1), 0)
)

const signListTotal = computed(() =>
  signList.value.reduce((s, r) => s + (r.so_tien || 0) * (r.so_ngay || 1), 0)
)

const formValid = computed(() => !!form.value.ly_do && !!form.value.don_vi_id && !!form.value.loai_du_tru && !!form.value.thoi_han_thanh_toan)

function addEstimateRow() {
  estimates.value.push({ noi_dung: '', don_gia: 0, so_luong: 1, don_vi_tinh: 'Cái', ghi_chu: '' })
}

function removeEstimateRow(i) {
  if (estimates.value.length > 1) estimates.value.splice(i, 1)
}

function addSignRow() {
  signList.value.push({ ho_ten: '', so_tien: 0, so_ngay: 1 })
}

function removeSignRow(i) {
  if (signList.value.length > 1) signList.value.splice(i, 1)
}

function showMsg(msg, color = 'success') {
  snackMsg.value = msg
  snackColor.value = color
  snackbar.value = true
}

let existingId = null

onMounted(async () => {
  loading.value = true
  try {
    units.value = await unitsApi.getUnits()
    if (isEdit.value) {
      const req = await requestsApi.getRequestById(route.params.id)
      if (!req) { router.push('/requests'); return }
      existingId = req.id || req.ma_ho_so
      form.value = {
        ly_do: req.ly_do || '',
        don_vi_id: req.don_vi_id || null,
        loai_du_tru: req.loai_du_tru || 'HSTU-01',
        thang_nam: req.thang_nam || '',
        ten_phong_trao: req.ten_phong_trao || '',
        thoi_han_thanh_toan: req.thoi_han_thanh_toan || '',
      }
      const est = await requestsApi.getEstimates(route.params.id)
      if (est && est.length) estimates.value = est.map(e => ({
        noi_dung: e.noi_dung || '', don_gia: Number(e.don_gia) || 0,
        so_luong: e.so_luong || 1, don_vi_tinh: e.don_vi_tinh || 'Cái', ghi_chu: e.ghi_chu || '',
      }))
      const sl = await requestsApi.getSignList(route.params.id)
      if (sl && sl.length) signList.value = sl.map(s => ({
        ho_ten: s.ho_ten || '', so_tien: Number(s.so_tien) || 0, so_ngay: s.so_ngay || 1,
      }))
    }
  } finally {
    loading.value = false
  }
})

async function saveRequest(submit = false) {
  if (!form.value.ly_do) { showMsg('Vui lòng nhập lý do tạm ứng', 'warning'); return }
  if (!form.value.don_vi_id) { showMsg('Vui lòng chọn đơn vị', 'warning'); return }
  if (!form.value.loai_du_tru) { showMsg('Vui lòng chọn loại dự trù', 'warning'); return }
  if (!form.value.thoi_han_thanh_toan) { showMsg('Vui lòng nhập thời hạn thanh toán', 'warning'); return }

  saving.value = true
  try {
    const payload = {
      ...form.value,
      so_tien_de_nghi: estimateTotal.value || signListTotal.value,
      trang_thai: 'nhap',
    }

    let reqId
    if (isEdit.value && existingId) {
      await requestsApi.updateRequest(existingId, payload)
      reqId = existingId
    } else {
      const result = await requestsApi.createRequest(payload)
      reqId = result.ma_ho_so || result.id
      existingId = reqId
    }

    const estItems = estimates.value
      .filter(e => e.noi_dung)
      .map((e, i) => ({ stt: i + 1, ...e }))
    if (estItems.length) await requestsApi.saveEstimates(reqId, estItems)

    const slItems = signList.value
      .filter(s => s.ho_ten)
      .map((s, i) => ({ stt: i + 1, ...s }))
    if (slItems.length) await requestsApi.saveSignList(reqId, slItems)

    if (submit) {
      await workflowApi.transition(reqId, 'nop_ho_so', 'Nộp hồ sơ mới')
      showMsg('Đã nộp hồ sơ thành công')
    } else {
      showMsg('Đã lưu nháp')
    }
    setTimeout(() => router.push('/requests'), 800)
  } catch (err) {
    showMsg('Lỗi: ' + (err.response?.data?.error || err.message), 'error')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12">
        <div class="d-flex align-center mb-4">
          <v-btn icon="mdi-arrow-left" variant="text" @click="router.push('/requests')" />
          <h1 class="text-h5 ml-2">{{ isEdit ? 'Chỉnh sửa hồ sơ' : 'Tạo hồ sơ tạm ứng mới' }}</h1>
        </div>
      </v-col>
    </v-row>

    <v-card :loading="loading" class="form-card">
      <v-stepper v-model="step" :items="['Thông tin chung', 'Dự trù kinh phí', 'Danh sách ký nhận', 'Xem lại & Nộp']" editable class="form-stepper">
        <!-- Step 1 -->
        <template v-slot:item.1>
          <v-card flat>
            <v-card-text>
              <v-row>
                <v-col cols="12">
                  <v-textarea v-model="form.ly_do" label="Lý do tạm ứng *" rows="3" :rules="[v => !!v || 'Bắt buộc']" />
                </v-col>
                <v-col cols="12" md="6">
                  <v-autocomplete
                    v-model="form.don_vi_id"
                    :items="units"
                    item-title="ten_don_vi"
                    item-value="id"
                    label="Đơn vị *"
                    :rules="[v => !!v || 'Bắt buộc']"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-select v-model="form.loai_du_tru" :items="ESTIMATE_TYPES" label="Loại dự trù *" :rules="[v => !!v || 'Bắt buộc']" />
                </v-col>
                <v-col cols="12" md="4">
                  <v-text-field v-model="form.thang_nam" label="Tháng/năm" placeholder="VD: 09/2026" />
                </v-col>
                <v-col cols="12" md="4">
                  <v-text-field v-model="form.ten_phong_trao" label="Tên phong trào" />
                </v-col>
                <v-col cols="12" md="4">
                  <v-text-field v-model="form.thoi_han_thanh_toan" label="Thời hạn thanh toán *" type="date" :rules="[v => !!v || 'Bắt buộc']" />
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </template>

        <!-- Step 2 -->
        <template v-slot:item.2>
          <v-card flat>
            <v-card-text>
              <v-table density="compact">
                <thead>
                  <tr>
                    <th style="width:50px">STT</th>
                    <th>Nội dung</th>
                    <th style="width:160px">Số tiền</th>
                    <th style="width:90px">Số lượng</th>
                    <th style="width:100px">ĐVT</th>
                    <th style="width:150px">Thành tiền</th>
                    <th>Ghi chú</th>
                    <th style="width:50px"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(item, i) in estimates" :key="i">
                    <td>{{ i + 1 }}</td>
                    <td><v-text-field v-model="item.noi_dung" variant="underlined" density="compact" hide-details /></td>
                    <td><MoneyInput v-model="item.don_gia" density="compact" /></td>
                    <td><v-text-field v-model.number="item.so_luong" type="number" variant="underlined" density="compact" hide-details min="1" /></td>
                    <td><v-text-field v-model="item.don_vi_tinh" variant="underlined" density="compact" hide-details /></td>
                    <td class="text-right font-weight-medium">{{ formatCurrency(item.don_gia * item.so_luong) }}</td>
                    <td><v-text-field v-model="item.ghi_chu" variant="underlined" density="compact" hide-details /></td>
                    <td><v-btn icon="mdi-close" size="x-small" variant="text" color="error" @click="removeEstimateRow(i)" /></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="5" class="text-right font-weight-bold">Tổng cộng:</td>
                    <td class="text-right font-weight-bold text-primary">{{ formatCurrencyFull(estimateTotal) }}</td>
                    <td colspan="2"></td>
                  </tr>
                </tfoot>
              </v-table>
              <v-btn prepend-icon="mdi-plus" variant="tonal" size="small" class="mt-2" @click="addEstimateRow">Thêm dòng</v-btn>
            </v-card-text>
          </v-card>
        </template>

        <!-- Step 3 -->
        <template v-slot:item.3>
          <v-card flat>
            <v-card-text>
              <v-table density="compact">
                <thead>
                  <tr>
                    <th style="width:50px">STT</th>
                    <th>Họ tên</th>
                    <th style="width:160px">Số tiền</th>
                    <th style="width:90px">Số ngày</th>
                    <th style="width:160px">Thành tiền</th>
                    <th style="width:50px"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(item, i) in signList" :key="i">
                    <td>{{ i + 1 }}</td>
                    <td><v-text-field v-model="item.ho_ten" variant="underlined" density="compact" hide-details /></td>
                    <td><MoneyInput v-model="item.so_tien" density="compact" /></td>
                    <td><v-text-field v-model.number="item.so_ngay" type="number" variant="underlined" density="compact" hide-details min="1" /></td>
                    <td class="text-right font-weight-medium">{{ formatCurrency(item.so_tien * item.so_ngay) }}</td>
                    <td><v-btn icon="mdi-close" size="x-small" variant="text" color="error" @click="removeSignRow(i)" /></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="4" class="text-right font-weight-bold">Tổng cộng:</td>
                    <td class="text-right font-weight-bold text-primary">{{ formatCurrencyFull(signListTotal) }}</td>
                    <td></td>
                  </tr>
                </tfoot>
              </v-table>
              <v-btn prepend-icon="mdi-plus" variant="tonal" size="small" class="mt-2" @click="addSignRow">Thêm dòng</v-btn>
            </v-card-text>
          </v-card>
        </template>

        <!-- Step 4 -->
        <template v-slot:item.4>
          <v-card flat>
            <v-card-text>
              <h3 class="text-subtitle-1 font-weight-bold mb-3">Thông tin chung</h3>
              <v-table density="compact" class="mb-4">
                <tbody>
                  <tr><td class="font-weight-medium" style="width:200px">Lý do</td><td>{{ form.ly_do }}</td></tr>
                  <tr><td class="font-weight-medium">Đơn vị</td><td>{{ units.find(u => u.id === form.don_vi_id)?.ten_don_vi || '-' }}</td></tr>
                  <tr><td class="font-weight-medium">Loại dự trù</td><td>{{ ESTIMATE_TYPES.find(e => e.value === form.loai_du_tru)?.title || form.loai_du_tru }}</td></tr>
                  <tr v-if="form.thang_nam"><td class="font-weight-medium">Tháng/năm</td><td>{{ form.thang_nam }}</td></tr>
                  <tr v-if="form.ten_phong_trao"><td class="font-weight-medium">Tên phong trào</td><td>{{ form.ten_phong_trao }}</td></tr>
                  <tr v-if="form.thoi_han_thanh_toan"><td class="font-weight-medium">Thời hạn</td><td>{{ form.thoi_han_thanh_toan }}</td></tr>
                </tbody>
              </v-table>

              <h3 class="text-subtitle-1 font-weight-bold mb-2">Dự trù kinh phí</h3>
              <v-table density="compact" class="mb-1">
                <thead><tr><th>STT</th><th>Nội dung</th><th>Số tiền</th><th>SL</th><th>Thành tiền</th></tr></thead>
                <tbody>
                  <tr v-for="(e, i) in estimates.filter(e => e.noi_dung)" :key="i">
                    <td>{{ i + 1 }}</td><td>{{ e.noi_dung }}</td>
                    <td class="text-right">{{ formatCurrency(e.don_gia) }}</td>
                    <td>{{ e.so_luong }}</td>
                    <td class="text-right">{{ formatCurrency(e.don_gia * e.so_luong) }}</td>
                  </tr>
                </tbody>
              </v-table>
              <div class="text-right font-weight-bold mb-4">Tổng dự trù: {{ formatCurrencyFull(estimateTotal) }}</div>

              <h3 class="text-subtitle-1 font-weight-bold mb-2">Danh sách ký nhận</h3>
              <v-table density="compact" class="mb-1">
                <thead><tr><th>STT</th><th>Họ tên</th><th>Số tiền</th><th>Số ngày</th><th>Thành tiền</th></tr></thead>
                <tbody>
                  <tr v-for="(s, i) in signList.filter(s => s.ho_ten)" :key="i">
                    <td>{{ i + 1 }}</td><td>{{ s.ho_ten }}</td>
                    <td class="text-right">{{ formatCurrency(s.so_tien) }}</td>
                    <td>{{ s.so_ngay }}</td>
                    <td class="text-right">{{ formatCurrency(s.so_tien * s.so_ngay) }}</td>
                  </tr>
                </tbody>
              </v-table>
              <div class="text-right font-weight-bold mb-6">Tổng ký nhận: {{ formatCurrencyFull(signListTotal) }}</div>

              <v-divider class="mb-4" />
              <div class="d-flex justify-end ga-3">
                <v-btn variant="outlined" prepend-icon="mdi-content-save-outline" :loading="saving" @click="saveRequest(false)">Lưu nháp</v-btn>
                <v-btn color="primary" prepend-icon="mdi-send" :loading="saving" :disabled="!formValid" @click="saveRequest(true)">Nộp hồ sơ</v-btn>
              </div>
            </v-card-text>
          </v-card>
        </template>
      </v-stepper>
    </v-card>

    <v-snackbar v-model="snackbar" :color="snackColor" timeout="3000">{{ snackMsg }}</v-snackbar>
  </v-container>
</template>

<style scoped>
.form-card {
  background: #FFFFFF !important;
  border-radius: 12px !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04) !important;
  padding: 32px !important;
}

/* Stepper header */
.form-stepper :deep(.v-stepper-header) {
  box-shadow: none !important;
}

/* Active step */
.form-stepper :deep(.v-stepper-item--selected .v-stepper-item__avatar) {
  background: #1A73E8 !important;
}
.form-stepper :deep(.v-stepper-item--selected .v-stepper-item__avatar .v-icon) {
  color: #FFFFFF !important;
}
.form-stepper :deep(.v-stepper-item--selected .v-stepper-item__content) {
  font-weight: 600 !important;
  color: #1A73E8 !important;
}

/* Completed step */
.form-stepper :deep(.v-stepper-item--complete .v-stepper-item__avatar) {
  background: #10B981 !important;
}
.form-stepper :deep(.v-stepper-item--complete .v-stepper-item__avatar .v-icon) {
  color: #FFFFFF !important;
}

/* Upcoming step */
.form-stepper :deep(.v-stepper-item:not(.v-stepper-item--selected):not(.v-stepper-item--complete) .v-stepper-item__avatar) {
  background: #E2E8F0 !important;
  color: #94A3B8 !important;
}

/* Connector lines */
.form-stepper :deep(.v-stepper-item--complete + .v-stepper__separator) {
  background: #10B981 !important;
}
.form-stepper :deep(.v-stepper-item--selected + .v-stepper__separator) {
  background: linear-gradient(90deg, #1A73E8, #E2E8F0) !important;
}
.form-stepper :deep(.v-stepper__separator) {
  background: #E2E8F0 !important;
}

/* Form inputs */
.form-stepper :deep(.v-field) {
  background: #F8FAFC !important;
  border-radius: 8px !important;
}
.form-stepper :deep(.v-field--variant-outlined .v-field__outline) {
  --v-field-border-opacity: 1;
  color: #D1D9E6 !important;
}
.form-stepper :deep(.v-field--focused .v-field__outline) {
  color: #3B82F6 !important;
}
.form-stepper :deep(.v-field--focused) {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Next button */
.form-stepper :deep(.v-stepper-actions .v-btn--variant-elevated),
.form-stepper :deep(.v-stepper-actions .v-btn--variant-flat):last-child {
  background: linear-gradient(135deg, #1A73E8, #2563EB) !important;
  color: #FFFFFF !important;
  font-weight: 600 !important;
  border-radius: 8px !important;
  padding: 10px 24px !important;
  box-shadow: none !important;
}
.form-stepper :deep(.v-stepper-actions .v-btn--variant-elevated:hover),
.form-stepper :deep(.v-stepper-actions .v-btn--variant-flat):last-child:hover {
  background: linear-gradient(135deg, #1557B0, #1A73E8) !important;
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.3) !important;
}

/* Back button */
.form-stepper :deep(.v-stepper-actions .v-btn--variant-text) {
  color: #3B82F6 !important;
}
.form-stepper :deep(.v-stepper-actions .v-btn--variant-text:hover) {
  color: #1A73E8 !important;
  text-decoration: underline;
}
</style>
