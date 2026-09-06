# Component Library · Engineering API Reference

> Part of the [Component Library](README.md). Companion to [design-specs.md](design-specs.md) (anatomy, sizes, redlines).
> The **engineering contract**: per component — Purpose · Variants · Properties · States · Accessibility · Animation · Usage Rules · Do · Don't · Jetpack Compose · Flutter · React Native (· SwiftUI notes in design-specs.md).
> Prefix for all wrappers: `Amds*`. Tokens from [`../../design-tokens/`](../../design-tokens/). Motion from [motion](../design-system/motion.md).

---

## 0. Conventions

### 0.1 Token references

Code below uses semantic token names, resolved per platform:

| Reference | Compose | Flutter | React Native |
|---|---|---|---|
| color | `AmdsTheme.colors.primary` | `context.amds.colors.primary` | `theme.colors.primary` |
| spacing | `AmdsSpacing.md` (16.dp) | `AmdsSpacing.md` | `theme.spacing[4]` |
| radius | `AmdsRadius.md` (12) | `AmdsRadius.md` | `theme.radius.md` |
| type | `MaterialTheme.typography.labelLarge` | `context.text.labelLarge` | `theme.typography.label` |
| motion | `AmdsMotion.BASE` / `AmdsMotion.StandardEasing` | `t.durBase` / `AmdsTokens.easeStandard` | `theme.motion.duration.base` |

### 0.2 Universal property set

Every interactive `Amds*` component accepts (names adapt to platform idiom):

| Prop | Type | Notes |
|---|---|---|
| `variant` | enum | visual emphasis / role |
| `size` | `sm` `md` `lg` | `md` default |
| `enabled` / `disabled` | bool | disabled = 38% opacity, not focusable, no pointer events |
| `loading` | bool | spinner replaces leading content; `aria-busy`; non-interactive |
| `onPress` / `onClick` | callback | up-event; cancel on drag-off |
| `leadingIcon` / `trailingIcon` | icon | 18–24 per size |
| `semanticLabel` / `contentDescription` | string | required where no visible text |
| `testId` / `testTag` | string | automation hook |
| `modifier` / `style` / `sx` | platform | layout overrides only, never token overrides |

### 0.3 Universal states

`enabled` · `hover` (pointer only — 8% `onSurface` overlay) · `focus-visible` (2px `borderFocus` ring, 2px offset) · `pressed` (12% overlay or 0.96 scale, 100ms) · `disabled` (38%) · `loading` · plus component states (`selected`, `error`, `expanded`, `checked`, `indeterminate`).

### 0.4 Universal accessibility baseline

Role exposed · accessible name from visible label or explicit prop · state announced (`selected`/`disabled`/`expanded`/`checked`/`busy`) · ≥44×44dp target · operable by keyboard / switch / D-pad / SR gestures · visible focus · honors reduced-motion + Dynamic Type (200%) · RTL-mirrored.

### 0.5 Platform primitive base

| AMDS | Compose base | Flutter base | RN base |
|---|---|---|---|
| theming | `MaterialTheme` (M3) + CompositionLocals | `Theme` + `ThemeExtension` | Context + `amdsLight/Dark` |
| lists | `LazyColumn` / Paging 3 | `ListView`/`Sliver` + `infinite_scroll_pagination` | `FlashList` / `FlatList` |
| overlays | `Dialog` / `ModalBottomSheet` | `showDialog` / `showModalBottomSheet` | `Modal` / `@gorhom/bottom-sheet` |
| motion | `animate*AsState`, `AnimatedContent`, `updateTransition` | implicit `Animated*`, `AnimatedSwitcher`, `flutter_animate` | `react-native-reanimated` 3 |
| icons | `Icon` + Material Symbols | `Icon` + `material_symbols_icons` | `react-native-vector-icons` |

---

## 1. Buttons

**Purpose** — trigger an operation. One **primary** button per screen/section maximum.

**Variants** — `primary` (filled `primary`) · `secondary` (outlined, `primary` label) · `tertiary`/`text` (label only) · `tonal` (`primaryContainer`) · `destructive` (filled `danger`) · `destructiveText`. Sizes `sm` 36 / `md` 44 / `lg` 52. `fullWidth` boolean.

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `label` | string | — | verb-first; required (icon-only → use IconButton) |
| `variant` | enum | `primary` | |
| `size` | `sm`\|`md`\|`lg` | `md` | |
| `leadingIcon` / `trailingIcon` | icon? | — | 16/20/24 per size |
| `fullWidth` | bool | false | pins to bottom + safe area when used as screen CTA |
| `loading` | bool | false | spinner replaces `leadingIcon`; label stays or → "Saving…" |
| `enabled` | bool | true | |
| `onPress` | () → void | — | |

**States** — universal + `pressed` (0.96 scale + darken to `primaryPressed`, 100ms `standard`) · `loading` (spinner, `aria-busy`, non-interactive) · `disabled` (38%, focusable=false).

**Accessibility** — role `button`; name = `label`; disabled announced + not focusable; loading announces "busy"; hit area ≥44 even for `sm` (pad vertically); destructive confirm dialogs default-focus the safe choice.

**Animation** — press: scale 1→0.96 (`instant` 100ms) + bg → pressed color; release: `spring` back 150ms. Loading: label↔spinner crossfade 150ms, width holds. Reduced-motion: color change only, no scale.

**Usage Rules** — verb labels ("Add asset"). ≤2 buttons in a row on phone; 3rd → overflow. Never silently disable the primary — show why. Not for navigation between screens where a row/link fits.

**Do** — pair one `primary` with one `secondary`/`text`. Keep the primary action in the same place across similar screens. Use `destructive` + a confirm for delete/reject.

**Don't** — two `primary` buttons on one screen. Icon-only Button (use IconButton). Disable without explanation. Use color alone to signal destructive (label + `danger` fill together).

**Jetpack Compose**
```kotlin
@Composable fun AmdsButton(
  label: String, onClick: () -> Unit, modifier: Modifier = Modifier,
  variant: AmdsButtonVariant = AmdsButtonVariant.Primary,
  size: AmdsSize = AmdsSize.Md, enabled: Boolean = true, loading: Boolean = false,
  leadingIcon: ImageVector? = null, trailingIcon: ImageVector? = null, fullWidth: Boolean = false,
)
// impl: Button / OutlinedButton / TextButton / FilledTonalButton by variant;
// min height per size; CircularProgressIndicator(strokeWidth 2.dp) swaps leadingIcon when loading;
// Modifier.graphicsLayer { scaleX = scaleY = pressScale } via interactionSource.
```

**Flutter**
```dart
AmdsButton(
  label: 'Add asset', onPressed: _add,
  variant: AmdsButtonVariant.primary, size: AmdsSize.md,
  loading: state.isSaving, leadingIcon: Icons.add, fullWidth: false,
)
// impl: FilledButton / OutlinedButton / TextButton / FilledButton.tonal;
// AnimatedScale(scale: pressed ? 0.96 : 1, duration: 100ms);
// child = loading ? SizedBox(16, CircularProgressIndicator(strokeWidth: 2)) : Row(icon,label).
```

**React Native**
```tsx
<AmdsButton label="Add asset" onPress={add}
  variant="primary" size="md" loading={isSaving} leadingIcon="add" fullWidth={false} />
// impl: Pressable + Reanimated useSharedValue(scale) → withTiming(0.96) onPressIn;
// bg/txt from theme by variant; ActivityIndicator swaps leading icon when loading;
// accessibilityRole="button", accessibilityState={{disabled, busy: loading}}.
```

---

## 2. Cards

**Purpose** — group content + actions about one subject into a surface; static or tappable.

**Variants** — `elevated` (`elevation1`, no border) · `outlined` (**default**, 1px `border`, flat) · `filled` (`surfaceVariant`) · `interactive` (whole card = one target, adds hover/press + trailing chevron). Specialized: `KpiCard`, `ChartCard`, `ProfileCard` (see §16–17).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `variant` | enum | `outlined` | |
| `onPress` | (() → void)? | — | presence makes it `interactive` |
| `padding` | space token | `md` (16) | |
| `media` | slot? | — | top, full-bleed, inherits top radius |
| `header` / `body` / `footer` | slot | — | |
| `semanticLabel` | string? | — | required when `interactive` (summarizes content) |

**States** — static: none. Interactive: `hover` (`elevation2`) · `focus` (ring) · `pressed` (0.98 scale + `surfaceVariant` overlay) · `loading` (skeleton) · `disabled`.

**Accessibility** — an interactive card is **one** `button`/`link` with a name summarizing its content; **no nested interactive children** — if multiple actions are needed, make the card static and expose actions separately or via a labelled menu.

**Animation** — interactive press: 0.98 scale + overlay, `instant`. Hover: `elevation1→2` + translateY −2, `fast`. List entrance: fade + riseY 8→0, `decelerate` 200ms, stagger 30ms (≤8). Reduced-motion: opacity only.

