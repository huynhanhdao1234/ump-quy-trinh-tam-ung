import api from './client'

export async function getRequests() {
  const { data } = await api.get('/requests')
  return data
}

export async function getRequestById(id) {
  const { data } = await api.get(`/requests/${id}`)
  return data
}

export async function getNextRequestId() {
  const { data } = await api.get('/requests/next-id')
  return data
}

export async function createRequest(payload) {
  const { data } = await api.post('/requests', payload)
  return data
}

export async function updateRequest(id, payload) {
  const { data } = await api.put(`/requests/${id}`, payload)
  return data
}

export async function getEstimates(requestId) {
  const { data } = await api.get(`/requests/${requestId}/estimates`)
  return data
}

export async function saveEstimates(requestId, items) {
  const { data } = await api.put(`/requests/${requestId}/estimates`, { items })
  return data
}

export async function getSignList(requestId) {
  const { data } = await api.get(`/requests/${requestId}/signlist`)
  return data
}

export async function saveSignList(requestId, items) {
  const { data } = await api.put(`/requests/${requestId}/signlist`, { items })
  return data
}

export async function getPayment(requestId) {
  const { data } = await api.get(`/requests/${requestId}/payment`)
  return data
}

export async function createPayment(requestId, payload) {
  const { data } = await api.post(`/requests/${requestId}/payment`, payload)
  return data
}

export async function getNextPaymentId() {
  const { data } = await api.get('/payments/next-id')
  return data
}

export async function getHistory(requestId) {
  const { data } = await api.get(`/requests/${requestId}/history`)
  return data
}

export async function addHistory(requestId, entry) {
  const { data } = await api.post(`/requests/${requestId}/history`, entry)
  return data
}

export async function getFiles(requestId) {
  const { data } = await api.get(`/requests/${requestId}/files`)
  return data
}

export async function uploadFile(requestId, file) {
  const form = new FormData()
  form.append('file', file)
  const { data } = await api.post(`/requests/${requestId}/files`, form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })
  return data
}
