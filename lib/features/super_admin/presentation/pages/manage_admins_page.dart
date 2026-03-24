import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_roles.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/super_admin_repository.dart';
import '../controllers/manage_admins_controller.dart';
import '../widgets/role_selector_dialog.dart';

class ManageAdminsPage extends StatelessWidget {
  const ManageAdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final adminId = auth.state.user?.uid;

    if (adminId == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) => ManageAdminsController(
        context.read<SuperAdminRepository>(),
        context.read<AdminRepository>(),
      )..loadUsers(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gestion des admins')),
        body: Consumer<ManageAdminsController>(
          builder: (context, controller, _) {
            if (controller.status == ViewStatus.loading) {
              return const LoadingState();
            }
            return ListView.separated(
              itemCount: controller.users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = controller.users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.fullName.isEmpty ? user.email : user.fullName),
                  subtitle: Text(user.email),
                  trailing: Text(user.role),
                  onTap: () async {
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (_) => RoleSelectorDialog(
                        currentRole: user.role,
                      ),
                    );
                    if (selected == null || selected == user.role) return;
                    if (!_isRoleChangeAllowed(user.role, selected)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Changement de role non autorise.'),
                        ),
                      );
                      return;
                    }
                    await controller.updateUserRole(
                      targetUserId: user.uid,
                      newRole: selected,
                      adminId: adminId,
                      previousRole: user.role,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool _isRoleChangeAllowed(String current, String next) {
    if (current == AppRoles.superAdmin && next != AppRoles.superAdmin) {
      return true;
    }
    if (current == AppRoles.admin && next == AppRoles.user) return true;
    if (current == AppRoles.user && next == AppRoles.admin) return true;
    if (current == AppRoles.admin && next == AppRoles.superAdmin) return true;
    if (current == AppRoles.user && next == AppRoles.superAdmin) return true;
    return false;
  }
}
