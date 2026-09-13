<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, required: true },
})

const steps = [
  { key: 'nhap', label: 'Nháp', icon: 'mdi-file-edit-outline' },
  { key: 'cho_tiep_nhan', label: 'Tiếp nhận', icon: 'mdi-inbox-arrow-down' },
  { key: 'cho_kiem_tra', label: 'Kiểm tra', icon: 'mdi-clipboard-check-outline' },
  { key: 'cho_duyet', label: 'Phê duyệt', icon: 'mdi-account-check-outline' },
  { key: 'da_chi', label: 'Chi tiền', icon: 'mdi-cash-check' },
  { key: 'hoan_tat', label: 'Hoàn tất', icon: 'mdi-archive-check-outline' },
]

const statusToStep = {
  nhap: 0,
  cho_tiep_nhan: 1,
  cho_kiem_tra: 2,
  can_bo_sung: 2,
  cho_duyet: 3,
  da_duyet: 4,
  da_chi: 4,
  hoan_tat: 5,
}

const isRejected = computed(() => props.status === 'tu_choi')
const isRevision = computed(() => props.status === 'can_bo_sung')
const currentStep = computed(() => statusToStep[props.status] ?? 0)
</script>

<template>
  <v-card class="mb-3">
    <v-card-text class="py-2 px-3">
      <div class="workflow-track">
        <template v-for="(step, i) in steps" :key="step.key">
          <div
            class="workflow-step"
            :class="{
              'is-done': i < currentStep,
              'is-current': i === currentStep && !isRejected,
              'is-rejected': i === currentStep && isRejected,
              'is-revision': i === currentStep && isRevision,
            }"
          >
            <div class="step-circle">
              <v-icon v-if="i < currentStep" size="16">mdi-check</v-icon>
              <v-icon v-else-if="isRejected && i === currentStep" size="16">mdi-close</v-icon>
              <v-icon v-else-if="isRevision && i === currentStep" size="16">mdi-alert</v-icon>
              <v-icon v-else size="16">{{ step.icon }}</v-icon>
            </div>
            <span class="step-text">{{ step.label }}</span>
          </div>
          <div v-if="i < steps.length - 1" class="step-connector" :class="{ 'is-done': i < currentStep }" />
        </template>
      </div>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.workflow-track {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
  overflow-x: auto;
}

.workflow-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
}

.step-circle {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #E0E0E0;
  color: #9E9E9E;
  transition: all 0.2s;
}

.is-done .step-circle {
  background: rgb(var(--v-theme-primary));
  color: #fff;
}
.is-current .step-circle {
  background: rgb(var(--v-theme-primary));
  color: #fff;
  box-shadow: 0 0 0 4px rgba(27, 58, 92, 0.18);
}
.is-rejected .step-circle {
  background: rgb(var(--v-theme-error));
  color: #fff;
  box-shadow: 0 0 0 4px rgba(198, 40, 40, 0.18);
}
.is-revision .step-circle {
  background: rgb(var(--v-theme-warning));
  color: #fff;
  box-shadow: 0 0 0 4px rgba(230, 81, 0, 0.18);
}

.step-text {
  font-size: 0.7rem;
  color: #9E9E9E;
  white-space: nowrap;
  font-weight: 500;
}
.is-done .step-text,
.is-current .step-text {
  color: rgb(var(--v-theme-primary));
  font-weight: 600;
}
.is-rejected .step-text {
  color: rgb(var(--v-theme-error));
  font-weight: 600;
}
.is-revision .step-text {
  color: rgb(var(--v-theme-warning));
  font-weight: 600;
}

.step-connector {
  flex: 1;
  min-width: 20px;
  max-width: 60px;
  height: 3px;
  background: #E0E0E0;
  margin: 0 4px;
  margin-bottom: 18px;
  border-radius: 2px;
  transition: background 0.2s;
}
.step-connector.is-done {
  background: rgb(var(--v-theme-primary));
}
</style>