**Usage Rules** — one subject per card. Don't nest cards. ≤3 content rows on phone (link to detail for more). Consistent height/padding/elevation across a set.

**Do** — use `outlined` by default; reserve elevation for raised/overlay contexts. Keep corner radius consistent within a view (`lg` 16).

**Don't** — nest cards. Put multiple tap targets inside an `interactive` card. Mix `md` and `lg` radius cards side by side.

**Compose**
```kotlin
@Composable fun AmdsCard(
  modifier: Modifier = Modifier, variant: AmdsCardVariant = Outlined,
  onClick: (() -> Unit)? = null, semanticLabel: String? = null, content: @Composable ColumnScope.() -> Unit,
)
// Card / OutlinedCard / ElevatedCard; if onClick != null → Modifier.clickable + semantics { role = Role.Button; contentDescription = semanticLabel }.
```

**Flutter**
```dart
AmdsCard(variant: AmdsCardVariant.outlined, onTap: () => open(id),
  semanticLabel: 'Compressor A-12, Active, updated 2 hours ago',
  child: Column(children: [ Header(), Body() ]))
// Material(shape: RoundedRectangleBorder(AmdsRadius.lg, side: BorderSide(border)));
// InkWell when onTap != null; Semantics(button: true, label: semanticLabel).
```

**React Native**
```tsx
<AmdsCard variant="outlined" onPress={() => open(id)}
  accessibilityLabel="Compressor A-12, Active, updated 2 hours ago">
  {children}
</AmdsCard>
// View with borderRadius/borderWidth/borderColor from theme; Pressable wrapper when onPress;
// accessibilityRole="button".
```

---

## 3. Inputs (Text Field · Password Field · number/currency/textarea)

**Purpose** — single- or multi-line data entry.

**Variants** — `outlined` (**default**) · `filled` · `textarea` (auto-grow to 5 lines) · `readonly`. Affix slots: leading/trailing icon, prefix/suffix text. Specializations: `AmdsPasswordField` (reveal toggle + optional strength meter), number/currency (keypad + unit).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` / `onChange` | string / (s)→void | — | controlled |
| `label` | string | — | **always visible**, above the field |
| `helper` | string? | — | shown until an error replaces it |
| `error` | string? | — | replaces helper; sets error state |
| `placeholder` | string? | — | not a label substitute |
| `keyboardType` / `inputmode` | enum | text | email/number/tel/url/decimal |
| `autofillHint` | enum? | — | username, password, oneTimeCode, … |
| `maxLength` | int? | — | show counter when set |
| `leadingIcon` / `trailing` | slot? | — | trailing may be a clear/action button (own 44dp) |
| `enabled` / `readOnly` | bool | true / false | |
| `obscure` | bool | false | password field |
| `multiline` / `minLines` / `maxLines` | — | — | textarea |

**States** — `enabled` · `focus` (2px `borderFocus`, label → `primary`) · `filled` (blurred, `borderStrong`) · `error` (2px `danger`, label + helper `danger` + ⚠) · `disabled` (38%) · `loading` (async validate: helper spinner + "Checking…").

**Accessibility** — visible `<label>` programmatically associated; placeholder ≠ label; error linked via `aria-describedby` / `accessibilityHint`, announced on blur/submit (`live=polite`); `inputmode`/`keyboardType` set; required in the label text ("Email (required)"); ≥44dp height; supports selection/paste/autofill/password managers; never block paste.

**Animation** — focus: border color crossfade 150ms; label float (filled variant) 150ms `standard`. Error: message slide-down + fade 150ms `decelerate`; border crossfade to `danger`. Reduced-motion: no float, color change only.

**Usage Rules** — label always visible (no float-only that disappears). One idea per field. Format hints in `helper` **before** the error. Validate on blur (not per keystroke) except strength/availability/counter/mask. Preserve input on error.

**Do** — set `keyboardType` + `autofillHint` for every field. Show a clear (`×`) trailing action when there's text. Group related fields (`space.5` apart).

**Don't** — use the placeholder as the label. Validate on every keystroke. Impose a `maxLength` below 64 on passwords. Clear the field on error.

**Compose**
```kotlin
@Composable fun AmdsTextField(
  value: String, onValueChange: (String) -> Unit, label: String,
  modifier: Modifier = Modifier, helper: String? = null, error: String? = null,
  leadingIcon: ImageVector? = null, trailing: @Composable (() -> Unit)? = null,
  keyboardOptions: KeyboardOptions = KeyboardOptions.Default, visualTransformation: VisualTransformation = None,
  enabled: Boolean = true, readOnly: Boolean = false, singleLine: Boolean = true,
)
// OutlinedTextField(isError = error != null, supportingText = { Text(error ?: helper ?: "") },
//   colors = amdsFieldColors(), shape = RoundedCornerShape(AmdsRadius.sm));
// AmdsPasswordField: visualTransformation toggled by a reveal IconToggleButton (stateDescription).
```

**Flutter**
```dart
AmdsTextField(
  controller: c, label: 'Email (required)', helper: 'We\'ll send a verification link',
  error: state.emailError, keyboardType: TextInputType.emailAddress,
  autofillHints: const [AutofillHints.username], prefixIcon: Icons.mail_outlined,
)
// TextFormField(decoration: InputDecoration from AmdsTheme.inputDecorationTheme,
//   errorText: error, ...); AmdsPasswordField wraps with obscureText + IconButton reveal;
// wrap the form in AutofillGroup.
```

**React Native**
```tsx
<AmdsTextField value={email} onChangeText={setEmail} label="Email (required)"
  helper="We'll send a verification link" error={emailError}
  keyboardType="email-address" autoComplete="username" textContentType="username"
  leadingIcon="mail" />
// View(label Text) + TextInput (styled by theme, red border when error) + helper/error Text
// with accessibilityLiveRegion="polite"; AmdsPasswordField adds secureTextEntry + reveal Pressable.
```

---

## 4. Search

**Purpose** — filter or find within a dataset or globally.

**Variants** — `persistent` (in app bar) · `collapsible` (icon expands to full-width) · `dockedWithSuggestions` (results/recents dropdown or full-screen search view) · `scoped` (leading segmented scope chips).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `query` / `onQueryChange` | string / (s)→void | — | |
| `onSubmit` | (s)→void | — | |
| `placeholder` | string | "Search" | scope it ("Search assets…") |
| `debounceMs` | int | 275 | 250–300 |
| `loading` | bool | false | trailing spinner |
| `suggestions` | list? | — | recents before typing, results while typing |
| `resultCount` | int? | — | announced via live region |
| `onClear` | ()→void | — | trailing `×` when non-empty |
| `scopes` | list? | — | segmented scope chips |

**States** — `empty` (placeholder) · `typing` (debounced) · `loading` (trailing spinner) · `results` / `noResults` (echo query + "Clear filters") · `recents` (on focus, pre-typing).

**Accessibility** — role `searchbox`; label "Search"; clear button labelled; result count announced (`live=polite`, "12 results"); suggestions navigable by arrows; Esc clears/closes; full-screen search view traps focus + returns it on dismiss.

**Animation** — collapsible: icon → full-width 200ms `standard`. Suggestions dropdown: fade + 4dp riseY 150ms. Clear: `×` fades in/out 100ms. Reduced-motion: instant.

**Usage Rules** — search the thing on screen (scope to current list). Preserve the query when navigating to a result and back. Explain zero results (spelling, active filters) + offer "Clear filters". Don't navigate on the first keystroke.

**Do** — debounce 250–300ms. Show recent searches on focus. Combine with filters (AND); show the query as a removable chip.

**Don't** — auto-submit navigation while typing. Lose the query on back. Use a global search when the user is clearly scoped to one list.

**Compose**
```kotlin
@Composable fun AmdsSearchField(
  query: String, onQueryChange: (String) -> Unit, onSearch: (String) -> Unit,
  modifier: Modifier = Modifier, placeholder: String = "Search",
  active: Boolean = false, onActiveChange: (Boolean) -> Unit = {}, content: @Composable ColumnScope.() -> Unit = {},
)
// M3 SearchBar / DockedSearchBar; leading Icon(Search); trailing Icon(Close) when query.isNotEmpty();
// debounce in the ViewModel via a StateFlow.debounce(275).
```

**Flutter**
```dart
AmdsSearchField(
  controller: c, hintText: 'Search assets…', onChanged: _debounced, onSubmitted: _run,
  loading: state.searching, resultCount: state.count,
)
// SearchBar / SearchAnchor (Material 3); trailing: [ if (loading) Spinner else if (text.isNotEmpty) IconButton(Icons.close) ];
// Semantics(liveRegion: true) on a hidden "{count} results" text.
```

**React Native**
```tsx
<AmdsSearchField value={q} onChangeText={onChange} onSubmitEditing={run}
  placeholder="Search assets…" loading={searching} resultCount={count} onClear={clear} />
