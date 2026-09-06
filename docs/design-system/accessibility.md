# Accessibility

> Part of the [Alan Mobile Design System](README.md). Target: **WCAG 2.2 Level AA** across all `[COMPANY_NAME]` mobile apps, aligned with EN 301 549 and platform guidance (Apple Accessibility, Android Accessibility).

---

## 1. Conformance summary

| Area | Requirement | AMDS provision |
|---|---|---|
| Text contrast | ≥ 4.5:1 (normal), ≥ 3:1 (large ≥ 18.66px bold / 24px) | Semantic text tokens verified ([design foundations](../design-system/README.md) §1.6) |
| Non-text contrast (1.4.11) | ≥ 3:1 for UI components, states, focus, meaningful graphics | Focus ring `primary`/green-400, borders, icons meet 3:1 |
| Touch target (2.5.8 AA) | ≥ 24×24 CSS px min; AMDS mandates **≥ 44×44 dp** | All interactive components; ≥ 8dp spacing |
| Text resize (1.4.4) | Usable at 200% | `sp`/scaled text everywhere; flexible containers |
| Reflow (1.4.10) | No loss at 320 CSS px width / 256px height | Mobile-first single column; horizontal scroll only for data tables/charts in their own container |
| Orientation (1.3.4) | Both orientations unless essential | Portrait lock only where justified (scanner, media) |
| Focus visible (2.4.7) + Focus appearance (2.4.11 AA) | Always visible, not obscured, ≥ 2px, ≥ 3:1 | 2px ring, 2px offset, `borderFocus` token |
| Focus not obscured (2.4.11) | Focused element not hidden by sticky headers/footers/keyboard | Scroll-into-view padding = sticky chrome height |
| Dragging movements (2.5.7 AA) | Any drag has a single-tap/button alternative | Sliders, reorder, sheet detents, swipe actions all have button equivalents |
| Target of pointer cancellation (2.5.2) | Action on up-event; abort by dragging off | Standard for all buttons |
| Consistent help (3.2.6 AA) | Help in the same relative place | Help entry point consistent per app (app bar overflow / Settings) |
| Accessible authentication (3.3.8 AA) | No cognitive test; allow paste, password managers, biometrics | Login/Register never block paste; biometric + SSO offered |
| Redundant entry (3.3.7 AA) | Don't re-ask for info in the same process | Prefill, carry forward, review steps |
| Error identification/suggestion (3.3.1/3.3.3) | Identify in text + suggest a fix | Form system [form design system](../screen-library/form-design-system.md) §6 |
| Status messages (4.1.3) | Announced without focus change | `aria-live`/announcements for toasts, counts, validation |
| Name/Role/Value (4.1.2) | Every control exposes all three | Component a11y specs, [component library](../component-library/README.md) |

---

## 2. Color & contrast

- **Verified pairs:** see [design foundations](../design-system/README.md) §1.6 (light + dark tables with exact ratios).
- **Body text on white:** `textPrimary` 17.9:1, `textSecondary` 4.76:1 (AA). Do **not** put `textSecondary` on `surfaceVariant` or `background` for essential text — only on `surface`.
- **`textTertiary` / `textDisabled`** are for decorative, placeholder, or disabled content only (contrast <3:1) — WCAG exempts disabled controls, but don't hide meaning there.
- **Primary green** `#16A34A` is 3.31:1 on white → **UI components and large text only**; button labels below 18.66px use the `#15803D` fill (5.01:1) or the label is ≥18px semibold.
- **Never encode meaning in color alone** (1.4.1): every status, chart series, and required field pairs color with an icon, label, shape, or position.
- **Focus indicator** ≥ 3:1 against the adjacent background, ≥ 2px thick, not clipped.
- Test in light, dark, and (informally) grayscale; test with "Increase Contrast" / high-contrast mode — provide a high-contrast token overlay if a client requires it.
- No pure `#000` text on pure `#FFF` for long reading (halation); AMDS uses slate-900 / slate-50.

---

## 3. Touch targets & spacing

- Minimum **44 × 44 dp** for any interactive element, even if the visual is smaller (expand the hit area).
- Minimum **8 dp** between adjacent independent targets; if visuals are tight, ensure centers are ≥ 44dp apart.
- Primary actions and destructive confirmations get larger targets (48–52dp height).
- List rows are a single target (≥ 48dp) unless they contain a distinct trailing control.
- Don't place targets in the bottom ~16dp (home indicator) or under cutouts.
- Account for reachability: primary actions in the lower half of the screen; destructive actions not under the thumb's resting arc.

---

## 4. Typography & reading

- Support Dynamic Type / font scale **85%–200%** (test 100/130/200 + Bold Text).
- Line length 40–70 chars; line-height ≥ 1.4× for body (AMDS body = 20/14 = 1.43, 24/16 = 1.5).
- No text in images (except logos); if unavoidable, provide the text alternative.
- Don't disable user zoom/scaling.
- Left-aligned, not justified; adequate paragraph spacing.
- Allow letter/line/word spacing overrides (1.4.12) without clipping.

---

## 5. Screen reader support (TalkBack / VoiceOver)

For every screen:

- **Logical reading order** matches visual order (top→bottom, leading→trailing; RTL mirrored).
- **Headings** marked as headings (app bar title, section headers) so users can navigate by heading.
- **Landmarks/regions:** navigation, main content, search — labeled.
- **Every control** exposes: role ("button", "switch", "tab"), name (verb/purpose, not the icon), state ("selected", "dimmed"/"disabled", "expanded", "on"), and value (current selection, slider value).
- **Images:** meaningful → concise `alt`/label; decorative → hidden from the a11y tree.
- **Dynamic changes:** use polite announcements for results/counts/toasts; assertive only for errors and critical alerts. Don't spam.
- **Focus management:** on navigation, focus lands on the new screen's title/first element; on dialog/sheet open, focus moves in and is trapped; on close, focus returns to the trigger; deleted items move focus to a sensible neighbor.
- **Grouping:** combine related bits into one swipe stop (list row = one stop reading "Compressor A-12, Active, updated 2 hours ago") with actions as rotor/custom actions.
- **Custom gestures** (swipe actions, drag) exposed as custom actions / buttons.
- **Live regions** for chat, monitoring feeds — throttled, summarized.
- Test the top 10 flows end-to-end with TalkBack **and** VoiceOver each release.

---

## 6. Keyboard, switch, and D-pad

Even on mobile (external keyboards, switch access, Android TV / D-pad, desktop webviews):

- Everything operable without a pointer; visible focus at all times.
- Logical tab order; no keyboard traps (except intentional modal focus traps, escapable with Esc/back).
- Standard keys: Enter/Space activate, Esc/back dismiss, arrows within composites (tabs, radios, menus, grids, sliders, date grid), Home/End where relevant.
- Shortcuts (if any) are documented, remappable or avoid single-character defaults (2.1.4), and don't clash with AT.
- Switch access: ensure scanning reaches every action; group to keep scan time reasonable; custom actions for row swipes.
- Focus never hidden behind sticky app bar, bottom nav, FAB, or the on-screen keyboard.

---

## 7. Motion & sensory

- Honor "Reduce Motion" / "Remove animations": replace slides/scales/parallax with ≤150ms crossfades or instant; stop looping/auto-playing decorative motion; keep essential feedback as non-motion cues ([motion](../design-system/motion.md) §7).
- No content flashes more than **3 times per second** over a large area.
- Auto-playing media/animation > 5s must be pausable.
- Parallax and motion-triggered UI (tilt) always have a static equivalent.
- Haptics and sound are additive, never the only signal, and respect system settings.
- Don't rely on shape/position/sound alone either — combine cues (1.3.3).

---

## 8. Forms & error prevention

See [form design system](../screen-library/form-design-system.md) §6–10. Key WCAG hooks:

- Labels visible and associated (3.3.2); required indicated in text.
- Errors identified in text, describe the problem, suggest a correction (3.3.1, 3.3.3).
- For legal/financial/data submissions: reversible, checked, or confirmed (3.3.4/3.3.6).
- Don't ask for the same info twice in one flow (3.3.7).
- Authentication: allow paste, password managers, biometrics; no puzzles or memory tests (3.3.8).
- Timeouts: warn before session expiry with an extend option (2.2.1); autosave so nothing is lost.

---

## 9. Media

- Video: captions (1.2.2), audio description or a text alternative where visuals carry info (1.2.5).
- Audio: transcripts.
- Auto-playing audio: none, or ≤3s, or an immediate control.
- Provide playback speed and volume independent of system.

---

## 10. Internationalization & RTL

- Full RTL mirroring (layout, icons that imply direction, gestures, progress) for Arabic/Hebrew.
- `lang` set correctly; don't hardcode text direction.
- Support locale formats for date, time, number, currency, first-day-of-week.
- Allow text expansion (German/Finnish ~+35%) without clipping.
- Don't concatenate translated strings; use full templated messages with placeholders.

---

## 11. Testing & tooling

**Automated (CI):**
- Contrast lint on token pairs and component snapshots.
- Accessibility scanners: Android `AccessibilityChecks` / Espresso, iOS Accessibility Audit (XCUITest `performAccessibilityAudit()`), Flutter `meetsGuideline` (`textContrastGuideline`, `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`), RN `eslint-plugin-react-native-a11y` + Detox.
- Lint rules: missing labels, low contrast, small targets, images without alt.

**Manual (each release, top flows):**
- TalkBack full walkthrough (Android) + VoiceOver (iOS).
- 200% text scale + Bold Text.
- Reduce Motion on.
- Keyboard-only / switch access.
- Grayscale + increase contrast.
- Landscape + tablet.
- Slow network / offline.

**Definition of done (accessibility):** the component/screen checklist in [component library](../component-library/README.md) §G and [form design system](../screen-library/form-design-system.md) §10 all pass; no automated violations; manual SR walkthrough completes the primary task without confusion.

---

## 12. Quick reference card

```
Contrast:      text 4.5:1 · large/UI 3:1 · focus ring 3:1
Targets:       44×44 dp min · 8 dp apart
Text scale:    works to 200%
Every control: role + name + state + value
Never:         color-only meaning · keyboard traps · blocked paste · motion-only cues
Always:        visible focus · labelled icons · announced errors · reduced-motion path
Test with:     TalkBack + VoiceOver + 200% + Reduce Motion + keyboard, every release
```
