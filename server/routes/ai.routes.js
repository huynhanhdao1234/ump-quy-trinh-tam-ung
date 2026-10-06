const { Router } = require('express');
const { authenticate } = require('../middleware/auth');

const router = Router();
router.use(authenticate);

const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
// openrouter/free routes to whichever free model is available; the Nemotron models are fallbacks
// when it times out or picks a model that returns an unusable answer.
const AI_MODELS = [
  'openrouter/free',
  'nvidia/nemotron-3-super-120b-a12b:free',
  'nvidia/nemotron-3-ultra-550b-a55b:free',
];

async function callModel(model, messages) {
  const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
      'Content-Type': 'application/json',
      'X-Title': 'UMP Quan ly Tam ung',
    },
    body: JSON.stringify({ model, messages }),
    signal: AbortSignal.timeout(40000),
  });
  if (res.status === 401 || res.status === 402) {
    console.error(`OpenRouter ${res.status}:`, await res.text());
    const err = new Error(res.status === 401
      ? 'Khóa AI không hợp lệ, vui lòng liên hệ quản trị viên'
      : 'Tài khoản AI đã hết hạn mức, vui lòng liên hệ quản trị viên');
    err.fatal = true;
    throw err;
  }
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
  const data = await res.json();
  // OpenRouter can report upstream failures (e.g. provider overloaded) inside a 200 response.
  if (data.error) throw new Error(`upstream: ${JSON.stringify(data.error)}`);
  const content = data.choices?.[0]?.message?.content?.trim();
  if (!content) throw new Error('empty response');
  return { content, servedBy: data.model };
}

async function chatCompletion(messages, isValid = () => true) {
  if (!OPENROUTER_API_KEY) throw new Error('OPENROUTER_API_KEY chưa được cấu hình');
  for (const model of AI_MODELS) {
    try {
      const { content, servedBy } = await callModel(model, messages);
      if (!isValid(content)) throw new Error('invalid format');
      console.log(`AI answered by ${servedBy}`);
      return content;
    } catch (err) {
      if (err.fatal) throw err;
      console.warn(`AI model ${model} failed, trying next:`, err.message.slice(0, 300));
    }
  }
  throw new Error('AI đang quá tải hoặc đã hết lượt miễn phí, vui lòng thử lại sau ít phút');
}

function parseChecks(text) {
  return JSON.parse(text.slice(text.indexOf('['), text.lastIndexOf(']') + 1));
}

const PROCESS_CONTEXT = `Bạn là trợ lý AI của Hệ thống Quản lý Tạm ứng Tài chính Công đoàn — CĐCS Đại học Y Dược TP.HCM.

Quy trình tạm ứng gồm 6 bước:
1. Nộp hồ sơ — Người đề nghị tạo hồ sơ tạm ứng (bảng dự trù HSTU-01, danh sách ký nhận)
2. Tiếp nhận — Chuyên viên VPCĐ kiểm tra hình thức, tiếp nhận hồ sơ (SLA: 1 ngày làm việc)
3. Kiểm tra — Kế toán CĐ kiểm tra chứng từ, tính hợp lệ (SLA: 3 ngày làm việc)
4. Phê duyệt — Chủ tịch CĐCS xét duyệt, quyết định số tiền duyệt (SLA: 1 ngày làm việc)
5. Chi tiền — Thủ quỹ lập phiếu chi C41-BB, chi tiền mặt hoặc chuyển khoản (SLA: 3 ngày làm việc)
6. Hoàn tất — Kế toán + Chuyên viên lưu hồ sơ, kết thúc quy trình (SLA: 3 ngày làm việc)

5 vai trò: Người đề nghị (nguoi_de_nghi), Chuyên viên VPCĐ (chuyen_vien), Kế toán CĐ (ke_toan), Thủ quỹ (thu_quy), Chủ tịch CĐCS (chu_tich).

Trạng thái hồ sơ: nhap, cho_tiep_nhan, cho_kiem_tra, can_bo_sung, cho_duyet, da_duyet, tu_choi, da_chi, hoan_tat.

Chủ tịch có thể: phê duyệt, từ chối, hoặc yêu cầu bổ sung hồ sơ.`;

// POST /api/ai/summarize
router.post('/summarize', async (req, res) => {
  try {
    const { request, estimates, signList, history } = req.body;

    const prompt = `${PROCESS_CONTEXT}

Hãy tóm tắt ngắn gọn hồ sơ tạm ứng sau đây bằng tiếng Việt (3-5 câu):

Mã hồ sơ: ${request.ma_ho_so}
Người đề nghị: ${request.nguoi_de_nghi?.ho_ten || request.ten_nguoi_de_nghi || ''}
Đơn vị: ${request.don_vi?.ten_don_vi || request.ten_don_vi || ''}
Lý do: ${request.ly_do}
Số tiền đề nghị: ${Number(request.so_tien_de_nghi).toLocaleString('vi-VN')}đ
Số tiền duyệt: ${request.so_tien_duyet ? Number(request.so_tien_duyet).toLocaleString('vi-VN') + 'đ' : 'Chưa duyệt'}
Trạng thái: ${request.trang_thai}

Dự trù kinh phí (${estimates?.length || 0} hạng mục):
${(estimates || []).map(e => `- ${e.noi_dung}: ${Number(e.don_gia).toLocaleString('vi-VN')}đ x ${e.so_luong} = ${Number(e.thanh_tien).toLocaleString('vi-VN')}đ`).join('\n')}

Danh sách ký nhận (${signList?.length || 0} người):
${(signList || []).map(s => `- ${s.ho_ten}: ${Number(s.thanh_tien).toLocaleString('vi-VN')}đ (${s.da_ky ? 'Đã ký' : 'Chưa ký'})`).join('\n')}

Lịch sử xử lý (${history?.length || 0} bước):
${(history || []).map(h => `- ${h.hanh_dong} bởi ${h.ten_nguoi_xu_ly}${h.ghi_chu ? ': ' + h.ghi_chu : ''}`).join('\n')}

Tóm tắt:`;

    const summary = await chatCompletion([{ role: 'user', content: prompt }]);
    res.json({ summary });
  } catch (err) {
    console.error('AI summarize error:', err);
    res.status(500).json({ error: err.message || 'Lỗi khi tóm tắt hồ sơ' });
  }
});