// View(row) + Icon(search) + TextInput(returnKeyType="search") + (loading ? ActivityIndicator : q ? Pressable(×) : null);
// AccessibilityInfo.announceForAccessibility(`${count} results`) throttled.
```

---

## 5. Dropdowns / Select

**Purpose** — choose value(s) from a known list. <5 options → Radio/Segmented; >25 → autocomplete.

**Variants** — `single` · `multi` (checkbox rows; trigger shows count/chips) · `searchable` (filter input in menu) · `grouped` (section headers). Presentation: **bottom sheet** on phone when >6 options or long labels; anchored popover on pointer/tablet.

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` / `onChange` | T / (T)→void | — | single |
| `values` / `onChange` | T[] / (T[])→void | — | multi |
| `options` | `{value,label,icon?,disabled?}[]` | — | |
| `optionsLoader` | async? | — | remote options; skeleton rows |
| `label` / `placeholder` | string | — | trigger shows current value once chosen |
| `searchable` | bool | auto (>12) | |
| `clearable` | bool | false | only when "no value" is valid |
| `error` | string? | — | |

**States** — `closed` (Text-Field states) · `open` (`aria-expanded`, trigger border `borderFocus`) · option `hover`/`focus`/`selected`/`disabled` · `empty` ("No matches") · `loading` (skeleton rows).

**Accessibility** — role `combobox` + `listbox`; `aria-activedescendant` tracks highlight; selected announced; trigger's accessible name includes current value ("Priority, High"); multi announces count; type-ahead; Esc closes + focus returns to trigger.

**Animation** — menu open: fade + scale 0.96→1 (popover) or sheet slide-up 250ms. Option select: `primaryContainer` tint crossfade + `check` draw 150ms. Reduced-motion: fade only.

**Usage Rules** — always show the current value in the trigger. Sort options (frequency then alpha). Provide a clear/none option only when "no value" is valid. Don't nest dropdowns in dropdowns.

**Do** — use a bottom sheet on phones for long lists. Add a search field above ~12 options. Show icons/meta in option rows when they aid choice.

**Don't** — leave the trigger showing only the placeholder after a value is chosen. Use a dropdown for 2–3 mutually exclusive options (use Segmented). Auto-open on mount.

**Compose**
```kotlin
@Composable fun <T> AmdsDropdown(
  value: T?, onValueChange: (T) -> Unit, options: List<AmdsOption<T>>, label: String,
  modifier: Modifier = Modifier, searchable: Boolean = options.size > 12, error: String? = null,
)
// ExposedDropdownMenuBox + OutlinedTextField(readOnly, trailingIcon = ExposedDropdownMenuDefaults.TrailingIcon);
// phone + long list → ModalBottomSheet with a LazyColumn of ListItem(trailing = if selected Icon(Check));
// semantics { role = Role.DropdownList; stateDescription = value?.label ?: "" }.
```

**Flutter**
```dart
AmdsDropdown<Priority>(
  value: state.priority, label: 'Priority',
  options: Priority.values.map((p) => AmdsOption(p, p.label)).toList(),
  onChanged: controller.setPriority, error: state.priorityError,
)
// DropdownMenu (M3) for short lists; for long/phone → showModalBottomSheet with ListView + RadioListTile/CheckboxListTile;
// trigger = InputDecorator styled like AmdsTextField.
```

**React Native**
```tsx
<AmdsDropdown value={priority} onChange={setPriority} label="Priority"
  options={priorityOptions} searchable={false} error={priorityError} />
// Pressable trigger (looks like AmdsTextField) → @gorhom/bottom-sheet with FlashList of option rows;
// selected row: check icon + primaryContainer bg; accessibilityRole="combobox", accessibilityState={{expanded}}.
```

---

## 6. Bottom Sheets

**Purpose** — contextual actions or supplementary content anchored to the current screen without full interruption.

**Variants** — `modal` (scrim, dismissible — action menus, pickers) · `persistent` (no scrim, coexists with content) · `expandable` (drag between `peek`/`half`/`full` detents).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `visible` / `onDismiss` | bool / ()→void | — | |
| `detents` | `[peek,half,full]` | `[half]` | expandable |
| `initialDetent` | enum | first | |
| `scrim` | bool | true (modal) | |
| `dragHandle` | bool | true | 32×4, `borderStrong` |
| `title` | string? | — | |
| `dismissOnScrimTap` | bool | true | false for destructive-only flows |

**States** — `peek`/`half`/`expanded` · `dragging` (follows finger, rubber-band past limits) · `settling` (250ms `standard` to nearest detent) · `dismissing` (slide down 200ms `accelerate` + scrim fade) · over-content scroll hand-off (sheet expands first, then inner content scrolls).

**Accessibility** — modal sheet = `dialog` + focus trap + scrim tap / back / swipe-down to dismiss, focus returns; drag handle exposes an accessible "Dismiss" action; expand/collapse exposed as buttons for non-drag users; announce sheet open + purpose.

**Animation** — present: slide-up to initial detent 250ms `standard` + scrim fade 150ms. Drag: 1:1, rubber-band `translation*0.35` past max. Release: `spring` (damping 0.85) to nearest detent. Reduced-motion: fade + minimal slide 150ms, snap without spring.

**Usage Rules** — prefer over a dropdown menu on phones for 3+ actions or long labels. Action sheets ≤6 items + Cancel. Don't put a primary destructive action first. Persistent sheets must not hide critical content at peek.

**Do** — include a drag handle. Provide non-drag expand/collapse. Use for filter panels, pickers, share/action menus, quick detail peeks.

**Don't** — nest a bottom sheet inside a bottom sheet. Use for a multi-field form (use a full-screen Modal). Auto-expand to full on open without reason.

**Compose**
```kotlin
val state = rememberModalBottomSheetState(skipPartiallyExpanded = false)
ModalBottomSheet(onDismissRequest = onDismiss, sheetState = state,
  dragHandle = { BottomSheetDefaults.DragHandle() },
  shape = RoundedCornerShape(topStart = AmdsRadius.xl, topEnd = AmdsRadius.xl)) { content() }
// AmdsBottomSheet wraps this; for detents use SheetValue + custom anchoredDraggable if >2.
```

**Flutter**
```dart
showModalBottomSheet(
  context: context, isScrollControlled: true, showDragHandle: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (_) => AmdsBottomSheetContent(...),
);
// expandable → DraggableScrollableSheet(initialChildSize, minChildSize, maxChildSize, snap: true, snapSizes: [...]).
```

**React Native**
```tsx
<AmdsBottomSheet ref={sheetRef} snapPoints={['25%','50%','90%']} index={1} enablePanDownToClose
  onClose={onDismiss}>
  <BottomSheetView>{content}</BottomSheetView>
</AmdsBottomSheet>
// @gorhom/bottom-sheet; handleComponent = <AmdsDragHandle/>; backdropComponent = <AmdsBackdrop/> (modal);
// accessibilityViewIsModal, focus trap via the library.
```

---

## 7. Dialogs

**Purpose** — interrupt for a decision or critical info that blocks progress.

**Variants** — `confirm` · `destructive` (Confirm = `danger`, default focus = Cancel) · `acknowledge` (single "OK") · `input` (one field — prefer a screen for more).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `visible` / `onDismiss` | bool / ()→void | — | |
| `title` | string | — | states the outcome/question |
| `body` | string / slot | — | consequence + reversibility |
| `confirmLabel` / `onConfirm` | string / ()→void | — | verb matching the title |
| `cancelLabel` | string | "Cancel" | |
| `danger` | bool | false | destructive |
| `requireTypedConfirm` | string? | — | must type this to enable Confirm |
| `loading` | bool | false | Confirm spinner, actions disabled |

**States** — enter (scrim fade 150ms → container fade + scale 0.95→1, 200ms `decelerate`, 50ms offset) · `loading` · error (keep open, inline error + Retry) · exit (reverse, `accelerate` 150ms).

**Accessibility** — role `alertdialog`; focus moves in (title or safe action); **trapped**; Esc / back = Cancel; scrim tap = Cancel (non-destructive only); focus returns to trigger on close; content announced; destructive default focus = Cancel; never stack dialogs.

**Animation** — as States. Confirm loading: label→spinner. Reduced-motion: fade + 8dp translate only, 150ms.

**Usage Rules** — sparingly; never for non-blocking info (use Snackbar/Banner). Title = the question/outcome. Buttons = verbs ("Delete"/"Keep"), never "Yes"/"No". Max 2 actions (3 only with a clear tertiary).

**Do** — spell out consequences + reversibility in the body. Use `requireTypedConfirm` for high-value deletes. Default-focus Cancel for destructive.

**Don't** — "Are you sure?" with Yes/No. Stack dialogs. Use a dialog where an inline error or a Snackbar+Undo is enough.

