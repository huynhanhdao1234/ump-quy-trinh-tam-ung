import api from './client'

export async function getUnits() {
  const { data } = await api.get('/units')
  return data
}

export async function getUnitById(id) {
  const { data } = await api.get(`/units/${id}`)
  return data
}

export async function saveUnit(payload) {
  const id = payload.id || payload._id
  if (id) {
    const { data } = await api.put(`/units/${id}`, payload)
    return data
  }
  const { data } = await api.post('/units', payload)
  return data
}
