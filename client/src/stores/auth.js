import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as authApi from '@/api/auth'
import { ROLE_LABELS } from '@/utils/constants'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const loading = ref(false)

  const isLoggedIn = computed(() => !!user.value)
  const vaiTro = computed(() => user.value?.vai_tro)

  const isChutich = computed(() => vaiTro.value === 'chu_tich')
  const isKetoan = computed(() => vaiTro.value === 'ke_toan')
  const isChuyenvien = computed(() => vaiTro.value === 'chuyen_vien')
  const isThuquy = computed(() => vaiTro.value === 'thu_quy')
  const isNguoiDenghi = computed(() => vaiTro.value === 'nguoi_de_nghi')

  const roleLabel = computed(() => ROLE_LABELS[vaiTro.value] || vaiTro.value)

  function canReceive(req) {
    return isChuyenvien.value && req.trang_thai === 'cho_tiep_nhan'
  }
  function canCheck(req) {
    return isKetoan.value && req.trang_thai === 'cho_kiem_tra'
  }
  function canApprove(req) {
    return isChutich.value && req.trang_thai === 'cho_duyet'
  }
  function canPay(req) {
    return (isThuquy.value || isKetoan.value) && req.trang_thai === 'da_duyet'
  }
  function canArchive(req) {
    return (isKetoan.value || isChuyenvien.value) && req.trang_thai === 'da_chi'
  }
  function canEdit(req) {
    return (
      isNguoiDenghi.value &&
      user.value?.id === req.nguoi_de_nghi_id &&
      (req.trang_thai === 'nhap' || req.trang_thai === 'can_bo_sung')
    )
  }
  function canRequestRevision(req) {
    return (
      (isKetoan.value && req.trang_thai === 'cho_kiem_tra') ||
      (isChutich.value && req.trang_thai === 'cho_duyet')
    )
  }
  function canReject(req) {
    return isChutich.value && req.trang_thai === 'cho_duyet'
  }

  function getActionableStatuses() {
    if (!user.value) return []
    switch (vaiTro.value) {
      case 'chu_tich': return ['cho_duyet']
      case 'ke_toan': return ['cho_kiem_tra', 'da_duyet', 'da_chi']
      case 'chuyen_vien': return ['cho_tiep_nhan', 'da_chi']
      case 'thu_quy': return ['da_duyet']
      case 'nguoi_de_nghi': return ['nhap', 'can_bo_sung']
      default: return []
    }
  }

  function getMenuItems() {
    if (!user.value) return []
    const items = [
      { title: 'Tổng quan', icon: 'mdi-view-dashboard', to: '/dashboard' },
    ]
    if (isNguoiDenghi.value) {
      items.push({ title: 'Hồ sơ của tôi', icon: 'mdi-file-document-outline', to: '/requests' })
      items.push({ title: 'Tạo hồ sơ mới', icon: 'mdi-plus-circle-outline', to: '/requests/new' })
    } else {
      items.push({ title: 'Hồ sơ tạm ứng', icon: 'mdi-file-document-outline', to: '/requests' })
    }
    items.push({ title: 'Thông báo', icon: 'mdi-bell-outline', to: '/notifications' })
    items.push({ title: 'Báo cáo', icon: 'mdi-chart-bar', to: '/reports' })
    if (isChutich.value) {
      items.push({ title: 'Quản trị', icon: 'mdi-cog-outline', to: '/admin' })
    }
    return items
  }

  async function login(email, password) {
    loading.value = true
    try {
      const result = await authApi.login(email, password)
      localStorage.setItem('jwt_token', result.token)
      user.value = result.user
      return { success: true }
    } catch (err) {
      return { success: false, message: err.response?.data?.error || 'Lỗi đăng nhập' }
    } finally {
      loading.value = false
    }
  }

  async function checkSession() {
    const token = localStorage.getItem('jwt_token')
    if (!token) return false
    try {
      user.value = await authApi.getSession()
      return true
    } catch {
      localStorage.removeItem('jwt_token')
      user.value = null
      return false
    }
  }

  function logout() {
    localStorage.removeItem('jwt_token')
    user.value = null
  }

  return {
    user, loading, isLoggedIn, vaiTro, roleLabel,
    isChutich, isKetoan, isChuyenvien, isThuquy, isNguoiDenghi,
    canReceive, canCheck, canApprove, canPay, canArchive, canEdit,
    canRequestRevision, canReject,
    getActionableStatuses, getMenuItems,
    login, logout, checkSession,
  }
})