**Compose**
```kotlin
AlertDialog(
  onDismissRequest = onDismiss,
  icon = if (danger) { { Icon(Icons.Rounded.Warning, null, tint = AmdsTheme.colors.danger) } } else null,
  title = { Text(title) }, text = { Text(body) },
  confirmButton = { AmdsButton(confirmLabel, onConfirm, variant = if (danger) Destructive else Primary, loading = loading) },
  dismissButton = { AmdsButton(cancelLabel, onDismiss, variant = Text) },
)
// LaunchedEffect(Unit) { focusRequester.requestFocus() } on the safe action for destructive.
```

**Flutter**
```dart
showDialog(context: context, barrierDismissible: !danger, builder: (_) => AmdsDialog(
  title: 'Delete work order WO-1043?',
  body: "This can't be undone. 3 linked tasks will be unassigned.",
  confirmLabel: 'Delete', danger: true, requireTypedConfirm: null, onConfirm: _delete,
));
// AlertDialog(shape: RoundedRectangleBorder(AmdsRadius.lg), actionsAlignment: MainAxisAlignment.end);
// PopScope(onPopInvoked → treat as cancel); autofocus the Cancel button.
```

**React Native**
```tsx
<AmdsDialog visible={open} onDismiss={close}
  title="Delete work order WO-1043?"
  body="This can't be undone. 3 linked tasks will be unassigned."
  confirmLabel="Delete" danger onConfirm={remove} loading={deleting} />
// <Modal transparent animationType="fade">: scrim Pressable(onPress=close if !danger) + centered card;
// AccessibilityInfo.setAccessibilityFocus on Cancel; BackHandler → close; accessibilityViewIsModal.
```

---

## 8. Modals (full-screen / sheet flows)

**Purpose** — a focused sub-task or multi-step flow needing the whole screen (create record, wizard, media viewer).

**Variants** — `fullScreen` (phone) · `centeredDialog` (tablet, max 720, radius `xl`) · `wizard` (with Stepper) · `mediaViewer`.

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `visible` / `onClose` | bool / ()→void | — | |
| `title` | string | — | |
| `primaryAction` | `{label,onPress,loading,enabled}` | — | trailing in the top bar ("Save") |
| `dirty` | bool | false | triggers discard guard on close |
| `stickyFooter` | slot? | — | long forms |

**States** — enter (slide-up from +100% h, `decelerate` 300ms + scrim 150ms; tablet: scale 0.92→1 200ms) · `submitting` (footer/appbar button spinner, inputs locked) · dirty-close (→ discard Dialog) · exit (slide-down `accelerate` 200ms).

**Accessibility** — role `dialog`; focus trap; Esc / back = close (with dirty guard); the close control (`X`) is first focusable + clearly labelled; title announced; focus returns on close.

**Animation** — as States. Wizard step advance: content shared-axis X 250ms; step indicator fills. Reduced-motion: fade + 8dp translate, 150ms.

**Usage Rules** — use instead of a Dialog when there's a form or >1 decision. Leading `X` = close/cancel; trailing action = commit — never swap. Provide a way out at every step.

**Do** — dirty-check on dismiss. Use a Stepper + Review step for wizards. On tablet, consider an inline two-pane instead of a modal flow.

**Don't** — trap the user with no visible close. Put the commit action in the leading slot. Use a full-screen modal for a one-line confirmation.

**Compose**
```kotlin
// A dedicated composable route (not a Dialog) for full-screen:
Scaffold(topBar = { TopAppBar(
  navigationIcon = { IconButton(onGuardClose) { Icon(Icons.Rounded.Close, "Close") } },
  title = { Text(title) },
  actions = { AmdsButton("Save", onSave, size = Sm, loading = submitting, enabled = valid) }) }) { ... }
// tablet: wrap in Dialog(properties = DialogProperties(usePlatformDefaultWidth = false)) sized to 720.
```

**Flutter**
```dart
Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => AmdsModalScreen(
  title: 'New incident', primary: AmdsAction('Submit', _submit, loading: submitting, enabled: valid),
  onClose: _guardClose, body: FormEngine(schema),
)));
// PopScope(canPop: !dirty, onPopInvoked: _confirmDiscard); tablet → showDialog with a 720-wide Dialog.
```

**React Native**
```tsx
// A stack screen with presentation:'modal' (or 'fullScreenModal'):
<Stack.Screen name="NewIncident" component={NewIncidentScreen}
  options={{ presentation: 'modal', headerLeft: () => <CloseButton onPress={guardClose}/>,
             headerRight: () => <AmdsButton label="Submit" size="sm" loading={submitting} onPress={submit}/> }} />
// usePreventRemove for the dirty guard; tablet → render as a centered <Modal> with maxWidth 720.
```

---

## 9. Tables

**Purpose** — compare values across rows; used where a spreadsheet workflow or many quantitative columns matter. Default on phones = the **row-transformation** (each row → a List item); a true horizontally-scrolling grid is a deliberate tablet/power choice.

**Variants** — `rows` (phone: card/list transformation) · `grid` (true table, sticky header, frozen first column) · densities `comfortable` 52 / `compact` 40 / `multiline` 64+.

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `columns` | `Column[] {key,label,width,align,sortable,numeric,frozen?}` | — | |
| `rows` | `Row[]` | — | |
| `keyColumns` | string[] | — | which columns show in the phone row-transformation |
| `sort` | `{key,dir}?` | config default | one active on mobile |
| `onSort` | (key)→void | — | server-side |
| `selectable` | bool | false | 44dp checkbox column, frozen |
| `selectedIds` / `onSelectionChange` | — | — | |
| `pagination` | `infinite`\|`loadMore`\|`paged` | `infinite` | |
| `rowActions` | (row)→Action[] | — | trailing `⋮` / swipe |
| `onRowPress` | (row)→void | — | → detail / right pane |
| `density` | enum | `comfortable` | user setting |
| `loading` / `empty` / `error` | state | — | |

**States** — `loading` (skeleton header + 6–8 rows at real height) · `loadingMore` (footer spinner) · `refreshing` (pull spinner) · `empty` (no data / no results — distinct) · `error` (keep loaded rows + Retry) · `offline` (cached + "as of HH:MM") · row: `hover`/`pressed`/`selected` (`primaryContainer` + 2px `primary` left bar)/`disabled`.

**Accessibility** — grid = `table`/`grid` with `columnheader` + `rowheader` (identifier cell) + indices; row-transformation cards = one `button` whose name summarizes key fields; sort state / filter count / pagination position announced (`live=polite`); checkbox labelled with the row identifier; frozen columns must not obscure focus; horizontal scroll must not trap focus; works at 200% (wrap or grow row height).

**Animation** — rows stagger on first paint (30ms, ≤8). Re-sort: rows crossfade, scroll to top. Row remove: collapse + fade + slide, 200ms `accelerate`. Selection mode: checkboxes fade in 150ms. Reduced-motion: fade only.

**Usage Rules** — table vs list: use a table only when users compare across rows. Server-side sort/filter/paginate; keyset over offset. Page 25 phone / 50 tablet. Preserve position on back. Don't lose selection silently across pages.

**Do** — freeze the identifier column in `grid`. Right-align numerics + tabular figures. Offer a "Table view" toggle for comparison-heavy lists on tablet. Match the loading skeleton to real row height.

**Don't** — force a wide grid on a phone. Zebra-stripe by default (only very wide tables, 50% `surfaceVariant`). Put critical actions only behind swipe (also in overflow).

**Compose**
```kotlin
@Composable fun AmdsTable(columns: List<AmdsColumn>, rows: List<AmdsRow>, ...)
// phone: LazyColumn { items(rows) { AmdsListTileX(title = row[keyColumns[0]], subtitle = keyMeta(row), trailing = row.primaryValue, onClick = { onRowPress(row) }) } }
// grid: Row(Modifier.horizontalScroll(state)) { Column(frozen) ; Column(scrollable header+cells) } + LazyColumn body;
// header Row sticky via stickyHeader; sort caret Icon; semantics collectionInfo / collectionItemInfo.
```

**Flutter**
```dart
AmdsDataTable(columns: cols, rows: rows, keyColumns: ['name','status','updated','amount'],
  density: settings.density, sort: state.sort, onSort: controller.sort,
  selectable: true, selectedIds: state.selected, onRowTap: (r) => open(r.id),
  pagination: AmdsPagination.infinite)
// phone: PagedListView<int, Row>(builderDelegate: ... AmdsListTileX ...);
// grid: SingleChildScrollView(scrollDirection: horizontal) → DataTable2 (data_table_2 pkg) with fixedLeftColumns: 1, fixedTopRows: 1;
// Semantics for headers; ExcludeSemantics on decorative gridlines.
```

**React Native**
```tsx
<AmdsTable columns={cols} rows={rows} keyColumns={['name','status','updated','amount']}
  density={density} sort={sort} onSort={sort} selectable selectedIds={selected}
  onRowPress={open} pagination="infinite" />
// phone: <FlashList data={rows} renderItem={AmdsRowCard} onEndReached={loadMore} />
// grid: horizontal <ScrollView> wrapping a frozen <View> + a scrollable <FlashList>; sticky header View;
// accessibilityRole="none" on grid container, each row card accessibilityRole="button".
```

