<script setup>
import { computed } from 'vue'
import { STATUS_LABELS, STATUS_COLORS, STATUS_ICONS } from '@/utils/constants'

const props = defineProps({
  status: { type: String, required: true },
  size: { type: String, default: 'default' },
})

const label = computed(() => STATUS_LABELS[props.status] || props.status)
const color = computed(() => STATUS_COLORS[props.status] || 'grey')
const icon = computed(() => STATUS_ICONS[props.status] || 'mdi-circle')
</script>

<template>
  <v-chip :color="color" :size="size" :prepend-icon="icon" variant="tonal">
    {{ label }}
  </v-chip>
</template>
