<script setup>
import { ref } from 'vue'
import { checkRequest } from '@/api/ai'

const props = defineProps({
  request: { type: Object, required: true },
  estimates: { type: Array, default: () => [] },
  signList: { type: Array, default: () => [] },
})

const loading = ref(false)
const checks = ref([])
const error = ref('')

const iconMap = {
  ok: { icon: 'mdi-check-circle', color: 'success' },
  warning: { icon: 'mdi-alert', color: 'warning' },
  error: { icon: 'mdi-close-circle', color: 'error' },
}

async function runCheck() {
  loading.value = true
  error.value = ''
  checks.value = []
  try {
    const res = await checkRequest({
      request: props.request,
      estimates: props.estimates,
      signList: props.signList,
    })
    checks.value = res.checks || res.items || []
  } catch (err) {
    error.value = err.response?.data?.error || err.message || 'Lỗi khi gọi AI'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <v-card variant="outlined" class="mb-3">
    <v-card-title class="d-flex align-center text-subtitle-2">
      <v-icon class="mr-2" color="indigo" size="small">mdi-clipboard-check</v-icon>
      AI Kiểm tra hồ sơ
      <v-spacer />
      <v-btn
        size="x-small"
        color="indigo"
        variant="tonal"
        prepend-icon="mdi-clipboard-check"
        :loading="loading"
        @click="runCheck"
      >
        Kiểm tra
      </v-btn>
    </v-card-title>

    <v-card-text v-if="error">
      <v-alert type="error" variant="tonal" density="compact" closable @click:close="error = ''">
        {{ error }}
      </v-alert>
    </v-card-text>

    <v-card-text v-if="loading && checks.length === 0" class="d-flex justify-center py-4">
      <v-progress-circular indeterminate color="indigo" size="28" />
    </v-card-text>

    <v-list v-if="checks.length > 0" density="compact" class="py-0">
      <v-list-item v-for="(c, i) in checks" :key="i">
        <template #prepend>
          <v-icon
            :icon="iconMap[c.status]?.icon || 'mdi-information'"
            :color="iconMap[c.status]?.color || 'info'"
            size="small"
          />
        </template>
        <v-list-item-title class="text-body-2">{{ c.label }}</v-list-item-title>
        <v-list-item-subtitle v-if="c.detail" class="text-caption">{{ c.detail }}</v-list-item-subtitle>
      </v-list-item>
    </v-list>
  </v-card>
</template>
