<script setup>
import { ref, watch } from 'vue'
import { formatCurrency, parseCurrency } from '@/utils/money'

const props = defineProps({
  modelValue: { type: Number, default: 0 },
  label: { type: String, default: '' },
  rules: { type: Array, default: () => [] },
  readonly: { type: Boolean, default: false },
})

const emit = defineEmits(['update:modelValue'])

const display = ref(props.modelValue ? formatCurrency(props.modelValue) : '')

watch(() => props.modelValue, (val) => {
  const parsed = parseCurrency(display.value)
  if (parsed !== val) {
    display.value = val ? formatCurrency(val) : ''
  }
})

function onInput(val) {
  const raw = val.replace(/\./g, '').replace(/[^\d]/g, '')
  if (raw === '') {
    display.value = ''
    emit('update:modelValue', 0)
    return
  }
  const num = parseInt(raw, 10)
  display.value = formatCurrency(num)
  emit('update:modelValue', num)
}
</script>

<template>
  <v-text-field
    :model-value="display"
    :label="label"
    :rules="rules"
    :readonly="readonly"
    suffix="đ"
    @update:model-value="onInput"
  />
</template>
