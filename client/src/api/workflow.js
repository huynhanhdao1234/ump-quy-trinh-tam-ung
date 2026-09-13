import api from './client'

export async function transition(hoSoId, hanhDong, ghiChu, soTienDuyet) {
  const { data } = await api.post('/workflow/transition', {
    hoSoId,
    hanhDong,
    ghiChu: ghiChu || null,
    soTienDuyet: soTienDuyet || null,
  })
  return data
}

export async function soThanhChu(so) {
  const { data } = await api.get(`/rpc/so-thanh-chu?so=${so}`)
  return data
}

export async function taoPhieuChi(hoSoId) {
  const { data } = await api.post('/rpc/tao-phieu-chi', { hoSoId })
  return data
}
