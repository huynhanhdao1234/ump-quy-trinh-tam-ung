<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getRequestById, getEstimates, getHistory, getPayment, getSignList, getFiles } from '@/api/requests'
import { transition } from '@/api/workflow'
import { formatCurrency, formatCurrencyFull } from '@/utils/money'
import { STATUS_LABELS } from '@/utils/constants'
import RequestStatusChip from '@/components/RequestStatusChip.vue'
import MoneyInput from '@/components/MoneyInput.vue'
import AiSummaryCard from '@/components/AiSummaryCard.vue'
import AiCheckCard from '@/components/AiCheckCard.vue'
import AiCommentSuggest from '@/components/AiCommentSuggest.vue'
import WorkflowProgress from '@/components/WorkflowProgress.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const request = ref(null)
const estimates = ref([])
const signList = ref([])
const history = ref([])
const payment = ref(null)
const files = ref([])
const loading = ref(true)
const actionNote = ref('')
const approveAmount = ref(0)
const actionLoading = ref(false)
const snackbar = ref({ show: false, text: '', color: 'success' })

const tab = ref('info')

onMounted(() => loadData())

async function loadData() {
  loading.value = true
  try {
    const id = route.params.id
    const [req, est, hist, pay, sl, fl] = await Promise.all([
      getRequestById(id),
      getEstimates(id).catch(() => []),
      getHistory(id).catch(() => []),
      getPayment(id).catch(() => null),
      getSignList(id).catch(() => []),
      getFiles(id).catch(() => []),
    ])
    request.value = req
    estimates.value = est
    history.value = hist
    payment.value = pay
    signList.value = sl
    files.value = fl
    if (req.so_tien_de_nghi) approveAmount.value = Number(req.so_tien_de_nghi)
  } finally {
    loading.value = false
  }
}

const totalEstimate = computed(() => estimates.value.reduce((s, e) => s + (Number(e.thanh_tien) || 0), 0))

async function doAction(hanhDong, successMsg) {
  actionLoading.value = true
  try {
    const amt = hanhDong === 'phe_duyet' ? approveAmount.value : null
    const note = actionNote.value || null
    await transition(request.value.ma_ho_so || request.value.id, hanhDong, note, amt)
    snackbar.value = { show: true, text: successMsg, color: 'success' }
    actionNote.value = ''
    await loadData()
  } catch (err) {
    snackbar.value = { show: true, text: err.response?.data?.error || err.message, color: 'error' }
  } finally {
    actionLoading.value = false
  }
}

function formatDate(dt) {
  if (!dt) return ''
  return new Date(dt).toLocaleString('vi-VN')
}

</script>

