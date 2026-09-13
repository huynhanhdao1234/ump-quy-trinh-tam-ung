<script setup>
import { ref } from 'vue'
import { draftComment } from '@/api/ai'

const props = defineProps({
  request: { type: Object, required: true },
  action: { type: String, default: '' },
})

const emit = defineEmits(['suggest'])

const loading = ref(false)

async function suggest() {
  loading.value = true
  try {
    const res = await draftComment({
      request: props.request,
      action: props.action,
    })
    const text = res.comment || res.content || res.text || ''
    if (text) emit('suggest', text)
  } catch {
    // silently fail — user can still type manually
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <v-btn
    size="x-small"
    variant="outlined"
    color="deep-purple"
    prepend-icon="mdi-creation"
    :loading="loading"
    @click="suggest"
  >
    AI Gợi ý
  </v-btn>
</template>
