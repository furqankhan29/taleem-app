---
name: Taleem Glass
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e1e7ff'
  surface-container-highest: '#dae2fc'
  on-surface: '#131b2e'
  on-surface-variant: '#464554'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#767586'
  outline-variant: '#c6c5d7'
  surface-tint: '#484bd6'
  primary: '#2c2abc'
  on-primary: '#ffffff'
  primary-container: '#4648d4'
  on-primary-container: '#d1d1ff'
  inverse-primary: '#c0c1ff'
  secondary: '#006590'
  on-secondary: '#ffffff'
  secondary-container: '#85cbfd'
  on-secondary-container: '#00567c'
  tertiary: '#8e0028'
  on-tertiary: '#ffffff'
  tertiary-container: '#b90538'
  on-tertiary-container: '#ffc7ca'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#06006c'
  on-primary-fixed-variant: '#2e2ebe'
  secondary-fixed: '#c8e6ff'
  secondary-fixed-dim: '#89ceff'
  on-secondary-fixed: '#001e2f'
  on-secondary-fixed-variant: '#004c6e'
  tertiary-fixed: '#ffdadb'
  tertiary-fixed-dim: '#ffb2b7'
  on-tertiary-fixed: '#40000d'
  on-tertiary-fixed-variant: '#920029'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fc'
  surface-glass: rgba(255, 255, 255, 0.7)
  ambient-shadow: rgba(70, 72, 212, 0.15)
  success-container: '#c9e6ff'
  warning-container: '#ffdad6'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  gutter: 24px
  md: 24px
  lg: 32px
  xl: 48px
  margin-mobile: 16px
  container-max: 1280px
---

## Brand & Style
Taleem embodies a **Modern Corporate** identity infused with **Glassmorphism** to create an approachable yet highly professional educational dashboard. The brand personality is "Intelligent, Transparent, and Encouraging."

The visual style relies on high-clarity interfaces, using semi-transparent surfaces and soft ambient shadows to reduce cognitive load. It balances the reliability of traditional SaaS (clean grids, structured data) with the freshness of contemporary design (vibrant accents, blur effects). The target audience includes educators and administrators who require data density without the aesthetic fatigue of legacy enterprise software.

## Colors
The palette is rooted in a deep **Indigo Primary** (#4648d4), representing stability and intelligence. This is supported by a **Cerulean Secondary** for action-oriented stability and a **Ruby Tertiary** for critical alerts and high-importance metrics.

Surface colors are predominantly off-white/lavender-tinted neutrals to maintain a soft contrast. Backgrounds utilize a subtle "Surface Bright" (#faf8ff) to ensure the white glass panels pop. Semantic colors for positive growth (secondary-fixed) and negative trends (tertiary) use container-style backgrounds to remain legible against the light UI.

## Typography
The system employs a dual-font strategy. **Hanken Grotesk** is used for display and headline roles to provide a sharp, contemporary edge to the dashboard's data points. **Inter** handles all functional, body, and label text to ensure maximum legibility at small sizes and high-density information areas.

Vertical rhythm is maintained through standardized line heights (typically 1.5x font size for body). Negative letter spacing is applied to large headings to maintain visual tension, while positive tracking is used on all-caps labels for clarity.

## Layout & Spacing
The layout follows a **Fixed Grid** model with a maximum width of 1280px. Content is structured within a bento-grid style arrangement using 24px gutters on desktop and 16px on mobile.

Breakpoints are handled at 768px (md), where the layout transitions from a single-column mobile stack to a multi-column dashboard. Mobile views include a safe area at the bottom for the fixed navigation bar. Spacing follows a 4px/8px baseline, ensuring all components align to a predictable geometric rhythm.

## Elevation & Depth
Depth is achieved through **Glassmorphism** and **Ambient Shadows**. 

1.  **Level 0 (Background):** Solid "Surface Bright" (#faf8ff).
2.  **Level 1 (Panels):** Semi-transparent white (rgba 255, 255, 255, 0.7) with a 16px backdrop-blur and a subtle 1px white border.
3.  **Level 2 (Floating Action):** Primary color surfaces with "Ambient Shadows" (0 10px 30px -10px rgba(70, 72, 212, 0.15)).

Shadows are never pure black; they are always tinted with the primary indigo hex to maintain a vibrant, clean aesthetic.

## Shapes
The UI uses a **Rounded** shape language to appear friendly and safe. 
- **Standard Components (Buttons, Inputs):** 0.5rem (8px).
- **Secondary Containers (Small Cards):** 0.75rem (12px).
- **Primary Layout Panels (Bento Cards):** 1.5rem (24px) for a soft, containerized feel.
- **Decorative Elements:** Full pill-shapes for chips and status indicators.

## Components
- **Buttons:** Primary buttons use solid fills with soft shadows. Secondary buttons use container-color fills (e.g., surface-container-high) without shadows.
- **Glass Cards:** The signature component. Must include `backdrop-filter: blur(16px)`, a thin semi-transparent border, and 24px internal padding.
- **Status Chips:** Small, pill-shaped labels with high-contrast text on 30%-50% opacity background containers of the same hue.
- **Activity Feed:** Minimalist list items with circular iconography and muted timestamp labels in `label-caps`.
- **Upcoming Class Cards:** Feature a thick 4px left-border accent corresponding to the class category color (Primary, Secondary, or Tertiary).
- **FAB:** The primary action button is a 56px circle using the primary color with a 90-degree icon rotation transition on hover.