<template>
  <div>
    <div v-if="loading" class="d-flex justify-center py-16">
      <v-progress-circular indeterminate color="primary" size="64" />
    </div>

    <template v-else-if="request">
      <div class="d-flex align-center mb-2">
        <v-btn icon variant="text" @click="router.back()" class="mr-2">
          <v-icon>mdi-arrow-left</v-icon>
        </v-btn>
        <div>
          <h1 class="text-h6 font-weight-bold">{{ request.ma_ho_so }}</h1>
          <p class="text-body-2 text-medium-emphasis">{{ request.ly_do }}</p>
        </div>
        <v-spacer />
        <RequestStatusChip :status="request.trang_thai" />
        <v-btn
          v-if="auth.canEdit(request)"
          class="ml-3"
          variant="outlined"
          color="primary"
          prepend-icon="mdi-pencil"
          :to="`/requests/${request.ma_ho_so || request.id}/edit`"
        >
          Sửa
        </v-btn>
      </div>

      <WorkflowProgress :status="request.trang_thai" />

      <v-tabs v-model="tab" class="mb-2">
        <v-tab value="info">Thông tin</v-tab>
        <v-tab value="estimates">Dự trù ({{ estimates.length }})</v-tab>
        <v-tab value="signlist">Ký nhận ({{ signList.length }})</v-tab>
        <v-tab value="history">Lịch sử</v-tab>
        <v-tab v-if="payment" value="payment">Phiếu chi</v-tab>
        <v-tab value="files">Tệp đính kèm ({{ files.length }})</v-tab>
      </v-tabs>

      <v-tabs-window v-model="tab">
        <!-- Info tab -->
        <v-tabs-window-item value="info">
          <v-row>
            <v-col cols="12" md="7">
              <v-card>
                <v-card-title>Chi tiết hồ sơ</v-card-title>
                <v-card-text>
                  <v-table density="compact">
                    <tbody>
                      <tr>
                        <td class="text-medium-emphasis" width="160">Người đề nghị</td>
                        <td class="font-weight-medium">{{ request.nguoi_de_nghi?.ho_ten || request.ten_nguoi_de_nghi }}</td>
                      </tr>
                      <tr>
                        <td class="text-medium-emphasis">Đơn vị</td>
                        <td>{{ request.don_vi?.ten_don_vi || request.ten_don_vi || '' }}</td>
                      </tr>
                      <tr>
                        <td class="text-medium-emphasis">Lý do tạm ứng</td>
                        <td>{{ request.ly_do }}</td>
                      </tr>
                      <tr>
                        <td class="text-medium-emphasis">Số tiền đề nghị</td>
                        <td class="font-weight-bold text-primary">{{ formatCurrencyFull(request.so_tien_de_nghi) }}</td>
                      </tr>
                      <tr v-if="request.so_tien_duyet">
                        <td class="text-medium-emphasis">Số tiền duyệt</td>
                        <td class="font-weight-bold text-success">{{ formatCurrencyFull(request.so_tien_duyet) }}</td>
                      </tr>
                      <tr>
                        <td class="text-medium-emphasis">Loại dự trù</td>
                        <td>{{ request.loai_du_tru }}</td>
                      </tr>
                      <tr v-if="request.thang_nam">
                        <td class="text-medium-emphasis">Tháng/Năm</td>
                        <td>{{ request.thang_nam }}</td>
                      </tr>
                      <tr v-if="request.thoi_han_thanh_toan">
                        <td class="text-medium-emphasis">Thời hạn thanh toán</td>
                        <td>{{ request.thoi_han_thanh_toan }}</td>
                      </tr>
                      <tr>
                        <td class="text-medium-emphasis">Ngày tạo</td>
                        <td>{{ formatDate(request.created_at) }}</td>
                      </tr>
                      <tr v-if="request.trang_thai === 'hoan_tat'">
                        <td class="text-medium-emphasis">Ngày hoàn thành</td>
                        <td class="font-weight-medium text-success">{{ formatDate(request.updated_at) }}</td>
                      </tr>
                    </tbody>
                  </v-table>

                  <v-alert v-if="request.ly_do_bo_sung" type="warning" variant="tonal" class="mt-4">
                    <strong>Yêu cầu bổ sung:</strong> {{ request.ly_do_bo_sung }}
                  </v-alert>
                  <v-alert v-if="request.ly_do_tu_choi" type="error" variant="tonal" class="mt-4">
                    <strong>Lý do từ chối:</strong> {{ request.ly_do_tu_choi }}
                  </v-alert>
                </v-card-text>
              </v-card>

              <AiSummaryCard
                :request="request"
                :estimates="estimates"
                :sign-list="signList"
                :history="history"
              />
            </v-col>

            <v-col cols="12" md="5">
              <AiCheckCard
                v-if="auth.canCheck(request)"
                :request="request"
                :estimates="estimates"
                :sign-list="signList"
              />

              <v-card v-if="auth.canReceive(request) || auth.canCheck(request) || auth.canApprove(request) || auth.canPay(request) || auth.canArchive(request) || auth.canRequestRevision(request)">
                <v-card-title>Thao tác</v-card-title>
                <v-card-text>
                  <div class="d-flex align-center ga-2 mb-1">
                    <span class="text-body-2 text-medium-emphasis">Ghi chú</span>
                    <v-spacer />
                    <AiCommentSuggest
                      :request="request"
                      :action="auth.canApprove(request) ? 'phe_duyet' : auth.canCheck(request) ? 'hop_le' : auth.canReject(request) ? 'tu_choi' : 'xu_ly'"
                      @suggest="(text) => actionNote = text"
                    />
                  </div>
                  <v-textarea
                    v-model="actionNote"
                    rows="2"
                    hide-details
                    class="mb-3"
                  />

                  <MoneyInput
                    v-if="auth.canApprove(request)"
                    v-model="approveAmount"
                    label="Số tiền duyệt"
                    class="mb-3"
                  />

                  <div class="d-flex flex-wrap ga-2">
                    <v-btn v-if="auth.canReceive(request)" color="primary" :loading="actionLoading" @click="doAction('tiep_nhan', 'Đã tiếp nhận hồ sơ')">
                      Tiếp nhận
                    </v-btn>
                    <v-btn v-if="auth.canCheck(request)" color="primary" :loading="actionLoading" @click="doAction('hop_le', 'Hồ sơ hợp lệ')">
                      Hợp lệ
                    </v-btn>
                    <v-btn v-if="auth.canApprove(request)" color="success" :loading="actionLoading" @click="doAction('phe_duyet', 'Đã phê duyệt')">
                      Phê duyệt
                    </v-btn>
                    <v-btn v-if="auth.canPay(request)" color="teal" :loading="actionLoading" @click="doAction('da_chi', 'Đã chi tiền')">
                      Xác nhận chi
                    </v-btn>
                    <v-btn v-if="auth.canArchive(request)" color="blue-grey" :loading="actionLoading" @click="doAction('hoan_tat', 'Đã hoàn tất')">
                      Hoàn tất
                    </v-btn>
                    <v-btn v-if="auth.canRequestRevision(request)" color="warning" variant="outlined" :loading="actionLoading" @click="doAction('yeu_cau_bo_sung', 'Đã yêu cầu bổ sung')">
                      Yêu cầu bổ sung
                    </v-btn>
                    <v-btn v-if="auth.canReject(request)" color="error" variant="outlined" :loading="actionLoading" @click="doAction('tu_choi', 'Đã từ chối')">
                      Từ chối
                    </v-btn>
                  </div>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-tabs-window-item>

        <!-- Estimates tab -->
        <v-tabs-window-item value="estimates">
          <v-card>
            <v-card-title class="d-flex align-center">
              <span>Bảng dự trù kinh phí</span>
              <v-spacer />
              <span class="text-body-2 font-weight-bold text-primary">Tổng: {{ formatCurrency(totalEstimate) }}đ</span>
            </v-card-title>
            <v-table density="comfortable">
              <thead>
                <tr>
                  <th>STT</th>
                  <th>Nội dung</th>
                  <th>ĐVT</th>
                  <th class="text-right">Đơn giá</th>
                  <th class="text-right">SL</th>
                  <th class="text-right">Thành tiền</th>
                  <th>Ghi chú</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="e in estimates" :key="e.id">
                  <td>{{ e.stt }}</td>
                  <td>{{ e.noi_dung }}</td>
                  <td>{{ e.don_vi_tinh }}</td>
                  <td class="text-right">{{ formatCurrency(e.don_gia) }}</td>
                  <td class="text-right">{{ e.so_luong }}</td>
                  <td class="text-right font-weight-medium">{{ formatCurrency(e.thanh_tien) }}</td>
                  <td>{{ e.ghi_chu }}</td>
                </tr>
                <tr v-if="estimates.length === 0">
                  <td colspan="7" class="text-center text-medium-emphasis py-4">Chưa có dữ liệu dự trù</td>
                </tr>
              </tbody>
            </v-table>
          </v-card>
        </v-tabs-window-item>

        <!-- Sign list tab -->
        <v-tabs-window-item value="signlist">
          <v-card>
            <v-card-title class="text-subtitle-1 font-weight-bold">Danh sách ký nhận</v-card-title>
            <v-table density="comfortable">
              <thead>
                <tr>
                  <th>STT</th>
                  <th>Họ tên</th>
                  <th class="text-right">Số tiền</th>
                  <th class="text-right">Số ngày</th>
                  <th class="text-right">Thành tiền</th>
                  <th>Đã ký</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="s in signList" :key="s.id">
                  <td>{{ s.stt }}</td>
                  <td>{{ s.ho_ten }}</td>
                  <td class="text-right">{{ formatCurrency(s.so_tien) }}</td>
                  <td class="text-right">{{ s.so_ngay }}</td>
                  <td class="text-right font-weight-medium">{{ formatCurrency(s.thanh_tien) }}</td>
                  <td><v-icon :color="s.da_ky ? 'success' : 'grey'">{{ s.da_ky ? 'mdi-check-circle' : 'mdi-circle-outline' }}</v-icon></td>
                </tr>
                <tr v-if="signList.length === 0">
                  <td colspan="6" class="text-center text-medium-emphasis py-4">Chưa có danh sách ký nhận</td>
                </tr>
              </tbody>
            </v-table>
          </v-card>
        </v-tabs-window-item>

        <!-- History tab -->
        <v-tabs-window-item value="history">
          <v-card>
            <v-card-title class="text-subtitle-1 font-weight-bold">Lịch sử xử lý</v-card-title>
            <v-card-text>
              <v-timeline side="end" density="compact">
                <v-timeline-item
                  v-for="h in history"
                  :key="h.id"
                  dot-color="primary"
                  size="small"
                >
                  <div>
                    <div class="font-weight-medium">{{ h.hanh_dong }}</div>
                    <div class="text-body-2">{{ h.ten_nguoi_xu_ly }}</div>
                    <div class="text-caption text-medium-emphasis">{{ formatDate(h.thoi_gian) }}</div>
                    <div v-if="h.ghi_chu" class="text-body-2 mt-1">{{ h.ghi_chu }}</div>
                  </div>
                </v-timeline-item>
              </v-timeline>
              <p v-if="history.length === 0" class="text-center text-medium-emphasis py-4">Chưa có lịch sử</p>
            </v-card-text>
          </v-card>
        </v-tabs-window-item>

        <!-- Payment tab -->
        <v-tabs-window-item v-if="payment" value="payment">
          <v-card>
            <v-card-title class="text-subtitle-1 font-weight-bold">Phiếu chi {{ payment.ma_phieu_chi }}</v-card-title>
            <v-card-text>
              <v-table density="compact">
                <tbody>
                  <tr><td class="text-medium-emphasis" width="160">Mã phiếu chi</td><td class="font-weight-medium">{{ payment.ma_phieu_chi }}</td></tr>
                  <tr><td class="text-medium-emphasis">Ngày chi</td><td>{{ payment.ngay_chi }}</td></tr>
                  <tr><td class="text-medium-emphasis">Người nhận</td><td>{{ payment.nguoi_nhan }}</td></tr>
                  <tr><td class="text-medium-emphasis">Nội dung</td><td>{{ payment.noi_dung }}</td></tr>
                  <tr><td class="text-medium-emphasis">Số tiền</td><td class="font-weight-bold text-success">{{ formatCurrencyFull(payment.so_tien) }}</td></tr>
                  <tr><td class="text-medium-emphasis">Bằng chữ</td><td>{{ payment.bang_chu }}</td></tr>
                  <tr><td class="text-medium-emphasis">Hình thức</td><td>{{ payment.hinh_thuc === 'chuyen_khoan' ? 'Chuyển khoản' : 'Tiền mặt' }}</td></tr>
                </tbody>
              </v-table>
            </v-card-text>
          </v-card>
        </v-tabs-window-item>

        <!-- Files tab -->
        <v-tabs-window-item value="files">
          <v-card>
            <v-card-title class="text-subtitle-1 font-weight-bold">Tệp đính kèm</v-card-title>
            <v-card-text>
              <v-list v-if="files.length > 0">
                <v-list-item v-for="f in files" :key="f.id" prepend-icon="mdi-file-outline">
                  <v-list-item-title>{{ f.ten_file }}</v-list-item-title>
                </v-list-item>
              </v-list>
              <p v-else class="text-medium-emphasis text-center py-4">Không có tệp đính kèm</p>
            </v-card-text>
          </v-card>
        </v-tabs-window-item>
      </v-tabs-window>
    </template>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" :timeout="3000" location="top">
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>
