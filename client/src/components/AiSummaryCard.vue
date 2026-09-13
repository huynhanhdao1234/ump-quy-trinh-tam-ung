<script setup>
import { ref } from 'vue'
import { summarizeRequest } from '@/api/ai'

const props = defineProps({
  request: { type: Object, required: true },
  estimates: { type: Array, default: () => [] },
  signList: { type: Array, default: () => [] },
  history: { type: Array, default: () => [] },
})

const loading = ref(false)
const result = ref('')
const error = ref('')
const editing = ref(false)
const copied = ref(false)

async function generate() {
  loading.value = true
  error.value = ''
  result.value = ''
  try {
    const res = await summarizeRequest({
      request: props.request,
      estimates: props.estimates,
      signList: props.signList,
      history: props.history,
    })
    result.value = res.summary || res.content || res.text || ''
  } catch (err) {
    error.value = err.response?.data?.error || err.message || 'Lỗi khi gọi AI'
  } finally {
    loading.value = false
  }
}

async function copyToClipboard() {
  try {
    await navigator.clipboard.writeText(result.value)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch {
    // fallback
  }
}
</script>

<template>
  <v-card class="mt-4" variant="outlined">
    <v-card-title class="d-flex align-center text-subtitle-1">
      <v-icon class="mr-2" color="deep-purple">mdi-robot</v-icon>
      AI Tóm tắt hồ sơ
      <v-spacer />
      <v-btn
        v-if="!result"
        size="small"
        color="deep-purple"
        variant="tonal"
        prepend-icon="mdi-robot"
        :loading="loading"
        @click="generate"
      >
        Tóm tắt
      </v-btn>
    </v-card-title>

    <v-card-text v-if="error">
      <v-alert type="error" variant="tonal" density="compact" closable @click:close="error = ''">
        {{ error }}
      </v-alert>
    </v-card-text>

    <v-card-text v-if="result">
      <v-textarea
        v-if="editing"
        v-model="result"
        rows="6"
        auto-grow
        variant="outlined"
        density="compact"
        hide-details
      />
      <div v-else class="text-body-2" style="white-space: pre-wrap">{{ result }}</div>

      <div class="d-flex ga-2 mt-3">
        <v-btn
          size="small"
          variant="text"
          :prepend-icon="editing ? 'mdi-check' : 'mdi-pencil'"
          @click="editing = !editing"
        >
          {{ editing ? 'Xong' : 'Chỉnh sửa' }}
        </v-btn>
        <v-btn
          size="small"
          variant="text"
          :prepend-icon="copied ? 'mdi-check' : 'mdi-content-copy'"
          :color="copied ? 'success' : undefined"
          @click="copyToClipboard"
        >
          {{ copied ? 'Đã sao chép' : 'Sao chép' }}
        </v-btn>
        <v-spacer />
        <v-btn
          size="small"
          variant="text"
          prepend-icon="mdi-refresh"
          :loading="loading"
          @click="generate"
        >
          Tạo lại
        </v-btn>
      </div>
    </v-card-text>

    <v-card-text v-if="loading && !result" class="d-flex justify-center py-6">
      <v-progress-circular indeterminate color="deep-purple" size="32" />
    </v-card-text>
  </v-card>
</template>
