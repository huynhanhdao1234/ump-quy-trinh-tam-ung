<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useNotificationsStore } from '@/stores/notifications'
import { ROLE_LABELS } from '@/utils/constants'
import AiChatbot from '@/components/AiChatbot.vue'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const notif = useNotificationsStore()

const drawer = ref(true)
const isLoginPage = computed(() => route.name === 'login')
const menuItems = computed(() => auth.getMenuItems())

onMounted(async () => {
  if (!isLoginPage.value) {
    const ok = await auth.checkSession()
    if (ok) notif.startPolling()
  }
})

watch(() => auth.isLoggedIn, (val) => {
  if (val) notif.startPolling()
  else notif.stopPolling()
})

function handleLogout() {
  auth.logout()
  notif.stopPolling()
  router.push('/login')
}
</script>

<template>
  <v-app>
    <template v-if="isLoginPage">
      <router-view />
    </template>

    <template v-else>
      <v-navigation-drawer v-model="drawer" :width="260" class="sidebar-drawer">
        <div class="sidebar-brand pa-3 d-flex align-center ga-3">
          <v-avatar color="primary" size="40" rounded="lg">
            <v-icon size="22" color="white">mdi-school</v-icon>
          </v-avatar>
          <div>
            <div class="text-subtitle-2 font-weight-bold" style="line-height:1.2">Tạm ứng CĐ</div>
            <div class="text-caption text-medium-emphasis">CĐCS ĐH Y Dược TP.HCM</div>
          </div>
        </div>
        <v-divider />
        <v-list nav density="comfortable" class="px-2 mt-1">
          <v-list-item
            v-for="item in menuItems"
            :key="item.to"
            :to="item.to"
            :prepend-icon="item.icon"
            :title="item.title"
            rounded="lg"
            class="mb-1"
          >
            <template v-if="item.to === '/notifications' && notif.unreadCount > 0" #append>
              <v-badge :content="notif.unreadCount" color="error" inline />
            </template>
          </v-list-item>
        </v-list>
        <template #append>
          <v-divider />
          <div class="pa-2">
            <div class="d-flex align-center ga-2 pa-2 rounded-lg" style="background: rgb(var(--v-theme-surface-variant))">
              <v-avatar color="primary" size="36">
                <span class="text-white text-caption font-weight-bold">{{ auth.user?.ho_ten?.charAt(0) }}</span>
              </v-avatar>
              <div class="flex-grow-1" style="min-width:0">
                <div class="text-body-2 font-weight-medium text-truncate">{{ auth.user?.ho_ten }}</div>
                <div class="text-caption text-medium-emphasis text-truncate">{{ auth.roleLabel }}</div>
                <div v-if="auth.user?.don_vi?.ten_don_vi" class="text-caption text-medium-emphasis text-truncate">{{ auth.user.don_vi.ten_don_vi }}</div>
              </div>
            </div>
          </div>
        </template>
      </v-navigation-drawer>

      <v-app-bar density="default" elevation="0" class="header-bar">
        <v-app-bar-nav-icon @click="drawer = !drawer" />
        <v-toolbar-title class="text-body-1 font-weight-medium">
          Hệ thống Quản lý Tạm ứng Tài chính Công đoàn
        </v-toolbar-title>
        <v-spacer />

        <v-btn icon :to="'/notifications'" class="mr-1">
          <v-badge :content="notif.unreadCount" :model-value="notif.unreadCount > 0" color="error">
            <v-icon>mdi-bell-outline</v-icon>
          </v-badge>
        </v-btn>

        <v-menu>
          <template #activator="{ props }">
            <v-btn v-bind="props" variant="text" class="text-none">
              <v-avatar size="26" color="primary" class="mr-2">
                <span class="text-white" style="font-size:0.7rem">{{ auth.user?.ho_ten?.charAt(0) }}</span>
              </v-avatar>
              <span class="d-none d-sm-inline">{{ auth.user?.ho_ten }}</span>
              <v-icon end>mdi-chevron-down</v-icon>
            </v-btn>
          </template>
          <v-list density="compact" min-width="200">
            <v-list-item prepend-icon="mdi-account-outline">
              <v-list-item-title>{{ auth.user?.ho_ten }}</v-list-item-title>
              <v-list-item-subtitle>{{ auth.roleLabel }}</v-list-item-subtitle>
              <v-list-item-subtitle v-if="auth.user?.don_vi?.ten_don_vi">
                <v-icon size="x-small" class="mr-1">mdi-domain</v-icon>{{ auth.user.don_vi.ten_don_vi }}
              </v-list-item-subtitle>
            </v-list-item>
            <v-divider />
            <v-list-item prepend-icon="mdi-logout" title="Đăng xuất" @click="handleLogout" />
          </v-list>
        </v-menu>
      </v-app-bar>

      <v-main>
        <v-container fluid class="pa-3 pa-md-4">
          <router-view />
        </v-container>
      </v-main>

      <AiChatbot />
    </template>
  </v-app>
</template>

<style>
.sidebar-drawer .v-navigation-drawer__content {
  background: linear-gradient(180deg, #1A73E8 0%, #0A2E5C 100%) !important;
}
.sidebar-drawer {
  background: linear-gradient(180deg, #1A73E8 0%, #0A2E5C 100%) !important;
}

.sidebar-drawer .sidebar-brand .text-subtitle-2,
.sidebar-drawer .sidebar-brand .text-caption {
  color: rgba(255, 255, 255, 0.85) !important;
}

.sidebar-drawer .v-list-item {
  color: rgba(255, 255, 255, 0.85) !important;
}
.sidebar-drawer .v-list-item .v-icon {
  color: rgba(255, 255, 255, 0.85) !important;
}
.sidebar-drawer .v-list-item:hover {
  background: rgba(255, 255, 255, 0.08) !important;
}
.sidebar-drawer .v-list-item--active {
  background: rgba(255, 255, 255, 0.15) !important;
  border-left: 3px solid #FFFFFF;
}

.sidebar-drawer .v-divider {
  border-color: rgba(255, 255, 255, 0.15) !important;
}

.sidebar-drawer .v-navigation-drawer__append {
  color: rgba(255, 255, 255, 0.85) !important;
}
.sidebar-drawer .v-navigation-drawer__append .text-body-2,
.sidebar-drawer .v-navigation-drawer__append .text-caption {
  color: rgba(255, 255, 255, 0.85) !important;
}
.sidebar-drawer .v-navigation-drawer__append .rounded-lg {
  background: rgba(255, 255, 255, 0.1) !important;
}
.sidebar-drawer .v-navigation-drawer__append .v-avatar {
  background-color: rgba(255, 255, 255, 0.2) !important;
}

.header-bar {
  background-color: #FFFFFF !important;
  box-shadow: 0 2px 8px rgba(26, 115, 232, 0.08) !important;
}

.v-main {
  background-color: #EDF2F7 !important;
}

.v-table thead tr,
.v-data-table thead tr {
  background: #EBF5FF !important;
}
.v-table thead th,
.v-data-table thead th {
  background: transparent !important;
}
</style>
