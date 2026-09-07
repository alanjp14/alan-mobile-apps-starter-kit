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
| Content | `AmdsCard`, `AmdsKpiCard`, `AmdsStat`, `AmdsDeltaChip`, `AmdsListItem`, `AmdsListGroup`, `AmdsDivider`, `AmdsAvatar`, `AmdsBadge`, `AmdsStatusChip`, `AmdsChip` / `AmdsFilterChips<T>` / `AmdsChoiceChips<T>`, `AmdsAccordion`, `AmdsImage` (progressive), `AmdsTimeline`, `AmdsBreadcrumb`, `AmdsSectionHeader` |
| Inputs (date/time) | `AmdsDateField`, `AmdsTimeField` |
| Navigation | `AmdsScaffold`, `AmdsAdaptiveNavigation` (bottom nav → rail → drawer), `AmdsSegmentedControl<T>`, `AmdsTabs` |
| Data display | `AmdsDataTable<T>` (sort · selection · density), `AmdsChartContainer` + `AmdsLegend`, `AmdsSparkline`, `AmdsPagination`, `AmdsLoadMoreFooter` |
| Feedback | `AmdsBanner`, `AmdsSnackbar.show(...)`, `AmdsDialogs.confirm(...)`, `AmdsBottomSheet.show/actions(...)`, `AmdsTooltip` / `AmdsInfoDot` |
| Loading | `AmdsProgressBar`, `AmdsCircularProgress`, `AmdsLoadingOverlay`, `AmdsSkeleton`, `AmdsSkeletonList` |
| State | `AmdsLoadingState`, `AmdsEmptyState`, `AmdsErrorState`, `AmdsOfflineBanner` |
| Motion (from [`amds_motion`](../amds_motion/README.md)) | `AmdsPageRoute` / `AmdsPageTransitions`, `AmdsFadeSlideIn`, `AmdsScaleIn`, `AmdsStagger`, `AmdsPressable`, `AmdsAnimatedCount`, `AmdsShake`, `AmdsPulse`, `AmdsSwitcher`, `AmdsCrossFade` |

Every widget: token-driven, dark-mode aware, honors reduce-motion + Dynamic Type, ≥44dp targets, `Semantics` for role/name/state.

## Extending

~60 components ship here — the working core of [`../../docs/component-library/`](../../docs/component-library/README.md). The remaining gaps are composite/screen-level (Filter Bar, Sort Sheet, Export flow) and a real charting engine (bring your own — `AmdsChartContainer` is the frame). Add one against the 15-point template + the [Definition of Done](../../docs/governance.md#4-definition-of-done--component). Drive it with [`prompts/component-library-generator.md`](../../prompts/component-library-generator.md).

## Testing

`flutter test` runs the behaviour tests and the golden tests in `test/`.

Goldens use **[Alchemist](https://pub.dev/packages/alchemist) CI mode** — text is
rendered as blocked squares (Ahem font), shadows are off, so a single set of
baselines in `test/goldens/ci/` is byte-identical on macOS, Windows and Linux.
Regenerate after an intentional visual change:

```bash
melos run test:golden      # or: flutter test -t golden --update-goldens
```

Review the PNG diff like code; commit baseline changes on their own.
