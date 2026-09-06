/**
 * Alan Mobile Design System (AMDS) v1.0
 * Tailwind preset. Use in web previews, Storybook, Next.js docs site, or
 * React Native via NativeWind. Import as a preset:
 *
 *   // tailwind.config.js
 *   module.exports = { presets: [require('./tokens/tailwind.config.js')] }
 *
 * Dark mode is class-based: add `class="dark"` (or `data-theme="dark"`) on <html>.
 * Semantic color aliases (bg-surface, text-primary, border-DEFAULT ...) resolve
 * per-theme through CSS variables declared in tokens/variables.css.
 */

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class', '[data-theme="dark"]'],
  theme: {
    // Breakpoints match AMDS responsive tiers (mobile-first).
    screens: {
      xs: '320px',   // phone small
      sm: '375px',   // phone medium
      md: '430px',   // phone large
      lg: '600px',   // tablet portrait
      xl: '905px',   // tablet landscape
      '2xl': '1240px',
    },
    extend: {
      colors: {
        // Raw ramps (use sparingly; prefer semantic aliases below)
        green: {
          50: '#F0FDF4', 100: '#DCFCE7', 200: '#BBF7D0', 300: '#86EFAC',
          400: '#4ADE80', 500: '#22C55E', 600: '#16A34A', 700: '#15803D',
          800: '#166534', 900: '#14532D', 950: '#052E16',
        },
        neutral: {
          0: '#FFFFFF', 50: '#F8FAFC', 100: '#F1F5F9', 200: '#E2E8F0',
          300: '#CBD5E1', 400: '#94A3B8', 500: '#64748B', 600: '#475569',
          700: '#334155', 800: '#1E293B', 900: '#0F172A', 950: '#020617',
        },
        amber: { 50: '#FFFBEB', 500: '#F59E0B', 600: '#D97706' },
        red:   { 50: '#FEF2F2', 500: '#EF4444', 600: '#DC2626' },
        sky:   { 50: '#F0F9FF', 500: '#0EA5E9', 600: '#0284C7' },

        // Semantic aliases (theme-aware via CSS variables)
        primary: {
          DEFAULT: 'var(--amds-primary)',
          hover: 'var(--amds-primary-hover)',
          pressed: 'var(--amds-primary-pressed)',
          container: 'var(--amds-primary-container)',
          fg: 'var(--amds-on-primary)',
        },
        secondary: 'var(--amds-secondary)',
        background: 'var(--amds-background)',
        surface: {
          DEFAULT: 'var(--amds-surface)',
          variant: 'var(--amds-surface-variant)',
        },
        content: {
          primary: 'var(--amds-text-primary)',
          secondary: 'var(--amds-text-secondary)',
          tertiary: 'var(--amds-text-tertiary)',
          disabled: 'var(--amds-text-disabled)',
          link: 'var(--amds-text-link)',
          onColor: 'var(--amds-text-on-color)',
        },
        border: {
          DEFAULT: 'var(--amds-border)',
          strong: 'var(--amds-border-strong)',
          focus: 'var(--amds-border-focus)',
        },
        success: { DEFAULT: 'var(--amds-success)', container: 'var(--amds-success-container)' },
        warning: { DEFAULT: 'var(--amds-warning)', container: 'var(--amds-warning-container)' },
        danger:  { DEFAULT: 'var(--amds-danger)',  container: 'var(--amds-danger-container)' },
        info:    { DEFAULT: 'var(--amds-info)',    container: 'var(--amds-info-container)' },
      },

      fontFamily: {
        sans: ['Inter', 'SF Pro Text', 'Roboto', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'SF Mono', 'Roboto Mono', 'monospace'],
      },

      fontSize: {
        'display-lg': ['36px', { lineHeight: '44px', letterSpacing: '-0.02em', fontWeight: '700' }],
        'display-md': ['32px', { lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '700' }],
        'display-sm': ['28px', { lineHeight: '36px', letterSpacing: '-0.01em', fontWeight: '700' }],
        'heading-lg': ['24px', { lineHeight: '32px', letterSpacing: '-0.01em', fontWeight: '600' }],
        'heading-md': ['20px', { lineHeight: '28px', letterSpacing: '-0.01em', fontWeight: '600' }],
        'heading-sm': ['18px', { lineHeight: '26px', letterSpacing: '0em', fontWeight: '600' }],
        'title-lg':   ['16px', { lineHeight: '24px', letterSpacing: '0em', fontWeight: '600' }],
        'title-md':   ['14px', { lineHeight: '20px', letterSpacing: '0.005em', fontWeight: '500' }],
        'body-lg':    ['16px', { lineHeight: '24px', letterSpacing: '0em', fontWeight: '400' }],
        'body-md':    ['14px', { lineHeight: '20px', letterSpacing: '0em', fontWeight: '400' }],
        'body-sm':    ['13px', { lineHeight: '18px', letterSpacing: '0.005em', fontWeight: '400' }],
        'label':      ['14px', { lineHeight: '16px', letterSpacing: '0.01em', fontWeight: '500' }],
        'label-sm':   ['12px', { lineHeight: '16px', letterSpacing: '0.02em', fontWeight: '500' }],
        'caption':    ['12px', { lineHeight: '16px', letterSpacing: '0.01em', fontWeight: '400' }],
        'overline':   ['11px', { lineHeight: '16px', letterSpacing: '0.08em', fontWeight: '600' }],
      },

      spacing: {
        0: '0px', 1: '4px', 2: '8px', 3: '12px', 4: '16px', 5: '20px',
        6: '24px', 8: '32px', 10: '40px', 12: '48px', 16: '64px',
        'touch': '44px', 'touch-lg': '48px',
        'app-bar': '56px', 'bottom-nav': '64px', 'fab': '56px', 'field': '48px',
      },

      borderRadius: {
        xs: '4px', sm: '8px', md: '12px', lg: '16px', xl: '24px', '2xl': '32px', full: '9999px',
      },

      borderWidth: { hairline: '1px', thin: '1.5px', thick: '2px' },

      boxShadow: {
        'elevation-1': '0 1px 2px rgba(15,23,42,0.06)',
        'elevation-2': '0 2px 4px -1px rgba(15,23,42,0.08), 0 1px 2px rgba(15,23,42,0.04)',
        'elevation-3': '0 4px 8px -2px rgba(15,23,42,0.10), 0 2px 4px -1px rgba(15,23,42,0.05)',
        'elevation-4': '0 12px 20px -4px rgba(15,23,42,0.12), 0 4px 8px -2px rgba(15,23,42,0.06)',
        'elevation-5': '0 24px 40px -8px rgba(15,23,42,0.16), 0 8px 16px -4px rgba(15,23,42,0.08)',
      },

      transitionDuration: {
        instant: '100ms', fast: '150ms', base: '200ms',
        moderate: '250ms', slow: '300ms', slower: '400ms',
      },
      transitionTimingFunction: {
        standard: 'cubic-bezier(0.2,0,0,1)',
        decelerate: 'cubic-bezier(0,0,0,1)',
        accelerate: 'cubic-bezier(0.3,0,1,1)',
        spring: 'cubic-bezier(0.34,1.56,0.64,1)',
      },

      zIndex: {
        raised: '10', sticky: '100', 'app-bar': '200', drawer: '300',
        'bottom-sheet': '400', modal: '500', toast: '600', tooltip: '700',
      },
    },
  },
  plugins: [],
};
