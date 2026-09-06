# Developer Handoff

> Part of the [starter template](README.md). How design decisions reach code: token pipeline, platform integration, component API contracts, redlines, QA, and the handoff checklist.

---

## 1. Design token pipeline

```
Figma (Tokens Studio plugin)
      │  export / commit
      ▼
tokens/tokens.json         ← W3C DTCG format, single source of truth
      │  Style Dictionary build  (npm run tokens:build)
      ├─► tokens/variables.css        CSS custom properties
      ├─► tokens/tailwind.config.js   Tailwind preset
      ├─► tokens/amds_theme.dart      Flutter ThemeData + AmdsTokens extension
      ├─► tokens/Theme.kt             Compose AmdsTheme + CompositionLocals
      ├─► tokens/theme.ts             React Native theme object
      └─► ios/Tokens.swift            SwiftUI/UIKit (Color/Font/Spacing enums)
```

**Rules**

- Never hand-edit generated files — change `tokens.json` and rebuild.
- The build runs in CI on every change to `tokens.json`; a failing contrast lint blocks merge.
- Token names are stable contracts. Renames are a MINOR (with an alias) → MAJOR (removal) per [governance](../governance.md) §5.4.
- Product code imports **semantic** tokens (`colors.primary`, `spacing[4]`), never primitives (`green.600`) or raw hex.

**Style Dictionary config (reference)**

```
// build/style-dictionary.config.js
module.exports = {
  source: ['tokens/tokens.json'],
  platforms: {
    css:     { transformGroup: 'css',            buildPath: 'tokens/', files: [{ destination: 'variables.css', format: 'css/variables', options: { outputReferences: true } }] },
    tailwind:{ transformGroup: 'js',             buildPath: 'tokens/', files: [{ destination: 'tailwind.tokens.js', format: 'javascript/module-flat' }] },
    compose: { transformGroup: 'compose',        buildPath: 'tokens/', files: [{ destination: 'Theme.kt', format: 'compose/object' }] },
    flutter: { transformGroup: 'flutter',        buildPath: 'tokens/', files: [{ destination: 'amds_theme.dart', format: 'flutter/class.dart' }] },
    rn:      { transformGroup: 'react-native',   buildPath: 'tokens/', files: [{ destination: 'theme.ts', format: 'javascript/es6' }] },
    ios:     { transformGroup: 'ios-swift',      buildPath: 'ios/',    files: [{ destination: 'Tokens.swift', format: 'ios-swift/enum.swift' }] }
  }
}
```
(The committed platform files in this template are authored to the same shape so teams can start before wiring the build.)

---

## 2. Platform integration

### 2.1 Android — Jetpack Compose

```kotlin
setContent {
  AmdsTheme(darkTheme = isSystemInDarkTheme()) {
    AppScaffold()
  }
}

// usage
Text("Total", style = MaterialTheme.typography.titleMedium, color = AmdsTheme.colors.textSecondary)
Spacer(Modifier.height(AmdsTheme.spacing.md))
Card(shape = AmdsShapes.large, border = BorderStroke(1.dp, AmdsTheme.colors.border)) { … }
```

- Fonts: bundle Inter in `res/font/`, register the `FontFamily`, swap `private val Inter` in `Theme.kt`.
- Min SDK 24; target latest. Use Material 3 components themed by `colorScheme` from `AmdsTheme`.
- Edge-to-edge + `WindowInsets` for safe areas; `enableEdgeToEdge()`.
- Legacy Views: a parallel `Theme.AMDS` XML style set mapping the same tokens (`values/` + `values-night/`).

### 2.2 Android — Views (legacy / hybrid)

- `themes.xml` maps `colorPrimary`, `colorSurface`, `?attr/textAppearance*` to token values; `values-night/` for dark.
- Dimens: `@dimen/amds_space_4` = 16dp, `@dimen/amds_radius_md` = 12dp.
- Prefer migrating screens to Compose; don't build new components in Views.

### 2.3 iOS — SwiftUI

