import api from './client'

export async function getUsers() {
  const { data } = await api.get('/users')
  return data
}

export async function searchUsers(q) {
  const { data } = await api.get('/users/search', { params: { q } })
  return data
}

export async function getUserById(id) {
  const { data } = await api.get(`/users/${id}`)
  return data
}

export async function saveUser(id, payload) {
  const { data } = await api.put(`/users/${id}`, payload)
  return data
}

export async function deleteUser(id) {
  const { data } = await api.delete(`/users/${id}`)
  return data
}
