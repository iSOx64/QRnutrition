import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreview extends StatelessWidget {
  const QrPreview({
    super.key,
    required this.value,
    this.size = 160,
  });

  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: QrImageView(
        data: value,
        size: size,
        backgroundColor: Colors.white,
        gapless: false,
      ),
    );
  }
}