// POST /api/ai/check
router.post('/check', async (req, res) => {
  try {
    const { request, estimates, signList } = req.body;

    const prompt = `${PROCESS_CONTEXT}

Bạn là Kế toán CĐ đang kiểm tra hồ sơ tạm ứng. Hãy phân tích hồ sơ sau và trả về danh sách kiểm tra dưới dạng JSON.

Hồ sơ:
- Mã: ${request.ma_ho_so}
- Lý do: ${request.ly_do}
- Số tiền đề nghị: ${Number(request.so_tien_de_nghi).toLocaleString('vi-VN')}đ
- Tháng/năm: ${request.thang_nam || 'Không có'}
- Loại dự trù: ${request.loai_du_tru || 'HSTU-01'}

Dự trù kinh phí (${estimates?.length || 0} hạng mục):
${(estimates || []).map(e => `- ${e.noi_dung}: ${Number(e.don_gia).toLocaleString('vi-VN')}đ x ${e.so_luong} ${e.don_vi_tinh} = ${Number(e.thanh_tien).toLocaleString('vi-VN')}đ`).join('\n')}
Tổng dự trù: ${(estimates || []).reduce((s, e) => s + Number(e.thanh_tien || 0), 0).toLocaleString('vi-VN')}đ

Danh sách ký nhận (${signList?.length || 0} người):
${(signList || []).map(s => `- ${s.ho_ten}: ${Number(s.so_tien).toLocaleString('vi-VN')}đ x ${s.so_ngay} ngày`).join('\n')}

Kiểm tra các tiêu chí:
1. Lý do tạm ứng có rõ ràng, hợp lệ không?
2. Bảng dự trù có đầy đủ không (ít nhất 1 hạng mục)?
3. Số tiền có hợp lý không (so với mặt bằng chung)?
4. Tổng dự trù có khớp với số tiền đề nghị không?
5. Danh sách ký nhận có phù hợp không?
6. Có dấu hiệu bất thường không (số tiền quá lớn, hạng mục không liên quan)?

Trả về CHÍNH XÁC JSON (không markdown, không giải thích thêm):
[{"status": "ok|warning|error", "message": "Mô tả ngắn gọn kết quả kiểm tra"}]`;

    const text = await chatCompletion([{ role: 'user', content: prompt }], (t) => {
      try { return Array.isArray(parseChecks(t)); } catch { return false; }
    });
    res.json({ checks: parseChecks(text) });
  } catch (err) {
    console.error('AI check error:', err);
    res.status(500).json({ error: err.message || 'Lỗi khi kiểm tra hồ sơ' });
  }
});

// POST /api/ai/draft-comment
router.post('/draft-comment', async (req, res) => {
  try {
    const { request, action, context } = req.body;

    const actionLabels = {
      tiep_nhan: 'tiếp nhận hồ sơ',
      hop_le: 'xác nhận hồ sơ hợp lệ',
      phe_duyet: 'phê duyệt hồ sơ',
      tu_choi: 'từ chối hồ sơ',
      yeu_cau_bo_sung: 'yêu cầu bổ sung hồ sơ',
      da_chi: 'xác nhận đã chi tiền',
      hoan_tat: 'hoàn tất hồ sơ',
    };

    const prompt = `${PROCESS_CONTEXT}

Bạn đang giúp người dùng soạn nhận xét/ghi chú cho hành động "${actionLabels[action] || action}" trên hồ sơ tạm ứng.

Hồ sơ:
- Mã: ${request.ma_ho_so}
- Lý do: ${request.ly_do}
- Số tiền đề nghị: ${Number(request.so_tien_de_nghi).toLocaleString('vi-VN')}đ
- Trạng thái hiện tại: ${request.trang_thai}
${context ? `- Thông tin thêm: ${context}` : ''}

Hãy viết một nhận xét ngắn gọn (1-2 câu), chuyên nghiệp, phù hợp với hành động "${actionLabels[action] || action}". Chỉ trả về nội dung nhận xét, không giải thích thêm.`;

    const comment = await chatCompletion([{ role: 'user', content: prompt }]);
    res.json({ comment });
  } catch (err) {
    console.error('AI draft-comment error:', err);
    res.status(500).json({ error: err.message || 'Lỗi khi tạo nhận xét' });
  }
});

// POST /api/ai/chat
router.post('/chat', async (req, res) => {
  try {
    const { message, history } = req.body;

    const messages = [
      { role: 'system', content: PROCESS_CONTEXT + '\n\nTôi là trợ lý AI của Hệ thống Quản lý Tạm ứng Tài chính Công đoàn. Tôi có thể giúp bạn tra cứu quy trình, giải đáp thắc mắc về tạm ứng tài chính, và hướng dẫn sử dụng hệ thống.' },
      ...(history || []).map(h => ({
        role: h.role === 'user' ? 'user' : 'assistant',
        content: h.content,
      })),
      { role: 'user', content: message },
    ];

    const reply = await chatCompletion(messages);
    res.json({ reply });
  } catch (err) {
    console.error('AI chat error:', err);
    res.status(500).json({ error: err.message || 'Lỗi khi trả lời câu hỏi' });
  }
});

module.exports = router;
