import api from './client'

export async function getSLA() {
  const { data } = await api.get('/config/sla')
  return data
}

export async function saveSLA(sla) {
  const { data } = await api.put('/config/sla', sla)
  return data
}