```swift
// Tokens.swift (generated)
extension Color {
  static let amdsPrimary = Color("amds/primary")        // asset catalog: Any + Dark
  static let amdsTextSecondary = Color("amds/textSecondary")
}
enum AmdsSpacing { static let md: CGFloat = 16 }

// usage
Text("Total").font(.amdsTitleMedium).foregroundStyle(Color.amdsTextSecondary)
  .padding(AmdsSpacing.md)
```

- Colors ship in an **asset catalog** with Any/Dark appearances so `Color("amds/…")` is automatically theme-aware.
- Fonts: bundle Inter (`Info.plist` `UIAppFonts`), `Font.custom("Inter", size:)` wrapped in `.amds*` text styles that scale with Dynamic Type (`relativeTo:`).
- iOS 15+; use `.safeAreaInset`, `.presentationDetents` for bottom sheets, `.confirmationDialog` for action sheets.
- Respect `@Environment(\.accessibilityReduceMotion)` and `\.sizeCategory`.

### 2.4 iOS — UIKit

- `UIColor(named:)` from the same asset catalog; `UIFontMetrics` for scaling; a `AMDSTheme` namespace for spacing/radii.

### 2.5 Flutter

```dart
MaterialApp(
  theme: AmdsTheme.light,
  darkTheme: AmdsTheme.dark,
  themeMode: ThemeMode.system,
  home: const Shell(),
);

// usage
final t = Theme.of(context).extension<AmdsTokens>()!;
Padding(
  padding: EdgeInsets.all(t.space4),
  child: Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: t.textSecondary)),
);
```

- Add Inter to `pubspec.yaml` `fonts:`.
- Use `AmdsTokens.elevation(3)` for shadows, `AmdsTokens.easeStandard` + duration getters for motion.
- `MediaQuery.textScalerOf(context)` respected automatically by `Text`.

### 2.6 React Native

```tsx
import { amdsLight, amdsDark } from '../tokens/theme';
const scheme = useColorScheme();
const theme = scheme === 'dark' ? amdsDark : amdsLight;

<Text style={{ ...theme.typography.titleMedium, color: theme.colors.textSecondary }} />
<View style={{ padding: theme.spacing[4], borderRadius: theme.radius.lg,
               borderWidth: 1, borderColor: theme.colors.border }} />
```

- Link Inter via `react-native.config.js` assets or `expo-font`.
- iOS shadows: use `theme.elevation.levelN` shadow props; Android: `elevation`.
- `allowFontScaling` left default (true); test at large scales.
- Provide a `ThemeProvider` context; don't read `useColorScheme` in every component.

---

## 3. Component API contract

Every AMDS component exposes a consistent prop surface across platforms (names adapt to platform idiom):

| Concept | Prop | Values |
|---|---|---|
| Visual emphasis | `variant` | `primary` `secondary` `tertiary` `tonal` `destructive` (component-specific) |
| Size | `size` | `sm` `md` `lg` |
| Content | `label`, `leadingIcon`, `trailingIcon`, `supportingText` | |
| State | `enabled`/`disabled`, `loading`, `error`, `selected` | booleans |
| Full width | `fullWidth` / `expand` | boolean |
| Action | `onPress` / `onClick` | callback |
| A11y | `accessibilityLabel` / `contentDescription`, `accessibilityHint`, `testID` | required where no visible text |

**Redline contract per component** (in the Figma component + this repo):

- Exact spacing (padding, gaps) in dp
- Min height / target size
- Type token per text element
- Color token per state (default/hover/focus/pressed/disabled/loading/error)
- Border width + radius token
- Icon size token
- Motion: property, duration token, easing token
- Focus ring: offset, width, color token

Example — **Button / Primary / Medium**:

```
height: 44 (min)            radius: radius.md (12)
padding: 0 16 (X)           gap icon↔label: space.2 (8)
label: type.label           icon: size.iconSm (20)
default:  bg colors.primary            fg colors.onPrimary
pressed:  bg colors.primaryPressed     scale 0.96, 100ms, ease.standard
disabled: opacity 0.38, no pointer events, not focusable
focus:    ring 2px colors.borderFocus, offset 2px
loading:  spinner 20 colors.onPrimary replaces leadingIcon, aria-busy, non-interactive
```

