import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { vi } from 'vuetify/locale'

export default createVuetify({
  components,
  directives,
  locale: {
    locale: 'vi',
    messages: { vi },
  },
  theme: {
    defaultTheme: 'umpLight',
    themes: {
      umpLight: {
        dark: false,
        colors: {
          primary: '#1B3A5C',
          'primary-darken-1': '#122940',
          secondary: '#00796B',
          accent: '#E65100',
          error: '#C62828',
          warning: '#E65100',
          info: '#00838F',
          success: '#2E7D32',
          background: '#EDF2F7',
          surface: '#FFFFFF',
          'on-primary': '#FFFFFF',
          'surface-variant': '#EEF1F5',
        },
      },
    },
  },
  defaults: {
    VBtn: { variant: 'flat', rounded: 'lg', density: 'comfortable' },
    VCard: { rounded: 'lg', elevation: 1 },
    VTextField: { variant: 'outlined', density: 'compact' },
    VSelect: { variant: 'outlined', density: 'compact' },
    VAutocomplete: { variant: 'outlined', density: 'compact' },
    VTextarea: { variant: 'outlined', density: 'compact' },
    VDataTable: { hover: true, density: 'compact' },
    VTable: { density: 'compact' },
    VList: { density: 'compact' },
    VTab: { density: 'comfortable', size: 'small' },
  },
})
