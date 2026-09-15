<script setup>
defineProps({
  title: { type: String, required: true },
  value: { type: [String, Number], required: true },
  icon: { type: String, default: 'mdi-chart-box' },
  color: { type: String, default: 'primary' },
  gradient: { type: String, default: '' },
})
</script>

<template>
  <v-card class="stats-card overflow-hidden" :style="gradient ? { background: gradient } : {}">
    <div v-if="!gradient" class="accent-bar" :style="{ background: `rgb(var(--v-theme-${color}))` }" />
    <v-card-text class="d-flex align-center pa-4">
      <div class="flex-grow-1">
        <div class="text-body-2" :class="gradient ? 'text-white-secondary' : 'text-medium-emphasis'">{{ title }}</div>
        <div class="text-h5 font-weight-bold" :style="gradient ? { color: '#FFFFFF' } : {}">{{ value }}</div>
      </div>
      <v-avatar :size="48" :class="gradient ? 'icon-on-gradient' : ''" :color="gradient ? undefined : color" :variant="gradient ? undefined : 'tonal'">
        <v-icon :icon="icon" size="24" :color="gradient ? 'white' : undefined" />
      </v-avatar>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.accent-bar {
  height: 4px;
  width: 100%;
}
.text-white-secondary {
  color: rgba(255, 255, 255, 0.85);
}
.icon-on-gradient {
  background: rgba(255, 255, 255, 0.18) !important;
}
</style>
