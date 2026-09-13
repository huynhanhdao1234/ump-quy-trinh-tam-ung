import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import { STATUS_LABELS } from '@/utils/constants'
import { formatCurrency } from '@/utils/money'

const fontCache = {}

function arrayBufferToBase64(buf) {
  const bytes = new Uint8Array(buf)
  let binary = ''
  for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i])
  return btoa(binary)
}

async function loadViFont(doc) {
  const fonts = [
    { url: 'https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.12/fonts/Roboto/Roboto-Regular.ttf', file: 'Roboto-Regular.ttf', style: 'normal' },
    { url: 'https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.12/fonts/Roboto/Roboto-Medium.ttf', file: 'Roboto-Medium.ttf', style: 'bold' },
  ]
  await Promise.all(fonts.map(async (f) => {
    if (!fontCache[f.file]) {
      const res = await fetch(f.url)
      if (!res.ok) throw new Error(`Font fetch failed: ${f.file}`)
      fontCache[f.file] = await res.arrayBuffer()
    }
    doc.addFileToVFS(f.file, arrayBufferToBase64(fontCache[f.file]))
    doc.addFont(f.file, 'Roboto', f.style)
  }))
  doc.setFont('Roboto')
}

function mapRow(r) {
  return {
    ma_ho_so: r.ma_ho_so || '',
    nguoi_de_nghi: r.nguoi_de_nghi?.ho_ten || r.ten_nguoi_de_nghi || '',
    don_vi: r.don_vi?.ten_don_vi || r.ten_don_vi || '',
    ly_do: r.ly_do || '',
    so_tien_de_nghi: Number(r.so_tien_de_nghi) || 0,
    so_tien_duyet: r.so_tien_duyet ? Number(r.so_tien_duyet) : null,
    trang_thai: STATUS_LABELS[r.trang_thai] || r.trang_thai,
    ngay_tao: r.created_at ? new Date(r.created_at).toLocaleDateString('vi-VN') : '',
  }
}

export function exportToExcel(data, filename = 'bao-cao-tam-ung') {
  const headers = [
    'Mã hồ sơ',
    'Người đề nghị',
    'Đơn vị',
    'Lý do',
    'Số tiền đề nghị',
    'Số tiền duyệt',
    'Trạng thái',
    'Ngày tạo',
  ]

  const rows = data.map(r => {
    const m = mapRow(r)
    return [
      m.ma_ho_so,
      m.nguoi_de_nghi,
      m.don_vi,
      m.ly_do,
      m.so_tien_de_nghi,
      m.so_tien_duyet ?? '',
      m.trang_thai,
      m.ngay_tao,
    ]
  })

  const ws = XLSX.utils.aoa_to_sheet([headers, ...rows])
  ws['!cols'] = [
    { wch: 16 }, { wch: 24 }, { wch: 28 }, { wch: 40 },
    { wch: 18 }, { wch: 18 }, { wch: 16 }, { wch: 14 },
  ]

  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Báo cáo')
  const buf = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  saveAs(new Blob([buf], { type: 'application/octet-stream' }), `${filename}.xlsx`)
}

export async function exportToPdf(data, filename = 'bao-cao-tam-ung') {
  const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' })

  try {
    await loadViFont(doc)
  } catch {
    // fallback to default font if CDN unavailable
  }

  doc.setFontSize(14)
  doc.text('BÁO CÁO TỔNG HỢP TẠM ỨNG TÀI CHÍNH CÔNG ĐOÀN', 148, 14, { align: 'center' })
  doc.setFontSize(10)
  doc.text('CĐCS Đại học Y Dược TP. Hồ Chí Minh', 148, 20, { align: 'center' })
  doc.setFontSize(8)
  doc.text(`Ngày xuất: ${new Date().toLocaleDateString('vi-VN')}`, 148, 25, { align: 'center' })

  const headers = ['Mã HS', 'Người đề nghị', 'Đơn vị', 'Lý do', 'Tiền đề nghị', 'Tiền duyệt', 'Trạng thái', 'Ngày tạo']
  const rows = data.map(r => {
    const m = mapRow(r)
    return [
      m.ma_ho_so,
      m.nguoi_de_nghi,
      m.don_vi,
      m.ly_do,
      formatCurrency(m.so_tien_de_nghi),
      m.so_tien_duyet != null ? formatCurrency(m.so_tien_duyet) : '-',
      m.trang_thai,
      m.ngay_tao,
    ]
  })

  autoTable(doc, {
    head: [headers],
    body: rows,
    startY: 29,
    styles: { fontSize: 7, cellPadding: 1.5, font: 'Roboto' },
    headStyles: { fillColor: [27, 58, 92], font: 'Roboto' },
    columnStyles: {
      4: { halign: 'right' },
      5: { halign: 'right' },
    },
  })

  const total = data.reduce((s, r) => s + (Number(r.so_tien_de_nghi) || 0), 0)
  const finalY = doc.lastAutoTable.finalY + 6
  doc.setFontSize(9)
  doc.text(`Tổng cộng: ${formatCurrency(total)} đồng (${data.length} hồ sơ)`, 14, finalY)

  doc.save(`${filename}.pdf`)
}