---

## 10. Charts

**Purpose** — house one visualization with title, legend, controls; answer one question.

**Variants** — `line`/`area` (trend) · `bar` (compare) · `stackedBar`/`donut ≤4` (composition) · `sparkline` (inline, no axes) · `bullet`/`progress` (goal). Always wrapped in a **ChartCard** with a header + "View as table".

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `type` | enum | — | |
| `series` | `Series[] {id,label,points,color?}` | — | ≤5; color from categorical palette (dashboard-system §6) |
| `xAxis` / `yAxis` | axis config | — | y starts at 0 for bars; note truncation |
| `range` | enum | 30d | segmented "7d·30d·90d" in the card header |
| `legend` | bool / `toggleable` | true | tap chip to toggle series |
| `tooltip` | `tapHold` | on | shows all series at x |
| `viewAsTable` | bool | **true** | mandatory a11y path |
| `loading`/`empty`/`error` | state | — | |
| `summary` | string | — | one-sentence takeaway → chart's accessible label |

**States** — `loading` (chart-area shimmer, header real) · `empty` ("Not enough data to chart yet" + keep range selector) · `error` ("Couldn't load chart" + Retry; "View as table" still offered) · `interactive` (crosshair on tap-hold) · `updated` (only changed values crossfade on refresh).

**Accessibility** — chart container labelled with `summary`; **"View as table" toggle mandatory** → real `table` with headers; no meaning by color alone (direct labels / markers / patterns; adjacent series differ in lightness); respect reduced-motion (no draw-in / instant); announce updated values politely + throttled; tap-hold tooltip content also reachable via the table.

**Animation** — first render / range change: line draws L→R 300ms `decelerate`; bars grow from baseline 250ms staggered. Legend toggle: series fade + y-axis rescale 200ms. Tooltip: fade in at x 100ms, follows drag. Refresh: changed values crossfade only. Reduced-motion: no draw-in, instant.

**Usage Rules** — one chart per card. Pick the type for the question. ≤5 series. Honest axes. Localize number/date formats. Downsample dense series (LTTB, ≤120 pts). Build data off the main thread.

**Do** — provide the table alternative always. Label series directly on mobile where space allows. Use the token-derived categorical palette. Cache the last result for instant back-nav.

**Don't** — 3D, heavy drop shadows, gratuitous gradients. Hover-only information. Truncated bar-chart y-axis without a note. More than 5 series. Pie for close values.

**Compose**
```kotlin
AmdsChartCard(title = "Incidents: opened vs closed", range = range, onRangeChange = vm::setRange,
  summary = "42 opened, 38 closed over the last 7 days",
  chart = { AmdsLineChart(series = state.series, reducedMotion = LocalAccessibility.reduceMotion) },
  onViewAsTable = { showTableSheet() })
// AmdsLineChart: Vico (com.patrykandpatrick.vico) LineChart / or Canvas; animateFloatAsState for the draw progress;
// tooltip via pointerInput { detectTapGestures(onPress = { awaitRelease() }) }.
```

**Flutter**
```dart
AmdsChartCard(
  title: 'Incidents: opened vs closed', range: state.range, onRangeChange: c.setRange,
  summary: '42 opened, 38 closed over the last 7 days',
  chart: AmdsLineChart(series: state.series),
  onViewAsTable: () => showModalBottomSheet(context: context, builder: (_) => ChartDataTable(state.series)),
)
// AmdsLineChart: fl_chart LineChart(LineChartData(...)); disable curve animation when MediaQuery.disableAnimations;
// prepare spots with compute().
```

**React Native**
```tsx
<AmdsChartCard title="Incidents: opened vs closed" range={range} onRangeChange={setRange}
  summary="42 opened, 38 closed over the last 7 days"
  chart={<AmdsLineChart series={series} />}
  onViewAsTable={() => openSheet(<ChartDataTable series={series} />)} />
// AmdsLineChart: victory-native (VictoryLine/VictoryArea) or react-native-svg; animate={!reduceMotion};
// series colors from theme categorical palette; VictoryVoronoiContainer for tap tooltips.
```

---

## 11. Navigation

**Purpose** — top-level switching + screen identity + hierarchy. Adaptive: **Bottom Navigation** (phone) → **Nav Rail** (tablet portrait) → **Persistent Drawer** (tablet landscape). Plus **Top App Bar**, **Tabs**, **Breadcrumb**.

**Variants** — `bottomBar` (3–5 destinations, labels always shown) · `rail` (icons + short labels) · `drawer` (`modal` / `permanent`) · `appBar` (`small` 56 / `centered` / `large` collapsing / `contextual` selection / `search`) · `tabs` (`fixed` 2–4 / `scrollable` 5+) · `breadcrumb` (tablet / hierarchical data only).

**Properties (adaptive nav)**

| Prop | Type | Notes |
|---|---|---|
| `destinations` | `{id,label,icon,selectedIcon,badge?}[]` | 3–5 |
| `selectedId` / `onSelect` | — | re-tap selected → scroll top → (2nd) pop to root |
| `layout` | auto by `WindowSizeClass` | bottomBar / rail / drawer |
| `header` (drawer) | slot | account switcher / workspace |

**States** — item: `selected` (`primary` + `primaryContainer` pill) / `unselected` (`onSurfaceVariant`) / `focus` / `pressed` / with `badge`. App bar: `resting` (flat) / `scrolledUnder` (`elevation2`). Tabs: `selected` (`primary` + 2px indicator) / indicator sliding.

**Accessibility** — bottom nav items expose selected state + position ("Tab 2 of 4, Assets, selected"); labels always visible (no icon-only); 48dp targets; modal drawer = `dialog` + focus trap + Esc; tabs = `tablist`/`tab`/`tabpanel` + arrow-key nav; back control labelled; app bar title = `heading` + screen name.

**Animation** — bottom nav selection: icon fill crossfade 150ms + pill scale-in 200ms `standard`. Drawer open: slide-in 250ms `decelerate` + scrim fade. App bar collapse: tied to scroll offset; elevation 150ms. Tab indicator: slide + width-morph 200ms `standard`. Reduced-motion: crossfades only.

**Usage Rules** — 3–5 primary destinations; more → "More" + drawer. Peers, not a stack (switching ≠ "back"). ≤2 icon actions + overflow in a phone app bar. Tabs never change what "back" means. Same nav set for the whole session.

**Do** — put the most-used destination first (Home/Dashboard leftmost). Elevate the app bar only on scroll-under. Persist the selected tab within a session.

**Don't** — put actions ("Add") in the bottom nav (that's the FAB). Hide the bottom nav on scroll by default (enterprise = predictable). Nest tabs more than one level.

**Compose**
```kotlin
NavigationSuiteScaffold(navigationSuiteItems = {
  destinations.forEach { d -> item(selected = d.id == selectedId, onClick = { onSelect(d.id) },
    icon = { BadgedIcon(d) }, label = { Text(d.label) }) }
}) { content() }
// picks NavigationBar / NavigationRail / PermanentNavigationDrawer by WindowSizeClass.
// App bar: TopAppBar / CenterAlignedTopAppBar / LargeTopAppBar + TopAppBarScrollBehavior.
// Tabs: PrimaryTabRow + HorizontalPager.
```

**Flutter**
```dart
AmdsAdaptiveNavigation(
  destinations: dests, selectedIndex: idx, onDestinationSelected: onSelect, body: child,
)
// LayoutBuilder: < 600 → Scaffold(bottomNavigationBar: NavigationBar);
//   600–905 → Row(NavigationRail, VerticalDivider, Expanded(child));
//   >= 905 → Row(NavigationDrawer(permanent), Expanded(child)).
// App bar: SliverAppBar(large: expandedHeight 112, pinned). Tabs: TabBar + TabBarView. go_router ShellRoute hosts this.
```

**React Native**
```tsx
// Bottom tabs (phone) — createBottomTabNavigator; each screen a nested stack.
// Tablet: a custom <Rail/> or <Drawer/> (createDrawerNavigator) chosen via useWindowDimensions.
<Tab.Navigator screenOptions={{ tabBarActiveTintColor: theme.colors.primary }}>
  <Tab.Screen name="Home" component={HomeStack} options={{ tabBarBadge: unread || undefined }} />
  ...
</Tab.Navigator>
// App bar: @react-navigation header or a custom animated header (Reanimated). Tabs: react-native-tab-view.
```

---

## 12. Snackbars

**Purpose** — brief, non-blocking confirmation or low-priority error, with at most one action.

**Variants** — `info` (default) · `success` (leading ✓) · `error` (leading ✕, `danger` accent, longer timeout, action = "Retry") · `withAction` ("Undo") · `multiline` (≤2 lines).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `message` | string | — | ≤2 lines |
| `variant` | enum | `info` | |
| `action` | `{label,onPress}?` | — | one only |
| `durationMs` | int | 4000 (info/success) / 6000–10000 (error/action) | pause on hover/focus/SR; extend under switch/SR |
| `onDismiss` | ()→void | — | swipe-to-dismiss |
| `leadingIcon` | icon? | by variant | |

