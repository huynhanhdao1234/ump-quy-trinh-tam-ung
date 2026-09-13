---
name: UMP Finance Governance
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#434654'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#737686'
  outline-variant: '#c3c5d7'
  surface-tint: '#1353d8'
  primary: '#003fb1'
  on-primary: '#ffffff'
  primary-container: '#1a56db'
  on-primary-container: '#d4dcff'
  inverse-primary: '#b5c4ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#7ef6be'
  on-secondary-container: '#00714c'
  tertiary: '#5e00cd'
  on-tertiary: '#ffffff'
  tertiary-container: '#7730eb'
  on-tertiary-container: '#e6d7ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b5c4ff'
  on-primary-fixed: '#00174d'
  on-primary-fixed-variant: '#003dab'
  secondary-fixed: '#81f9c1'
  secondary-fixed-dim: '#63dca6'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#eaddff'
  tertiary-fixed-dim: '#d2bbff'
  on-tertiary-fixed: '#25005a'
  on-tertiary-fixed-variant: '#5a00c6'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
  status-nhap: '#9ca3af'
  status-cho-tiep-nhan: '#eab308'
  status-cho-kiem-tra: '#f97316'
  status-can-bo-sung: '#e02424'
  status-cho-duyet: '#3f83f8'
  status-da-duyet: '#84e1bc'
  status-tu-choi: '#9b1c1c'
  status-da-chi: '#046c4e'
  status-hoan-tat: '#7e3af2'
  notification-red: '#f05252'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 12px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 32px
  container-max: 1440px
---

## Brand & Style

This design system is built on a **Corporate / Modern** aesthetic, specifically tailored for the administrative rigor of the UMP Trade Union Finance System. The brand personality is authoritative yet accessible, emphasizing transparency and institutional trust. 

The style utilizes a high-density information architecture typical of financial software, but softens it with generous whitespace and a refined color palette. The visual language conveys precision through crisp edges, structured grids, and a systematic approach to state management, ensuring union officials can process complex financial data with minimal cognitive load and high confidence.

## Colors

The palette is anchored by **Deep Blue (#1a56db)**, a color that signifies stability and official governance. The color strategy relies heavily on semantic clarity to guide users through financial workflows:

- **Primary:** Used for primary actions, navigation headers, and active UI states.
- **Surface Colors:** The background uses a very subtle blue-tinted white (`#f8f9ff`) to reduce screen glare during long working hours.
- **Status Colors:** A comprehensive set of named colors is used to represent the lifecycle of a financial request. Each status has a dedicated hue to ensure immediate recognition in dense data tables. 
- **Notifications:** A vibrant **Notification Red** is reserved exclusively for menu badges to signal urgent attention or pending tasks.

## Typography

**Inter** is the exclusive typeface for the system, chosen for its exceptional legibility in data-heavy environments and its neutral, professional tone.

- **Data Tables:** Use `body-md` for row content to maximize information density without sacrificing readability.
- **Labels:** Status tags and table headers use `label-md` with a slight letter spacing to differentiate metadata from primary data.
- **Numerical Data:** For currency and financial figures, ensure tabular lining figures are used (where numbers align vertically) to allow for easy comparison of amounts in columns.

## Layout & Spacing

The system employs a **Fluid Grid** architecture to accommodate the wide variety of screen sizes used by union officials, from high-resolution office monitors to tablets in the field.

- **Grid:** A 12-column grid system with 20px gutters. 
- **Data Density:** In financial views, a "Compact" spacing mode (using 4px/8px increments) is applied to tables to allow for more rows per screen.
- **Form Layouts:** Financial input forms should follow a structured 1 or 2-column layout to ensure a clear vertical scanning path. 
- **Breakpoints:**
  - **Mobile:** Single column, margins reduced to 16px.
  - **Tablet:** 8-column configuration, sidebar transitions to a collapsed state.
  - **Desktop:** Full 12-column layout with a fixed-width persistent navigation sidebar.

## Elevation & Depth

To maintain a "clean and professional" look, the system uses **Low-contrast outlines** and **Tonal layers** rather than heavy shadows.

- **Base Layer:** The main background is the `surface` color.
- **Content Cards:** Use a white background with a 1px `outline-variant` border. No shadow is used for static cards to keep the UI flat and focused.
- **Interactive Elements:** Buttons and inputs gain a subtle 2px soft shadow only on hover to provide tactile feedback.
- **Modals/Overlays:** Use a medium-diffusion shadow (8% opacity) to create distinct separation when a user is performing a specific sub-task, like approving a voucher.

## Shapes

The design system uses a **Soft** shape language (`roundedness: 1`). This subtle 4px corner radius maintains the "Professional" requirement by avoiding the overly casual nature of pill shapes while feeling more modern and accessible than sharp, 90-degree corners. 

- **Inputs and Buttons:** Standardized at 4px.
- **Status Tags:** Use 4px for a consistent "ticket" look across all tag types.
- **Cards:** May use up to 8px (`rounded-lg`) to define major sections of the dashboard.

## Components

### 1. Status Tags
Tags must use a low-saturation background of the named status color with a high-saturation text of the same hue.
- **Format:** `label-md`, uppercase, 4px border radius.
- **Example:** "Đã Duyệt" uses a light green background with dark green text.

### 2. Data Tables & Actions
- **Header:** Sticky headers with a subtle `surface-container` background.
- **Rows:** Zebra-striping or 1px bottom borders. Hover state highlights the entire row in `primary-container` (at 5% opacity).
- **Actions:** Use a "More" (three-dot) menu for secondary actions and primary icon-buttons (edit/view) for immediate tasks.

### 3. Dynamic Currency Inputs
- **Logic:** Fields must include a "helper text" area directly below that dynamically converts numerical input (e.g., 1,000,000) into Vietnamese text (Một triệu đồng chẵn).
- **Formatting:** Numbers must auto-format with dot separators (e.g., 1.000.000) as the user types.

### 4. Notification Badges
- **Menu Items:** Small circular badges in `notification-red`. 
- **Behavior:** If the count is >99, display "99+". Badges should be positioned at the top-right corner of the icon or menu label.

### 5. Input Fields
- **State:** Active inputs use a 2px `primary-color` border. 
- **Error:** Fields in error state use `status-can-bo-sung` color for borders and helper text.