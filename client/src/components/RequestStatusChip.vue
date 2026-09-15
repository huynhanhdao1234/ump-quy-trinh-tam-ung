<script setup>
import { computed } from 'vue'
import { STATUS_LABELS, STATUS_COLORS, STATUS_ICONS } from '@/utils/constants'

const STATUS_BG = {
  cho_tiep_nhan: '#DBEAFE',
  hoan_tat: '#D1FAE5',
  cho_kiem_tra: '#FED7AA',
  da_duyet: '#CCFBF1',
  cho_duyet: '#EDE9FE',
  can_bo_sung: '#FEF3C7',
  tu_choi: '#FEE2E2',
  da_chi: '#E0E7FF',
}

const props = defineProps({
  status: { type: String, required: true },
  size: { type: String, default: 'default' },
})

const label = computed(() => STATUS_LABELS[props.status] || props.status)
const color = computed(() => STATUS_COLORS[props.status] || 'grey')
const icon = computed(() => STATUS_ICONS[props.status] || 'mdi-circle')
const bgColor = computed(() => STATUS_BG[props.status])
</script>

<template>
  <v-chip
    :color="color"
    :size="size"
    :prepend-icon="icon"
    variant="tonal"
    :style="bgColor ? { background: bgColor } : {}"
  >
    {{ label }}
  </v-chip>
</template>
