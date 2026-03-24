import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/admin_log_model.dart';

class AdminLogTile extends StatelessWidget {
  AdminLogTile({
    super.key,
    required this.log,
  }) : _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final AdminLog log;
  final DateFormat _dateFormat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.admin_panel_settings),
      title: Text(log.action),
      subtitle: Text('${log.details}\n${_dateFormat.format(log.createdAt)}'),
      isThreeLine: true,
      trailing: Text(log.targetId),
    );
  }
}