---

## 4. Redlines & specs from Figma

- Use **Figma Dev Mode**: designers mark sections `Ready for dev`; devs read spacing, tokens (Tokens Studio surfaces the token name, not just the value), and component props directly.
- Every spec references a **token name**, never a raw value — if Dev Mode shows `#16A34A`, the handoff is incomplete; it should show `color.primary`.
- Interaction & motion specs live in the component page (this repo [component library](../component-library/README.md) + [motion](../design-system/motion.md)), not as loose prototype notes.
- Responsive: designer provides the phone (375) frame + tablet (905) frame + notes for the breakpoints between; devs implement the adaptive rules ([design foundations](../design-system/README.md) §7, [navigation patterns](../design-system/navigation-patterns.md) §2).
- Edge cases delivered with the happy path: empty, loading, error, long text, no permission, offline, RTL, 200% text.

---

## 5. Assets

- **Icons:** Material Symbols via the font (variable, `wght`/`opsz`/`GRAD` axes) or per-icon SVG set; Lucide as SVG. One shared icon module per app; name by concept (`ic_add`, not `ic_plus_24_green`).
- **Illustrations:** SVG or Lottie; light + dark variants; `@1x` intrinsic, scale in code.
- **Raster images:** provide `@1x/@2x/@3x` (iOS) / density buckets (Android) or a single high-res + downscale; WebP/AVIF where supported.
- **Fonts:** Inter variable (`Inter-VariableFont.ttf`) or the static weights 400/500/600/700; licensed OFL — include the license.
- **App icon / splash:** generated from a master per platform spec; adaptive icon (Android), all required sizes (iOS).
- Store assets in the repo (`/assets`) or a shared package; never hotlink.

---

## 6. QA & acceptance

**Visual regression:** snapshot tests per component × variant × state × theme (Paparazzi/Roborazzi for Compose, iOSSnapshotTestCase, `golden` for Flutter, react-native snapshot / Storybook + Chromatic). CI diffs on every PR.

**Accessibility gates:** automated scanners in CI ([accessibility](../design-system/accessibility.md) §11); manual SR walkthrough of changed flows.

**Acceptance checklist per screen:**

- [ ] Matches the Figma frame at 375 and 905 (spacing, type, color tokens)
- [ ] All states implemented: default, loading (skeleton), empty, error, offline, no-permission
- [ ] Dark mode correct ([dark mode](../design-system/dark-mode.md) checklist)
- [ ] Motion uses tokens; reduced-motion path works
- [ ] Touch targets ≥44dp; safe areas respected; no content under notch/home indicator
- [ ] 200% text scale + Bold Text: no clipping/overlap
- [ ] RTL mirrored
- [ ] Deep link route works, back stack synthesized ([navigation patterns](../design-system/navigation-patterns.md) §9)
- [ ] Analytics events fire per the tracking plan
- [ ] Performance: first meaningful paint budget met; 60fps scroll on min-spec device
- [ ] Strings externalized/localizable; no hardcoded copy
- [ ] No hardcoded colors/dimensions (lint passes)

---

## 7. Handoff checklist (design → engineering)

- [ ] Figma page marked `Ready for dev`; components use published library components (no detached/local styles)
- [ ] Every element bound to a token (Dev Mode shows token names)
- [ ] Phone (375) + tablet (905) frames + breakpoint notes
- [ ] All edge-case frames present (empty/loading/error/long/RTL/200%/offline/no-permission)
- [ ] Interaction spec: what each control does, navigation target, transition (duration + easing token)
- [ ] Content: final copy, or clearly-marked placeholder + a copy ticket; number/date formats specified
- [ ] New component? → [component library](../component-library/README.md) page drafted + API proposed + a11y notes + added to the library
- [ ] Deep link route defined for any new list/detail screen
- [ ] Analytics: events, properties, and triggers listed
- [ ] Permissions/roles: which fields/actions are gated
- [ ] Open questions listed with owners
- [ ] Kickoff walkthrough scheduled (designer + engineers + QA)
