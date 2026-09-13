<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { DEMO_ACCOUNTS } from '@/utils/constants'

const router = useRouter()
const auth = useAuthStore()

const email = ref('')
const password = ref('')
const showPassword = ref(false)
const errorMsg = ref('')
const loading = ref(false)

function fillDemo(account) {
  email.value = account.email
  password.value = account.password
  errorMsg.value = ''
}

async function handleLogin() {
  if (!email.value || !password.value) {
    errorMsg.value = 'Vui lòng nhập email và mật khẩu'
    return
  }
  loading.value = true
  errorMsg.value = ''
  const result = await auth.login(email.value, password.value)
  loading.value = false
  if (result.success) {
    router.push('/dashboard')
  } else {
    errorMsg.value = result.message
  }
}

const steps = [
  { icon: 'mdi-file-edit-outline', label: 'Nộp hồ sơ' },
  { icon: 'mdi-inbox-arrow-down', label: 'Tiếp nhận' },
  { icon: 'mdi-clipboard-check-outline', label: 'Kiểm tra' },
  { icon: 'mdi-account-check-outline', label: 'Phê duyệt' },
  { icon: 'mdi-cash-check', label: 'Chi tiền' },
  { icon: 'mdi-archive-check-outline', label: 'Hoàn tất' },
]
</script>

<template>
  <v-app>
    <v-main class="login-bg">
      <v-container fluid class="fill-height pa-0">
        <v-row class="fill-height ma-0">
          <!-- Left panel — branding -->
          <v-col cols="12" md="6" class="d-none d-md-flex flex-column justify-center align-center left-panel pa-12">
            <div class="text-center" style="max-width: 420px">
              <div class="brand-icon mb-6">
                <v-icon size="56" color="white">mdi-school</v-icon>
              </div>
              <h1 class="text-h4 font-weight-bold text-white mb-2" style="line-height: 1.3">
                Quản lý Tạm ứng Tài chính Công đoàn
              </h1>
              <p class="text-body-1 mb-10" style="color: rgba(255,255,255,0.8)">
                CĐCS Đại học Y Dược TP. Hồ Chí Minh
              </p>

              <div class="workflow-steps">
                <div v-for="(s, i) in steps" :key="i" class="step-item">
                  <div class="step-dot">
                    <v-icon size="18" color="white">{{ s.icon }}</v-icon>
                  </div>
                  <span class="step-label">{{ s.label }}</span>
                  <div v-if="i < steps.length - 1" class="step-line" />
                </div>
              </div>
            </div>
          </v-col>

          <!-- Right panel — login form -->
          <v-col cols="12" md="6" class="d-flex align-center justify-center right-panel">
            <div style="width: 100%; max-width: 400px" class="px-6 px-md-0">
              <div class="d-md-none text-center mb-8">
                <v-avatar color="primary" size="56" class="mb-3">
                  <v-icon size="32" color="white">mdi-school</v-icon>
                </v-avatar>
                <h2 class="text-h6 font-weight-bold">Quản lý Tạm ứng</h2>
                <p class="text-body-2 text-medium-emphasis">CĐCS ĐH Y Dược TP.HCM</p>
              </div>

              <h2 class="text-h5 font-weight-bold mb-1">Đăng nhập</h2>
              <p class="text-body-2 text-medium-emphasis mb-6">Nhập thông tin tài khoản để truy cập hệ thống</p>

              <v-alert v-if="errorMsg" type="error" density="compact" variant="tonal" class="mb-4" closable @click:close="errorMsg = ''">
                {{ errorMsg }}
              </v-alert>

              <v-form @submit.prevent="handleLogin">
                <v-text-field
                  v-model="email"
                  label="Email"
                  type="email"
                  prepend-inner-icon="mdi-email-outline"
                  autocomplete="email"
                  class="mb-1"
                />
                <v-text-field
                  v-model="password"
                  label="Mật khẩu"
                  :type="showPassword ? 'text' : 'password'"
                  prepend-inner-icon="mdi-lock-outline"
                  :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
                  autocomplete="current-password"
                  class="mb-4"
                  @click:append-inner="showPassword = !showPassword"
                />
                <v-btn
                  type="submit"
                  color="primary"
                  size="large"
                  block
                  :loading="loading"
                  class="mb-6"
                >
                  Đăng nhập
                </v-btn>
              </v-form>

              <div class="demo-section pa-4 rounded-lg">
                <p class="text-body-2 font-weight-medium mb-3">Tài khoản demo</p>
                <div class="d-flex flex-wrap ga-2">
                  <v-chip
                    v-for="acc in DEMO_ACCOUNTS"
                    :key="acc.email"
                    :color="acc.color"
                    variant="tonal"
                    size="small"
                    class="cursor-pointer"
                    @click="fillDemo(acc)"
                  >
                    {{ acc.role }}
                  </v-chip>
                </div>
              </div>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<style scoped>
.login-bg {
  background: #F4F6F8;
  min-height: 100vh;
}

.left-panel {
  background: linear-gradient(160deg, #1B3A5C 0%, #0D2137 60%, #00796B 100%);
  position: relative;
  overflow: hidden;
}
.left-panel::before {
  content: '';
  position: absolute;
  top: -40%; right: -30%;
  width: 600px; height: 600px;
  border-radius: 50%;
  background: rgba(255,255,255,0.03);
}

.brand-icon {
  width: 88px; height: 88px;
  border-radius: 20px;
  background: rgba(255,255,255,0.12);
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.right-panel {
  background: #fff;
}

.demo-section {
  background: #F4F6F8;
}

.workflow-steps {
  display: flex;
  justify-content: center;
  gap: 0;
  flex-wrap: wrap;
}
.step-item {
  display: flex;
  align-items: center;
  gap: 6px;
}
.step-dot {
  width: 32px; height: 32px;
  border-radius: 50%;
  background: rgba(255,255,255,0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.step-label {
  font-size: 0.75rem;
  color: rgba(255,255,255,0.8);
  white-space: nowrap;
}
.step-line {
  width: 12px; height: 2px;
  background: rgba(255,255,255,0.25);
  flex-shrink: 0;
}

.cursor-pointer { cursor: pointer; }
</style>
