import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../data/repositories/admin_repository.dart';
import '../controllers/admin_logs_controller.dart';
import '../widgets/admin_log_tile.dart';

class AdminLogsPage extends StatefulWidget {
  const AdminLogsPage({super.key});

  @override
  State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  String? _actionFilter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AdminLogsController(context.read<AdminRepository>())
            ..loadAdminLogs(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Logs admin'),
          actions: [
            DropdownButton<String>(
              value: _actionFilter,
              hint: const Text('Filtrer'),
              items: const [
                DropdownMenuItem(value: 'create_product', child: Text('Create')),
                DropdownMenuItem(value: 'update_product', child: Text('Update')),
                DropdownMenuItem(value: 'delete_product', child: Text('Delete')),
                DropdownMenuItem(value: 'role_update', child: Text('Role')),
              ],
              onChanged: (value) {
                setState(() => _actionFilter = value);
                context
                    .read<AdminLogsController>()
                    .loadAdminLogs(action: value);
              },
            ),
          ],
        ),
        body: Consumer<AdminLogsController>(
          builder: (context, controller, _) {
            if (controller.status == ViewStatus.loading) {
              return const LoadingState();
            }
            if (controller.logs.isEmpty) {
              return const Center(child: Text('Aucun log'));
            }
            return ListView.separated(
              itemCount: controller.logs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return AdminLogTile(log: controller.logs[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
