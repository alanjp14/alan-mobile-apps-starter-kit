/**
 * Alan Mobile Design System (AMDS) v1.0
 * React Native theme object. Generated from tokens/tokens.json.
 *
 * Usage with a ThemeProvider (React Navigation, styled-components, unistyles,
 * or a bespoke Context):
 *
 *   import { amdsLight, amdsDark, AmdsTheme } from './tokens/theme';
 *   const theme = colorScheme === 'dark' ? amdsDark : amdsLight;
 *
 * Values are plain numbers (dp/sp) and hex strings so they drop straight into
 * StyleSheet.create without unit conversion.
 */

export const palette = {
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
  amber: { 400: '#FBBF24', 500: '#F59E0B', 600: '#D97706' },
  red: { 400: '#F87171', 500: '#EF4444', 600: '#DC2626' },
  sky: { 400: '#38BDF8', 500: '#0EA5E9', 600: '#0284C7' },
} as const;

const lightColors = {
  primary: palette.green[600],
  primaryHover: palette.green[700],
  primaryPressed: palette.green[800],
  primaryContainer: palette.green[100],
  onPrimary: palette.neutral[0],
  onPrimaryContainer: palette.green[900],
  secondary: palette.green[500],

  background: palette.neutral[50],
  onBackground: palette.neutral[900],
  surface: palette.neutral[0],
  surfaceVariant: palette.neutral[100],
  onSurface: palette.neutral[900],
  onSurfaceVariant: palette.neutral[500],

  textPrimary: palette.neutral[900],
  textSecondary: palette.neutral[500],
  textTertiary: palette.neutral[400],
  textDisabled: palette.neutral[300],
  textLink: palette.green[700],
  textOnColor: palette.neutral[0],

  border: palette.neutral[200],
  borderStrong: palette.neutral[300],
  borderFocus: palette.green[600],
  divider: palette.neutral[200],

  success: palette.green[600],
  successContainer: palette.green[50],
  warning: palette.amber[600],
  warningContainer: '#FFFBEB',
  danger: palette.red[600],
  dangerContainer: '#FEF2F2',
  info: palette.sky[600],
  infoContainer: '#F0F9FF',

  scrim: 'rgba(15, 23, 42, 0.48)',
  skeletonBase: palette.neutral[200],
  skeletonSheen: palette.neutral[100],
} as const;

const darkColors: typeof lightColors = {
  primary: palette.green[400],
  primaryHover: palette.green[300],
  primaryPressed: palette.green[200],
  primaryContainer: palette.green[900],
  onPrimary: palette.green[950],
  onPrimaryContainer: palette.green[100],
  secondary: palette.green[500],

  background: palette.neutral[950],
  onBackground: palette.neutral[50],
  surface: palette.neutral[900],
  surfaceVariant: palette.neutral[800],
  onSurface: palette.neutral[50],
  onSurfaceVariant: palette.neutral[400],

  textPrimary: palette.neutral[50],
  textSecondary: palette.neutral[400],
  textTertiary: palette.neutral[500],
  textDisabled: palette.neutral[700],
  textLink: palette.green[400],
  textOnColor: palette.neutral[950],

  border: palette.neutral[700],
  borderStrong: palette.neutral[600],
  borderFocus: palette.green[400],
  divider: palette.neutral[800],

  success: palette.green[400],
  successContainer: 'rgba(34, 197, 94, 0.16)',
  warning: palette.amber[400],
  warningContainer: 'rgba(245, 158, 11, 0.16)',
  danger: palette.red[400],
  dangerContainer: 'rgba(239, 68, 68, 0.16)',
  info: palette.sky[400],
  infoContainer: 'rgba(14, 165, 233, 0.16)',

  scrim: 'rgba(2, 6, 23, 0.64)',
  skeletonBase: palette.neutral[800],
  skeletonSheen: palette.neutral[700],
};

export const spacing = {
  0: 0, 1: 4, 2: 8, 3: 12, 4: 16, 5: 20, 6: 24, 8: 32, 10: 40, 12: 48, 16: 64,
} as const;

export const radius = {
  xs: 4, sm: 8, md: 12, lg: 16, xl: 24, '2xl': 32, full: 9999,
} as const;

export const size = {
  touchTargetMin: 44,
  fieldHeight: 48,
  appBarHeight: 56,
  bottomNavHeight: 64,
  fab: 56,
  icon: { xs: 16, sm: 20, md: 24, lg: 32, xl: 40 },
  avatar: { xs: 24, sm: 32, md: 40, lg: 56, xl: 80 },
} as const;

