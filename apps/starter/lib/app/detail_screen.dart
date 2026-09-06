import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return AmdsScaffold(
      appBar: AppBar(title: const Text('Detail')),
      banner: const AmdsOfflineBanner(asOf: '9:04 AM'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AmdsSpacing.md),
          Row(
            children: [
              const AmdsAvatar(name: 'Compressor A-12', size: AmdsSize.avatarLg),
              const SizedBox(width: AmdsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compressor A-12', style: context.text.headlineMedium),
                    const SizedBox(height: AmdsSpacing.xxs),
                    Text('Asset · East site', style: TextStyle(color: c.textSecondary)),
                  ],
                ),
              ),
              const AmdsStatusChip('Active', tone: AmdsStatusTone.success),
            ],
          ),
          const AmdsSectionHeader('Details'),
          for (final row in const [
            ('Serial', 'CMP-10293'),
            ('Owner', 'P. Nair'),
            ('Last service', '12 Mar 2026'),
            ('Location', 'East site · Bay 3'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 120, child: Text(row.$1, style: TextStyle(color: c.textSecondary))),
                  Expanded(child: Text(row.$2, style: context.text.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: AmdsSpacing.xl),
          AmdsButton(
            label: 'Report an issue',
            onPressed: () => AmdsSnackbar.show(context, message: 'Issue reported', tone: AmdsStatusTone.info),
            fullWidth: true,
          ),
          const SizedBox(height: AmdsSpacing.xl),
        ],
      ),
    );
  }
}
