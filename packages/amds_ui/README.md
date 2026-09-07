# amds_ui

AMDS v1.0 Flutter component library. Re-exports `amds_tokens` **and `amds_motion`**, so apps import only this package.

```dart
import 'package:amds_ui/amds_ui.dart';
```

## Component set (this package)

| Group | Widgets |
|---|---|
| Actions | `AmdsButton` (6 variants × 3 sizes, loading, press-spring), `AmdsIconButton` |
| Inputs | `AmdsTextField`, `AmdsPasswordField`, `AmdsSearchBar` (debounced), `AmdsDropdown<T>`, `AmdsCheckbox` / `AmdsCheckboxTile`, `AmdsRadioGroup<T>` / `AmdsRadioTile<T>`, `AmdsSwitchTile`, `AmdsSlider` |
| Content | `AmdsCard`, `AmdsKpiCard`, `AmdsStat`, `AmdsDeltaChip`, `AmdsListItem`, `AmdsListGroup`, `AmdsDivider`, `AmdsAvatar`, `AmdsBadge`, `AmdsStatusChip`, `AmdsChip` / `AmdsFilterChips<T>` / `AmdsChoiceChips<T>`, `AmdsAccordion`, `AmdsImage` (progressive), `AmdsSectionHeader` |
| Navigation | `AmdsScaffold`, `AmdsAdaptiveNavigation` (bottom nav → rail → drawer), `AmdsSegmentedControl<T>`, `AmdsTabs` |
| Feedback | `AmdsBanner`, `AmdsSnackbar.show(...)`, `AmdsDialogs.confirm(...)`, `AmdsBottomSheet.show/actions(...)` |
| Loading | `AmdsProgressBar`, `AmdsCircularProgress`, `AmdsLoadingOverlay`, `AmdsSkeleton`, `AmdsSkeletonList` |
| State | `AmdsLoadingState`, `AmdsEmptyState`, `AmdsErrorState`, `AmdsOfflineBanner` |
| Motion (from [`amds_motion`](../amds_motion/README.md)) | `AmdsPageRoute` / `AmdsPageTransitions`, `AmdsFadeSlideIn`, `AmdsScaleIn`, `AmdsStagger`, `AmdsPressable`, `AmdsAnimatedCount`, `AmdsShake`, `AmdsPulse`, `AmdsSwitcher`, `AmdsCrossFade` |

Every widget: token-driven, dark-mode aware, honors reduce-motion + Dynamic Type, ≥44dp targets, `Semantics` for role/name/state.

## Extending

~45 components ship here — the common core of [`../../docs/component-library/`](../../docs/component-library/README.md). Still to add: Data Table, Chart Container, Timeline, Breadcrumb, Time Picker, Tooltip (rich). Add one against the 15-point template + the [Definition of Done](../../docs/governance.md#4-definition-of-done--component). Drive it with [`prompts/component-library-generator.md`](../../prompts/component-library-generator.md).

## Testing

`flutter test` runs widget + golden tests in `test/`. Update goldens with `melos run test:golden`.