**States** — enter (slide-up + fade 200ms `decelerate`) · visible (timer; pauses on interaction/focus) · action-pressed · dismissing (200ms `accelerate`) · queued (one at a time, newest waits).

**Accessibility** — `role=status` (polite) for info/success; `role=alert` (assertive) for errors only; the action is a real focusable button reachable before dismiss (extend timeout / require manual dismiss when a screen reader or switch access is active); never put critical info only in a snackbar.

**Animation** — as States; position above bottom nav / FAB, respecting safe area. Reduced-motion: fade only.

**Usage Rules** — confirm actions whose result isn't visible ("Message sent"). Offer "Undo" for destructive actions (5–7s) instead of a pre-confirm where feasible. One at a time. Not for form validation. Not for anything the user must read/act on.

**Do** — keep messages short + specific. Anchor above the FAB/bottom nav. Use `error` variant + "Retry" for transient failures.

**Don't** — stack multiple snackbars. Put two actions in one. Use for critical or must-read information. Auto-dismiss an error the user needs to act on before they can.

**Compose**
```kotlin
val host = remember { SnackbarHostState() }
Scaffold(snackbarHost = { SnackbarHost(host) { AmdsSnackbarVisuals(it) } }) { ... }
// scope.launch { host.showSnackbar(message = "Approved", actionLabel = "Undo", duration = SnackbarDuration.Short) }
// AmdsSnackbarVisuals: inverseSurface pill, leading icon by variant, action in primary tint.
```

**Flutter**
```dart
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Text('Approved'), behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AmdsRadius.md)),
  action: SnackBarAction(label: 'Undo', onPressed: _undo),
  duration: const Duration(seconds: 6),
));
// AmdsSnackbar.show(context, message, variant, action) wraps this; error variant → longer duration + Semantics(liveRegion assertive).
```

**React Native**
```tsx
snackbar.show({ message: 'Approved', variant: 'info', action: { label: 'Undo', onPress: undo }, durationMs: 6000 });
// A single portal-rendered <AmdsSnackbar/> at zIndex: toast, positioned above the tab bar (safe-area aware);
// Reanimated entering={SlideInDown} exiting={SlideOutDown}; AccessibilityInfo.announceForAccessibility(message).
```

---

## 13. FAB (Floating Action Button)

**Purpose** — the single most important, most frequent constructive action on a screen.

**Variants** — `regular` (56, icon 24) · `small` (40) · `extended` (icon + label, height 56, radius `full`/`lg`) · `lowered` (Extended → Regular on scroll).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | icon | — | |
| `label` | string? | — | Extended; real text, not baked into an image |
| `variant` | enum | `regular` | |
| `onPress` | ()→void | — | |
| `visible` | bool | true | hide on scroll-down |
| `loading` | bool | false | spinner in place of icon |
| `expandedContent` | slot? | — | speed-dial menu |

**States** — resting `elevation3` · pressed (0.96 scale, **not** elevation change) · hidden (scroll-down → scale + fade 200ms `accelerate`) · shown (scroll-up → 200ms `decelerate`) · loading.

**Accessibility** — role `button`; descriptive label ("New incident"); if it opens a speed-dial, `aria-expanded` + focus moves into the menu; Extended label is real text.

**Animation** — press 0.96 scale (`instant`); show/hide direction-aware 200ms; Regular↔Extended morph on scroll `standard` 250ms. Reduced-motion: instant show/hide (or keep always visible).

**Usage Rules** — **one FAB per screen.** Not for navigation, not for destructive actions, not when the primary action is already obvious in the layout. Bottom-right, `space.4` from edges, `space.4` above bottom nav (RTL: bottom-left). Content list gets bottom padding = FAB + 2×`space.4`.

**Do** — use Extended on empty/first-run screens for clarity. Move it into the nav rail as a prominent button on tablet landscape. Give the list enough bottom padding.

**Don't** — two FABs. A FAB for "Filter" or "Back". Cover content permanently. Hide it behind a scroll on a screen where it's the only way to create.

**Compose**
```kotlin
FloatingActionButton(onClick = onPress, modifier = Modifier.graphicsLayer { scaleX = scaleY = press }) {
  if (loading) CircularProgressIndicator(Modifier.size(24.dp), strokeWidth = 2.dp, color = AmdsTheme.colors.onPrimary)
  else Icon(icon, contentDescription = null)
}
// ExtendedFloatingActionButton(text = { Text(label) }, icon = { Icon(icon, null) }, expanded = !scrolled);
// AnimatedVisibility(visible, enter = scaleIn()+fadeIn(), exit = scaleOut()+fadeOut()).
```

**Flutter**
```dart
AnimatedScale(scale: visible ? 1 : 0, duration: AmdsMotion.base,
  child: FloatingActionButton.extended(onPressed: onPress, icon: Icon(icon), label: Text(label))
    // or FloatingActionButton(child: loading ? Spinner : Icon(icon))
)
// Scaffold(floatingActionButton:, floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
// hide on scroll: listen to a ScrollController and toggle `visible`.
```

**React Native**
```tsx
<AmdsFab icon="add" label={firstRun ? 'Report incident' : undefined}
  visible={!scrollingDown} loading={creating} onPress={create} />
// Absolutely-positioned Pressable (bottom+right, safe-area aware); Reanimated scale on scroll direction;
// accessibilityRole="button", accessibilityLabel="New incident".
```

---

## 14. Badges

**Purpose** — annotate an element with a count or status.

**Variants** — `dot` (6–8dp, unread/attention) · `count` (pill, "9" / "99+", ≤3 chars) · `statusLabel` (text pill: "Draft", "Overdue", "Live") · `standalone` (chip-badge).

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `type` | `dot`\|`count`\|`label` | `count` | |
| `value` | int / string | — | count caps at 99+ |
| `tone` | `danger`\|`warning`\|`success`\|`info`\|`neutral` | `neutral` | semantic, by meaning |
| `anchor` | slot | — | host icon/avatar |
| `max` | int | 99 | |
| `outline` | bool | auto | 1.5px `surface` ring when overlapping imagery |

**States** — static; count-change animates (old digit up-fades out, new up-fades in). Min 3:1 contrast against whatever is behind it.

**Accessibility** — value appended to the host's accessible name ("Notifications, 5 unread"); a dot announces "new"/"unread"; status label **text** is the source of truth, color secondary.

**Animation** — appear: scale 0→1 `spring` 150ms. Count change: digit up-fade `fast`. Reduced-motion: instant.

**Usage Rules** — dot = "something changed"; count = "how many". Cap at "99+". Don't badge many elements in one view. Status labels use a controlled per-app vocabulary (document it).

**Do** — add a `surface` outline when the badge overlaps an avatar/photo. Tint by meaning (`danger` overdue, `warning` pending, `success` done).

**Don't** — show raw counts > 99. Use color as the only status signal. Badge every list row.

**Compose**
```kotlin
BadgedBox(badge = {
  when (type) {
    Dot   -> Badge()
    Count -> Badge { Text(if (value > max) "$max+" else "$value") }
    Label -> AmdsStatusChip(text = value.toString(), tone = tone)
  }
}) { anchor() }
// Badge(containerColor = tone.color); semantics on the anchor: contentDescription = "$hostName, $value unread".
```

**Flutter**
```dart
Badge(
  label: type == AmdsBadgeType.count ? Text(value > max ? '$max+' : '$value') : null,
  isLabelVisible: type != AmdsBadgeType.dot ? true : true,
  backgroundColor: tone.color,
  child: anchor,
)
// status label → a small Container(pill) with tone.container bg + tone.onContainer text;
// Semantics(label: '$hostLabel, $value unread').
```

**React Native**
```tsx
<AmdsBadge type="count" value={unread} tone="danger" outline anchor={<Icon name="notifications" />} />
// absolutely-positioned View (top-right, overlap ~40%) with borderRadius: 'full', minWidth 16, 1.5px surface border when outline;
// parent accessibilityLabel composed with the count.
```

---

## 15. Avatar

**Purpose** — visual identity for a person or entity.

**Variants** — sizes `xs` 24 / `sm` 32 / `md` 40 / `lg` 56 / `xl` 80. Shape: `circle` (people) / `rounded` (`radius.sm`, orgs/assets). `withStatus` (dot) · `group` (stack up to 3 + "+N") · `withBadge`.

**Properties**

| Prop | Type | Default | Notes |
|---|---|---|---|
| `imageUrl` | string? | — | photo → initials → entity icon fallback |
| `name` | string | — | drives initials + fallback color |
| `size` | enum | `md` | |
| `shape` | `circle`\|`rounded` | `circle` | |
| `status` | `online`\|`away`\|`offline`? | — | bottom-right dot + 1.5px `surface` ring |
| `onPress` | ()→void? | — | e.g. "change photo" |

