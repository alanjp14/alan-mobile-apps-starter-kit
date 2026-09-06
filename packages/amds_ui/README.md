# amds_ui

AMDS v1.0 Flutter component library. Re-exports `amds_tokens`, so apps import only this package.

```dart
import 'package:amds_ui/amds_ui.dart';
```

## Starter set (this package)

| Group | Widgets |
|---|---|
| Actions | `AmdsButton` (6 variants × 3 sizes, loading, press-spring), `AmdsIconButton` |
| Containment | `AmdsCard`, `AmdsStatusChip`, `AmdsBadge`, `AmdsAvatar`, `AmdsSectionHeader` |
| Inputs | `AmdsTextField`, `AmdsPasswordField` |
| Feedback | `AmdsBanner`, `AmdsSnackbar.show(...)`, `AmdsDialogs.confirm(...)` |
| Layout | `AmdsScaffold`, `AmdsAdaptiveNavigation` (bottom nav → rail → drawer) |
| State | `AmdsLoadingState`, `AmdsEmptyState`, `AmdsErrorState`, `AmdsOfflineBanner`, `AmdsSkeleton`, `AmdsSkeletonList` |
| Motion | `AmdsPressable`, `AmdsFadeSlideIn`, `AmdsAnimatedCount`, `amdsSharedAxisTransition` |

Every widget: token-driven, dark-mode aware, honors reduce-motion + Dynamic Type, ≥44dp targets, `Semantics` for role/name/state.

## Extending

The full library is ~40 components ([`../../docs/component-library/`](../../docs/component-library/README.md)). Add one against the 15-point template + the [Definition of Done](../../docs/governance.md#4-definition-of-done--component). Drive it with [`prompts/component-library-generator.md`](../../prompts/component-library-generator.md).

## Testing

`flutter test` runs widget + golden tests in `test/`. Update goldens with `melos run test:golden`.
