<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useNotificationsStore } from '@/stores/notifications'

const router = useRouter()
const notifStore = useNotificationsStore()

function formatTime(ts) {
  if (!ts) return ''
  return new Date(ts).toLocaleString('vi-VN')
}

async function handleClick(notif) {
  if (!notif.da_doc) {
    await notifStore.markRead(notif.id)
  }
  if (notif.ho_so_id) {
    router.push(`/requests/${notif.ho_so_id}`)
  }
}

onMounted(() => {
  notifStore.fetchAll()
})
</script>

<template>
  <v-container fluid>
    <div class="d-flex align-center justify-space-between mb-4">
      <h1 class="text-h5">Thông báo</h1>
      <v-btn
        v-if="notifStore.unreadCount > 0"
        variant="outlined"
        size="small"
        prepend-icon="mdi-check-all"
        @click="notifStore.markAllRead()"
      >
        Đánh dấu đã đọc tất cả
      </v-btn>
    </div>

    <!-- Empty state -->
    <v-card v-if="notifStore.items.length === 0" class="text-center pa-8">
      <v-icon icon="mdi-bell-off-outline" size="64" color="grey-lighten-1" class="mb-4" />
      <div class="text-h6 text-medium-emphasis">Không có thông báo</div>
      <div class="text-body-2 text-medium-emphasis">Thông báo sẽ hiện ở đây khi có hoạt động liên quan đến bạn</div>
    </v-card>

    <!-- Notification list -->
    <v-card v-else>
      <v-list lines="two">
        <template v-for="(notif, i) in notifStore.items" :key="notif.id">
          <v-list-item
            :class="{ 'bg-blue-lighten-5': !notif.da_doc }"
            @click="handleClick(notif)"
            class="cursor-pointer"
          >
            <template #prepend>
              <v-avatar :color="notif.da_doc ? 'grey-lighten-2' : 'primary'" size="40">
                <v-icon :icon="notif.da_doc ? 'mdi-bell-outline' : 'mdi-bell-ring'" :color="notif.da_doc ? 'grey' : 'white'" />
              </v-avatar>
            </template>
            <v-list-item-title :class="{ 'font-weight-bold': !notif.da_doc }">
              {{ notif.noi_dung }}
            </v-list-item-title>
            <v-list-item-subtitle>
              {{ formatTime(notif.created_at) }}
            </v-list-item-subtitle>
            <template #append>
              <v-icon v-if="notif.ho_so_id" icon="mdi-chevron-right" size="small" color="grey" />
            </template>
          </v-list-item>
          <v-divider v-if="i < notifStore.items.length - 1" />
        </template>
      </v-list>
    </v-card>
  </v-container>
</template>