**States** — loaded (image) · fallback (initials on deterministic color, ≥3:1) · icon fallback · loading (circle skeleton) · with status.

**Accessibility** — decorative (`aria-hidden`) when the name is adjacent; otherwise labelled with the name; status meaning included in the label ("Priya Nair, online"); group stack labelled ("Priya, Sam, and 4 others"); if `onPress`, it's a labelled button ("Change profile photo").

**Animation** — image crossfades in on load 200ms; status dot scale-in `spring`; group stack: subtle offset. Reduced-motion: no crossfade.

**Usage Rules** — never the sole identifier — always show the name too. Consistent size within a list. Initials = first + last initial on a deterministic, sufficiently-dark color from the user id. Don't stretch non-square photos (center-crop).

**Do** — provide the initials + icon fallbacks. Ring the status dot with `surface`. Respect "no photo" without a visual penalty.

**Don't** — identify someone by avatar alone. Mix avatar sizes in one list. Use low-contrast initials backgrounds.

**Compose**
```kotlin
@Composable fun AmdsAvatar(name: String, imageUrl: String? = null, size: AmdsAvatarSize = Md,
  shape: AmdsAvatarShape = Circle, status: PresenceStatus? = null, onClick: (() -> Unit)? = null)
// Box(Modifier.size(size.dp).clip(shapeOf(shape))) { SubcomposeAsyncImage(imageUrl) { fallback → InitialsOrIcon(name) } }
// status → Box(align = BottomEnd).size(dot).background(status.color, CircleShape).border(1.5.dp, surface, CircleShape)
```

**Flutter**
```dart
AmdsAvatar(name: user.name, imageUrl: user.photoUrl, size: AmdsAvatarSize.md,
  status: user.presence, onTap: isSelf ? _changePhoto : null)
// CircleAvatar(backgroundImage: CachedNetworkImageProvider?, child: initials/icon on error);
// Stack + Positioned(bottom,right) for the status dot with a Container border.
// Semantics(label: '${user.name}${status != null ? ", ${status.label}" : ""}', image: true).
```

**React Native**
```tsx
<AmdsAvatar name={user.name} imageUrl={user.photoUrl} size="md" status={user.presence}
  onPress={isSelf ? changePhoto : undefined} />
// <Image> with onError → <InitialsView bg={colorFromId(user.id)} />; <View> status dot absolutely positioned with 1.5px surface border;
// accessibilityRole={onPress ? 'button' : 'image'}, accessibilityLabel composed with status.
```

---

## 16. Profile Components

**Purpose** — represent a person or entity with identity, key attributes, and quick actions. (Composite of Avatar + text + Chip + action rows.)

**Variants** — `header` (large, top of a profile screen) · `listItem` (compact: avatar 40 + name + subtitle + trailing action) · `contact` (mid-size, directory grid) · `mini` (avatar + name inline, in comments/activity).

**Properties**

| Prop | Type | Notes |
|---|---|---|
| `person` | `{name,title,department,avatarUrl,status}` | |
| `variant` | enum | header / listItem / contact / mini |
| `attributes` | `{icon,label,value,action?}[]` | contact rows (email→mail, phone→call, …) |
| `actions` | `Action[]` | Message / Call / View profile |
| `statusChip` | `{label,tone}?` | Active / On leave / Offline |
| `onPress` | ()→void? | listItem/contact → profile |

**States** — loading (avatar circle + text bars) · unknown user (initials/icon fallback) · self (edit affordance) · deactivated (muted + "Deactivated" chip).

**Accessibility** — name is the primary label; status + role announced; action buttons name the person where ambiguous ("Call Priya Nair"); avatar decorative when the name is present; attribute rows announce "label, value" + the trailing action separately.

**Animation** — header enter: fade. Avatar/status per §15. List-item press: `surfaceVariant` overlay. Reduced-motion: crossfades only.

**Usage Rules** — never rely on the avatar alone. Consistent variant within a context. Don't expose PII (phone/email) in list contexts that don't need it.

**Do** — use `listItem` in directories, `header` on the profile screen, `mini` in feeds. Deterministic initials fallback. Gate sensitive attributes by permission.

**Don't** — mix `contact` and `listItem` in one list. Show email/phone in a queue row that only needs the name. Identify by photo only.

**Compose**
```kotlin
@Composable fun AmdsProfileHeader(person: Person, actions: List<AmdsAction>, statusChip: AmdsChipData?)
@Composable fun AmdsProfileListItem(person: Person, trailing: @Composable (() -> Unit)? , onClick: () -> Unit)
// header: Column { AmdsAvatar(Xl); Text(name, headlineLarge); Text("$title · $department", bodyMedium, textSecondary);
//   statusChip?.let { AmdsChip(it) }; Row { actions.forEach { AmdsButton(it.label, it.onClick, size = Sm) } } }
// listItem: ListItem(leadingContent = { AmdsAvatar(Md) }, headlineContent = { Text(name) },
//   supportingContent = { Text(subtitle) }, trailingContent = trailing, modifier = Modifier.clickable(onClick))
```

**Flutter**
```dart
AmdsProfileHeader(person: p, statusChip: AmdsChipData('On leave', AmdsTone.warning),
  actions: [AmdsAction('Message', _msg), AmdsAction('Call', _call)])
AmdsProfileTile(person: p, subtitle: p.department, trailing: AmdsIconButton(Icons.chevron_right), onTap: () => open(p.id))
// header: Column(children: [AmdsAvatar(xl), Text(name, style: headlineLarge), Text('$title · $dept'), AmdsChip(...), Wrap(actions)]);
// tile: ListTile(leading: AmdsAvatar(md), title: Text(name), subtitle: Text(subtitle), trailing: trailing, onTap: onTap).
```

**React Native**
```tsx
<AmdsProfileHeader person={p} statusChip={{ label: 'On leave', tone: 'warning' }}
  actions={[{ label: 'Message', onPress: msg }, { label: 'Call', onPress: call }]} />
<AmdsProfileRow person={p} subtitle={p.department} onPress={() => open(p.id)} trailing={<Chevron/>} />
// header: View column — <AmdsAvatar size="xl"/> + <Text> name/title + <AmdsChip/> + <Row> of <AmdsButton size="sm"/>;
// row: Pressable — <AmdsAvatar size="md"/> + text column + trailing; accessibilityRole="button".
```

---

## 17. Timeline Components

**Purpose** — show a chronological sequence of events (audit trail, approval chain, activity history, order status, delivery tracking).

**Variants** — `activityFeed` (reverse-chronological, icon + actor + action + time) · `processStepper` (vertical, ordered, with states: complete ✓ / active / upcoming / error — used for approval chains) · `statusTracker` (horizontal, ≤4 steps, e.g. order → picked → shipped → delivered) · `groupedByDate` (Today / Yesterday / Earlier headers).

**Properties**

| Prop | Type | Notes |
|---|---|---|
| `entries` | `Entry[] {id,icon?,actor?,title,detail?,timestamp,state?}` | |
| `variant` | enum | feed / stepper / tracker |
| `orientation` | `vertical`\|`horizontal` | tracker = horizontal |
| `connector` | `line`\|`dashed` | between nodes |
| `currentId` | string? | `aria-current` node |
| `onEntryPress` | (entry)→void? | → the related artifact |
| `groupByDate` | bool | feed |
| `loading` / `empty` | state | 3–4 node skeletons / "No activity yet" |

**States** — node: `complete` (filled, `success`/`primary`) · `active`/`current` (ring, pulses once on load) · `upcoming` (outline, `textTertiary`) · `error` (`danger` fill + icon). Feed row: `pressed` (`surfaceVariant`). New entry: expand + fade + 2s `primaryContainer` tint.

**Accessibility** — the timeline is an **ordered list**; each entry = one grouped stop read in order ("2 March, 9:12 AM. S. Lee approved. Comment: verified the PO."); `aria-current` on the active/outcome node; connectors are decorative (`aria-hidden`); state conveyed by icon + label, not color alone; horizontal tracker still reads top-to-bottom / start-to-end logically.

**Animation** — entries fade + riseY 8→0 staggered 30ms on first paint (≤8). Current node: one subtle pulse on load (reduced-motion: static). Stepper advance: connector fills + next node activates 250ms. Reduced-motion: no stagger, no pulse, fade only.

**Usage Rules** — chronological and consistent (feed = newest first; process = submission → outcome). Every entry shows who + what + when (+ why for decisions). Immutable for audit logs. Group long feeds by date. Link entries to their source.

**Do** — use `processStepper` for approval chains (motion §11), `statusTracker` for fulfillment, `activityFeed` for audit/history. Show reasons/comments prominently. Collapse resubmission cycles into a group.

**Don't** — mix ordering directions in one timeline. Encode step state by color only. Make audit entries editable. Render hundreds of nodes — paginate/virtualize.

