// Runtime light/dark/system choice. Persist it with shared_preferences in a
// real app (see docs/starter-template/local-storage.md §preferences) — kept
// in-memory here so the template has zero extra plugins.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;

  void toggle() => state = switch (state) {
        ThemeMode.dark => ThemeMode.light,
        _ => ThemeMode.dark,
      };
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
