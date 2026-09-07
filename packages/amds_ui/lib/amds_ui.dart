/// AMDS v1.0 Flutter component library.
///
/// ```dart
/// import 'package:amds_ui/amds_ui.dart';
///
/// MaterialApp(
///   theme: AmdsTheme.light(),
///   darkTheme: AmdsTheme.dark(),
///   themeMode: ThemeMode.system,
///   home: AmdsScaffold(
///     title: 'Home',
///     body: AmdsButton(label: 'Save', onPressed: () {}),
///   ),
/// );
/// ```
///
/// This is a **starter set** of the most-used components. Extend it against
/// docs/component-library/ using prompts/component-library-generator.md.
library;

// re-export tokens + motion so apps import one package
export 'package:amds_motion/amds_motion.dart';
export 'package:amds_tokens/amds_tokens.dart';

export 'src/components/amds_accordion.dart';
export 'src/components/amds_button.dart';
export 'src/components/amds_card.dart';
export 'src/components/amds_chip.dart';
export 'src/components/amds_dropdown.dart';
export 'src/components/amds_feedback.dart';
export 'src/components/amds_image.dart';
export 'src/components/amds_kpi.dart';
export 'src/components/amds_list_item.dart';
export 'src/components/amds_misc.dart';
export 'src/components/amds_progress.dart';
export 'src/components/amds_search_bar.dart';
export 'src/components/amds_segmented.dart';
export 'src/components/amds_selection.dart';
export 'src/components/amds_sheet.dart';
export 'src/components/amds_text_field.dart';
export 'src/layout/amds_scaffold.dart';
export 'src/state/amds_skeleton.dart';
export 'src/state/amds_states.dart';