**Compose**
```kotlin
@Composable fun AmdsTimeline(entries: List<AmdsTimelineEntry>, variant: AmdsTimelineVariant = Feed,
  currentId: String? = null, onEntryClick: ((AmdsTimelineEntry) -> Unit)? = null)
// LazyColumn { itemsIndexed(entries) { i, e ->
//   Row { TimelineGutter(isFirst = i==0, isLast = i==last, node = nodeFor(e.state), connector = i < last)
//         Column { e.actor?.let { Text(it, labelMedium) }; Text(e.title); e.detail?.let { Text(it, bodyMedium, textSecondary) }; Text(rel(e.timestamp), caption) } }
// } }
// gutter drawn with Canvas (line + circle); semantics { if (e.id == currentId) this.selected = true }.
```

**Flutter**
```dart
AmdsTimeline(
  entries: history, variant: AmdsTimelineVariant.stepper, currentId: state.currentStepId,
  onEntryTap: (e) => openArtifact(e),
)
// timeline_tile package OR custom: Column of Row(children: [ SizedBox(width: 24, child: CustomPaint(painter: _Connector(state))), Expanded(child: _EntryBody(e)) ]);
// MergeSemantics per entry; Semantics(label: '${fmtDate(e.timestamp)}. ${e.actor} ${e.action}. ${e.detail}').
```

**React Native**
```tsx
<AmdsTimeline entries={history} variant="stepper" currentId={currentStepId}
  onEntryPress={openArtifact} />
// FlashList / map → each entry: <View row> <TimelineGutter node=state connector/> <View body: actor, title, detail, time/> </View>
// gutter via react-native-svg (line + circle); accessibilityRole="text", composed accessibilityLabel per entry;
// entering={FadeInDown} with staggered delay (i*30) unless reduceMotion.
```

---

## 18. Notification Components

**Purpose** — represent an in-app notification in a list, and its unread/badge affordances. (The screens are in [`screen-library/06-notifications.md`](../screen-library/06-notifications.md); these are the building blocks.)

**Variants** — `notificationRow` (list item: leading category icon/avatar · title + snippet · timestamp · unread dot · optional quick action) · `notificationGroupHeader` (date bucket) · `bellWithBadge` (app-bar affordance) · `inlineNotificationCard` (a rich notification rendered in-context, e.g. an announcement on the dashboard) · `pushPreview` (design-time reference for the OS notification layout).

**Properties (notificationRow)**

| Prop | Type | Notes |
|---|---|---|
| `notification` | `{id,category,title,body,actorId?,createdAt,readAt?,entityRef,actions[]}` | |
| `unread` | bool | derived from `readAt == null` |
| `leading` | `categoryIcon`\|`avatar` | |
| `quickAction` | `{label,onPress}?` | safe, high-value only ("Approve", "View") |
| `onPress` | ()→void | deep-link to `entityRef`, mark read |
| `onSwipe` | `{markRead, dismiss}` | |

**States** — `unread` (title `titleMedium` bold + dot; on read → dot fades, title weight crossfades 150ms) · `read` · `pressed` (`surfaceVariant`) · `new` (just arrived while open → expand + fade + 2s `primaryContainer` tint) · `dismissing` (collapse + fade + slide 200ms `accelerate`) · quick-action `loading`.

**Accessibility** — row = one grouped stop: "Unread. Purchase request PR-88120 needs your approval. From S. Adeyemi. 20 minutes ago." Unread state announced. Quick-action button separately labelled with context ("Approve PR-88120"). Bell badge value in the affordance's accessible name ("Notifications, 5 unread"). New-arrival announcements **polite**, no focus move. Group headers = headings. Swipe actions exposed as custom actions + present in a row overflow.

**Animation** — read transition 150ms; new-item insert + tint (2s fade); dismiss 200ms `accelerate`; "mark all read" → dots fade in a quick L→R cascade (reduced-motion: all at once); badge count digit up-fade. Reduced-motion: fade only, no cascade/slide.

**Usage Rules** — tapping goes to the exact source and marks read. Unread by **weight + dot**, not background color. Batch similar events ("3 comments on INC-442"). Quick actions only for safe, reversible, high-value cases. Respect per-category settings.

**Do** — deep-link precisely via `entityRef`. Keep the snippet to 1–2 lines. Sync read state across devices. Drive the OS app-icon badge from the same unread count.

**Don't** — signal unread with background color alone. Put risky actions (Reject/Delete) as row quick actions. Require the app to have been open to have "received" a notification (this list is the durable record). Lose scroll position on return.

**Compose**
```kotlin
@Composable fun AmdsNotificationRow(n: AppNotification, onClick: () -> Unit,
  onMarkRead: () -> Unit, onDismiss: () -> Unit, quickAction: AmdsAction? = null)
// SwipeToDismissBox(state = rememberSwipeToDismissBoxState(), backgroundContent = { SwipeBg() }) {
//   ListItem(
//     leadingContent = { if (n.actorId != null) AmdsAvatar(...) else CategoryIcon(n.category) },
//     headlineContent = { Text(n.title, fontWeight = if (n.unread) FontWeight.SemiBold else FontWeight.Normal) },
//     supportingContent = { Text(n.body, maxLines = 2, overflow = Ellipsis, color = AmdsTheme.colors.textSecondary) },
//     trailingContent = { Column { Text(rel(n.createdAt), style = caption); if (n.unread) UnreadDot() } },
//     modifier = Modifier.clickable(onClick)
//   )
//   quickAction?.let { AmdsButton(it.label, it.onPress, size = Sm, variant = Tonal) }
// }
// semantics { contentDescription = buildNotificationA11y(n); customActions = listOf(markRead, dismiss) }
```

**Flutter**
```dart
Dismissible(
  key: ValueKey(n.id),
  background: const _SwipeBg(action: 'Mark read'),
  secondaryBackground: const _SwipeBg(action: 'Dismiss', destructive: true),
  confirmDismiss: (dir) async => dir == DismissDirection.startToEnd ? (onMarkRead(), false).$2 : true,
  onDismissed: (_) => onDismiss(),
  child: ListTile(
    leading: n.actorId != null ? AmdsAvatar(size: AmdsAvatarSize.sm, /*...*/) : CategoryIcon(n.category),
    title: Text(n.title, style: n.unread ? context.text.titleMedium : context.text.bodyMedium),
    subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: Column(children: [ Text(rel(n.createdAt), style: context.text.caption), if (n.unread) const _Dot() ]),
    onTap: () { onTap(); markRead(); },
  ),
)
// Semantics(label: buildNotificationA11y(n), button: true); grouped by date via a builder that inserts headers.
```

**React Native**
```tsx
<Swipeable renderLeftActions={MarkReadAction} renderRightActions={DismissAction}
  onSwipeableOpen={(dir) => dir === 'left' ? onMarkRead() : onDismiss()}>
  <Pressable onPress={() => { onPress(); }} accessibilityLabel={buildNotificationA11y(n)}
    accessibilityActions={[{name:'markRead'},{name:'dismiss'}]} onAccessibilityAction={handleA11yAction}>
    <View row>
      {n.actorId ? <AmdsAvatar size="sm" .../> : <CategoryIcon category={n.category} />}
      <View flex>
        <Text style={n.unread ? theme.typography.titleMedium : theme.typography.bodyMedium} numberOfLines={1}>{n.title}</Text>
        <Text style={theme.typography.bodyMedium} numberOfLines={2}>{n.body}</Text>
      </View>
      <View>
        <Text style={theme.typography.caption}>{rel(n.createdAt)}</Text>
        {n.unread && <UnreadDot />}
      </View>
    </View>
  </Pressable>
</Swipeable>
// SectionList groups by date bucket; new items: Reanimated entering + a timed tint; badge on the bell composed into its label.
```

---

## Appendix · Component → screen usage matrix

| Component | Primary screens (see [`screen-library/`](../screen-library/README.md)) |
|---|---|
| Buttons | every screen (CTAs, form submit, decision bars) |
| Cards | Dashboard, Detail, Reports, Profile |
| Inputs | Login/Register/Reset, all Forms, Contact Support |
| Search | List View, User List, Notifications, FAQ, Reports |
| Dropdowns | Forms, Filters, Settings pickers |
| Bottom Sheets | Filters, Sort, action menus, pickers, Export (phone) |
| Dialogs | Delete Confirmation, sign-out, discard, session-expiry |
| Modals | Create/Edit Form, wizards, media viewers |
| Tables | Data List (tablet), Report Detail, Approval line items |
| Charts | all Dashboards, Report Detail, KPI cards |
| Navigation | app shell (every screen) |
| Snackbars | after create/update/delete/approve (Undo), transient errors |
| FAB | Dashboard, List View, User List |
| Badges | Bottom nav (Approvals), bell, list-row status, avatars |
| Avatar | Profile, User List/Detail, Approvals, Comments, Activity |
| Profile Components | My Profile, User Detail, Directory, Comments |
| Timeline Components | Approval Detail/History, Data Detail (audit), Activity feeds |
| Notification Components | Notification List/Detail, Dashboard alerts, bell affordance |