export const typography = {
  fontFamily: { sans: 'Inter', mono: 'JetBrainsMono' },
  displayLarge:  { fontFamily: 'Inter', fontSize: 36, lineHeight: 44, fontWeight: '700', letterSpacing: -0.7 },
  displayMedium: { fontFamily: 'Inter', fontSize: 32, lineHeight: 40, fontWeight: '700', letterSpacing: -0.6 },
  displaySmall:  { fontFamily: 'Inter', fontSize: 28, lineHeight: 36, fontWeight: '700', letterSpacing: -0.3 },
  headingLarge:  { fontFamily: 'Inter', fontSize: 24, lineHeight: 32, fontWeight: '600', letterSpacing: -0.2 },
  headingMedium: { fontFamily: 'Inter', fontSize: 20, lineHeight: 28, fontWeight: '600', letterSpacing: -0.2 },
  headingSmall:  { fontFamily: 'Inter', fontSize: 18, lineHeight: 26, fontWeight: '600', letterSpacing: 0 },
  titleLarge:    { fontFamily: 'Inter', fontSize: 16, lineHeight: 24, fontWeight: '600', letterSpacing: 0 },
  titleMedium:   { fontFamily: 'Inter', fontSize: 14, lineHeight: 20, fontWeight: '500', letterSpacing: 0.1 },
  bodyLarge:     { fontFamily: 'Inter', fontSize: 16, lineHeight: 24, fontWeight: '400', letterSpacing: 0 },
  bodyMedium:    { fontFamily: 'Inter', fontSize: 14, lineHeight: 20, fontWeight: '400', letterSpacing: 0 },
  bodySmall:     { fontFamily: 'Inter', fontSize: 13, lineHeight: 18, fontWeight: '400', letterSpacing: 0.1 },
  label:         { fontFamily: 'Inter', fontSize: 14, lineHeight: 16, fontWeight: '500', letterSpacing: 0.1 },
  labelSmall:    { fontFamily: 'Inter', fontSize: 12, lineHeight: 16, fontWeight: '500', letterSpacing: 0.2 },
  caption:       { fontFamily: 'Inter', fontSize: 12, lineHeight: 16, fontWeight: '400', letterSpacing: 0.1 },
  overline:      { fontFamily: 'Inter', fontSize: 11, lineHeight: 16, fontWeight: '600', letterSpacing: 0.9 },
} as const;

// iOS uses shadow*, Android uses elevation. Provide both.
export const elevation = {
  level1: { shadowColor: '#0F172A', shadowOpacity: 0.06, shadowRadius: 2,  shadowOffset: { width: 0, height: 1 },  elevation: 1 },
  level2: { shadowColor: '#0F172A', shadowOpacity: 0.10, shadowRadius: 4,  shadowOffset: { width: 0, height: 2 },  elevation: 3 },
  level3: { shadowColor: '#0F172A', shadowOpacity: 0.12, shadowRadius: 8,  shadowOffset: { width: 0, height: 4 },  elevation: 6 },
  level4: { shadowColor: '#0F172A', shadowOpacity: 0.16, shadowRadius: 20, shadowOffset: { width: 0, height: 12 }, elevation: 12 },
  level5: { shadowColor: '#0F172A', shadowOpacity: 0.20, shadowRadius: 40, shadowOffset: { width: 0, height: 24 }, elevation: 24 },
} as const;

export const motion = {
  duration: { instant: 100, fast: 150, base: 200, moderate: 250, slow: 300, slower: 400 },
  easing: {
    standard: [0.2, 0, 0, 1] as const,
    decelerate: [0, 0, 0, 1] as const,
    accelerate: [0.3, 0, 1, 1] as const,
    spring: [0.34, 1.56, 0.64, 1] as const,
  },
} as const;

export const breakpoints = {
  phoneSmall: 320, phoneMedium: 375, phoneLarge: 430,
  tabletPortrait: 600, tabletLandscape: 905, desktop: 1240,
} as const;

export const zIndex = {
  raised: 10, sticky: 100, appBar: 200, drawer: 300,
  bottomSheet: 400, modal: 500, toast: 600, tooltip: 700,
} as const;

export const amdsLight = {
  dark: false,
  colors: lightColors,
  spacing, radius, size, typography, elevation, motion, breakpoints, zIndex,
} as const;

export const amdsDark = {
  dark: true,
  colors: darkColors,
  spacing, radius, size, typography, elevation, motion, breakpoints, zIndex,
} as const;

export type AmdsTheme = typeof amdsLight;
export type AmdsColors = typeof lightColors;
