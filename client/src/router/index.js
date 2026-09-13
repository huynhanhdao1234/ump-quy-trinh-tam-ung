import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { guest: true },
  },
  {
    path: '/',
    redirect: '/dashboard',
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('@/views/DashboardView.vue'),
  },
  {
    path: '/requests',
    name: 'requests',
    component: () => import('@/views/RequestsView.vue'),
  },
  {
    path: '/requests/new',
    name: 'request-new',
    component: () => import('@/views/RequestFormView.vue'),
  },
  {
    path: '/requests/:id',
    name: 'request-detail',
    component: () => import('@/views/RequestDetailView.vue'),
    props: true,
  },
  {
    path: '/requests/:id/edit',
    name: 'request-edit',
    component: () => import('@/views/RequestFormView.vue'),
    props: true,
  },
  {
    path: '/reports',
    name: 'reports',
    component: () => import('@/views/ReportsView.vue'),
  },
  {
    path: '/notifications',
    name: 'notifications',
    component: () => import('@/views/NotificationsView.vue'),
  },
  {
    path: '/admin',
    name: 'admin',
    component: () => import('@/views/AdminView.vue'),
    meta: { role: 'chu_tich' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const token = localStorage.getItem('jwt_token')
  if (!to.meta.guest && !token) {
    return { name: 'login' }
  }
  if (to.meta.guest && token) {
    return { name: 'dashboard' }
  }
})

export default router
