import api from './client'

export async function summarizeRequest(data) {
  const { data: res } = await api.post('/ai/summarize', data)
  return res
}

export async function checkRequest(data) {
  const { data: res } = await api.post('/ai/check', data)
  return res
}

export async function draftComment(data) {
  const { data: res } = await api.post('/ai/draft-comment', data)
  return res
}

export async function chatWithAi(data) {
  const { data: res } = await api.post('/ai/chat', data)
  return res
}
