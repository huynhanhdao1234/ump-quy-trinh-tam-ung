import { defineStore } from 'pinia'
import { ref } from 'vue'
import * as notifApi from '@/api/notifications'

export const useNotificationsStore = defineStore('notifications', () => {
  const items = ref([])
  const unreadCount = ref(0)
  let pollTimer = null

  async function fetchUnreadCount() {
    try {
      const data = await notifApi.getUnreadCount()
      unreadCount.value = data.count || 0
    } catch {
      /* ignore */
    }
  }

  async function fetchAll() {
    try {
      items.value = await notifApi.getMyNotifications()
    } catch {
      items.value = []
    }
  }

  async function markRead(id) {
    await notifApi.markRead(id)
    const item = items.value.find((n) => n.id === id)
    if (item) item.da_doc = true
    unreadCount.value = Math.max(0, unreadCount.value - 1)
  }

  async function markAllRead() {
    await notifApi.markAllRead()
    items.value.forEach((n) => (n.da_doc = true))
    unreadCount.value = 0
  }

  function startPolling() {
    if (pollTimer) return
    fetchUnreadCount()
    pollTimer = setInterval(fetchUnreadCount, 30000)
  }

  function stopPolling() {
    if (pollTimer) {
      clearInterval(pollTimer)
      pollTimer = null
    }
  }

  return {
    items, unreadCount,
    fetchAll, fetchUnreadCount, markRead, markAllRead,
    startPolling, stopPolling,
  }
})
