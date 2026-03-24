import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/scan_history_item_model.dart';

class HistoryItemTile extends StatelessWidget {
  HistoryItemTile({
    super.key,
    required this.item,
    required this.onTap,
  }) : _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final ScanHistoryItem item;
  final VoidCallback onTap;
  final DateFormat _dateFormat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: const Icon(Icons.history),
      ),
      title: Text(item.productName),
      subtitle: Text(_dateFormat.format(item.scannedAt)),
      trailing: Text('${item.calories.toStringAsFixed(0)} kcal'),
    );
  }
}
