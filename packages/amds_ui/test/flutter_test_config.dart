import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Golden-test config for amds_ui.
///
/// Only **CI goldens** are generated (`test/goldens/ci/*.png`): text renders as
/// blocked squares in the Ahem font so the output is byte-identical on macOS,
/// Windows and Linux — no per-platform baselines to maintain. Regenerate with
/// `melos run test:golden` (or `flutter test --update-goldens`).
Future<void> testExecutable(FutureOr<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
      ciGoldensConfig: CiGoldensConfig(enabled: true),
    ),
    run: () async => testMain(),
  );
}
