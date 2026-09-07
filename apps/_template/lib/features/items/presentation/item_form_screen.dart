import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/item.dart';
import 'items_controller.dart';

/// Create ([id] == null) or edit an item. One screen, one form, one save path.
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({this.id, super.key});

  final String? id;
  bool get isEdit => id != null;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  bool _submitting = false;
  bool _prefilled = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final controller = ref.read(itemsControllerProvider.notifier);
    final error = widget.isEdit
        ? await controller.edit(widget.id!,
            title: _title.text.trim(), subtitle: _subtitle.text.trim())
        : await controller.create(ItemDraft(
            title: _title.text.trim(), subtitle: _subtitle.text.trim()));

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _error = error;
      });
      return;
    }
    AmdsSnackbar.show(context,
        message: widget.isEdit ? 'Saved' : 'Created',
        tone: AmdsStatusTone.success);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Edit [DATA_NAME]' : 'New [DATA_NAME]';

    // Prefill once when editing.
    if (widget.isEdit && !_prefilled) {
      final existing = ref.watch(itemByIdProvider(widget.id!));
      if (existing case AsyncData(:final value)) {
        _title.text = value.title;
        _subtitle.text = value.subtitle;
        _prefilled = true;
      } else if (existing.isLoading) {
        return AmdsScaffold(
          scrollable: false,
          appBar: AppBar(title: Text(title)),
          body: const AmdsLoadingState(),
        );
      }
    }

    return AmdsScaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AmdsSpacing.md),
            AmdsTextField(
              label: 'Title',
              controller: _title,
              required: true,
              autofocus: !widget.isEdit,
              validator: Validators.all([
                Validators.required(),
                Validators.minLength(3),
              ]),
            ),
            const SizedBox(height: AmdsSpacing.md),
            AmdsTextField(
              label: 'Owner / reference',
              controller: _subtitle,
              required: true,
              validator: Validators.required(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AmdsSpacing.md),
              AmdsBanner(message: _error!, tone: AmdsStatusTone.danger),
            ],
            const SizedBox(height: AmdsSpacing.xl),
            AmdsButton(
              label: widget.isEdit ? 'Save changes' : 'Create',
              fullWidth: true,
              size: AmdsButtonSize.lg,
              loading: _submitting,
              onPressed: _submitting ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
