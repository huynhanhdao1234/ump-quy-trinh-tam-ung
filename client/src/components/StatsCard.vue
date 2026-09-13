<script setup>
defineProps({
  title: { type: String, required: true },
  value: { type: [String, Number], required: true },
  icon: { type: String, default: 'mdi-chart-box' },
  color: { type: String, default: 'primary' },
})
</script>

<template>
  <v-card class="stats-card overflow-hidden">
    <div class="accent-bar" :style="{ background: `rgb(var(--v-theme-${color}))` }" />
    <v-card-text class="d-flex align-center pa-4">
      <div class="flex-grow-1">
        <div class="text-body-2 text-medium-emphasis">{{ title }}</div>
        <div class="text-h5 font-weight-bold">{{ value }}</div>
      </div>
      <v-avatar :color="color" size="48" variant="tonal">
        <v-icon :icon="icon" size="24" />
      </v-avatar>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.accent-bar {
  height: 4px;
  width: 100%;
}
</style>
