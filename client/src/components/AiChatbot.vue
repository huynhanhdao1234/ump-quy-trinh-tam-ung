<script setup>
import { ref, nextTick } from 'vue'
import { chatWithAi } from '@/api/ai'

const open = ref(false)
const input = ref('')
const loading = ref(false)
const messages = ref([])
const messagesContainer = ref(null)

const suggestions = [
  'Quy trình tạm ứng gồm mấy bước?',
  'Ai có quyền phê duyệt?',
  'Thời hạn xử lý hồ sơ là bao lâu?',
]

async function send(text) {
  const msg = text || input.value.trim()
  if (!msg || loading.value) return

  input.value = ''
  messages.value.push({ role: 'user', content: msg })
  loading.value = true

  await scrollToBottom()

  try {
    const res = await chatWithAi({
      message: msg,
      history: messages.value.slice(0, -1),
    })
    messages.value.push({
      role: 'assistant',
      content: res.reply || res.content || res.text || 'Không có phản hồi.',
    })
  } catch (err) {
    messages.value.push({
      role: 'assistant',
      content: 'Xin lỗi, đã xảy ra lỗi. Vui lòng thử lại.',
    })
  } finally {
    loading.value = false
    await scrollToBottom()
  }
}

async function scrollToBottom() {
  await nextTick()
  const el = messagesContainer.value
  if (el) el.scrollTop = el.scrollHeight
}

function clearChat() {
  messages.value = []
}
</script>

<template>
  <!-- FAB trigger -->
  <v-btn
    v-if="!open"
    icon
    color="deep-purple"
    size="large"
    elevation="8"
    style="position: fixed; bottom: 24px; right: 24px; z-index: 1000"
    @click="open = true"
  >
    <v-icon>mdi-robot-outline</v-icon>
    <v-tooltip activator="parent" location="start">Trợ lý AI</v-tooltip>
  </v-btn>

  <!-- Chat panel -->
  <v-card
    v-if="open"
    elevation="12"
    rounded="lg"
    style="position: fixed; bottom: 24px; right: 24px; z-index: 1000; width: 380px; max-height: 520px; display: flex; flex-direction: column"
  >
    <!-- Header -->
    <v-toolbar color="deep-purple" density="compact" dark>
      <v-icon class="ml-3">mdi-robot-outline</v-icon>
      <v-toolbar-title class="text-body-1">Trợ lý AI Quy trình</v-toolbar-title>
      <v-spacer />
      <v-btn icon size="small" variant="text" @click="clearChat">
        <v-icon size="small">mdi-delete-outline</v-icon>
        <v-tooltip activator="parent" location="bottom">Xóa hội thoại</v-tooltip>
      </v-btn>
      <v-btn icon size="small" variant="text" @click="open = false">
        <v-icon size="small">mdi-close</v-icon>
      </v-btn>
    </v-toolbar>

    <!-- Messages -->
    <div
      ref="messagesContainer"
      style="flex: 1; overflow-y: auto; padding: 12px; min-height: 300px; max-height: 380px"
    >
      <!-- Welcome -->
      <div v-if="messages.length === 0" class="text-center py-4">
        <v-icon size="48" color="deep-purple-lighten-3">mdi-robot-happy-outline</v-icon>
        <p class="text-body-2 text-medium-emphasis mt-2 mb-3">
          Xin chào! Tôi có thể giúp bạn tìm hiểu về quy trình tạm ứng tài chính Công đoàn.
        </p>
        <div class="d-flex flex-column ga-2">
          <v-btn
            v-for="s in suggestions"
            :key="s"
            size="small"
            variant="outlined"
            color="deep-purple"
            class="text-none text-caption"
            @click="send(s)"
          >
            {{ s }}
          </v-btn>
        </div>
      </div>

      <!-- Chat messages -->
      <div v-for="(msg, i) in messages" :key="i" class="mb-3">
        <div
          :class="[
            'd-flex',
            msg.role === 'user' ? 'justify-end' : 'justify-start',
          ]"
        >
          <div
            :class="[
              'pa-2 rounded-lg text-body-2',
              msg.role === 'user'
                ? 'bg-deep-purple-lighten-5 text-deep-purple-darken-2'
                : 'bg-grey-lighten-4',
            ]"
            style="max-width: 85%; white-space: pre-wrap; word-break: break-word"
          >
            {{ msg.content }}
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="d-flex justify-start mb-3">
        <div class="pa-2 rounded-lg bg-grey-lighten-4">
          <v-progress-circular indeterminate size="16" width="2" color="deep-purple" />
          <span class="text-caption text-medium-emphasis ml-2">Đang suy nghĩ...</span>
        </div>
      </div>
    </div>

    <!-- Input -->
    <v-divider />
    <div class="pa-2 d-flex ga-2 align-center">
      <v-text-field
        v-model="input"
        placeholder="Nhập câu hỏi..."
        variant="outlined"
        density="compact"
        hide-details
        rounded="lg"
        @keyup.enter="send()"
      />
      <v-btn
        icon
        size="small"
        color="deep-purple"
        variant="flat"
        :disabled="!input.trim() || loading"
        @click="send()"
      >
        <v-icon>mdi-send</v-icon>
      </v-btn>
    </div>
  </v-card>
</template>
