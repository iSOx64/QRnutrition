import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../admin/presentation/widgets/admin_log_tile.dart';
import '../controllers/system_logs_controller.dart';

class SystemLogsPage extends StatelessWidget {
  const SystemLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          SystemLogsController(context.read<AdminRepository>())
            ..loadSystemLogs(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Logs systeme')),
        body: Consumer<SystemLogsController>(
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
