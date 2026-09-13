const ones = ['', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín']
const units = ['', 'nghìn', 'triệu', 'tỷ', 'nghìn tỷ', 'triệu tỷ']

function readThreeDigits(n, showZeroHundred) {
  const h = Math.floor(n / 100)
  const t = Math.floor((n % 100) / 10)
  const o = n % 10
  let result = ''

  if (h > 0 || showZeroHundred) {
    result += ones[h] + ' trăm '
  }

  if (t > 1) {
    result += ones[t] + ' mươi '
    if (o === 1) result += 'mốt '
    else if (o === 5) result += 'lăm '
    else if (o > 0) result += ones[o] + ' '
  } else if (t === 1) {
    result += 'mười '
    if (o === 5) result += 'lăm '
    else if (o > 0) result += ones[o] + ' '
  } else if (o > 0) {
    if (h > 0 || showZeroHundred) result += 'lẻ '
    result += ones[o] + ' '
  }

  return result.trim()
}

export function numberToWords(amount) {
  if (amount === 0) return 'Không đồng'
  if (!amount || isNaN(amount)) return ''

  amount = Math.abs(Math.round(amount))
  if (amount === 0) return 'Không đồng'

  const groups = []
  let temp = amount
  while (temp > 0) {
    groups.push(temp % 1000)
    temp = Math.floor(temp / 1000)
  }

  let result = ''
  for (let i = groups.length - 1; i >= 0; i--) {
    if (groups[i] > 0) {
      const showZero = i < groups.length - 1
      result += readThreeDigits(groups[i], showZero) + ' ' + units[i] + ' '
    }
  }

  result = result.trim()
  result = result.charAt(0).toUpperCase() + result.slice(1)
  return result + ' đồng'
}

export function formatCurrency(amount) {
  if (amount === null || amount === undefined || isNaN(amount)) return '0'
  return Math.round(amount).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
}

export function formatCurrencyFull(amount) {
  return formatCurrency(amount) + ' đồng'
}

export function parseCurrency(str) {
  if (!str) return 0
  return parseInt(str.toString().replace(/\./g, '').replace(/[^\d]/g, ''), 10) || 0
}
