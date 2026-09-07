// AMDS v1.0 · Search Bar — debounced query input with a clear affordance.
// See docs/component-library/design-specs.md (Inputs › Search).

import 'dart:async';

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

class AmdsSearchBar extends StatefulWidget {
  const AmdsSearchBar({
    required this.onChanged,
    this.controller,
    this.hint = 'Search',
    this.autofocus = false,
    this.debounce = const Duration(milliseconds: 250),
    this.onSubmitted,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hint;
  final bool autofocus;
  final Duration debounce;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AmdsSearchBar> createState() => _AmdsSearchBarState();
}

class _AmdsSearchBarState extends State<AmdsSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(Icons.search, color: c.onSurfaceVariant),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close),
                iconSize: AmdsSize.iconSm,
                tooltip: 'Clear',
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: c.surfaceVariant,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AmdsSpacing.sm),
        border: const OutlineInputBorder(
          borderRadius: AmdsRadius.brFull,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AmdsRadius.brFull,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AmdsRadius.brFull,
          borderSide:
              BorderSide(color: c.borderFocus, width: AmdsBorderWidth.thick),
        ),
      ),
    );
  }
}
