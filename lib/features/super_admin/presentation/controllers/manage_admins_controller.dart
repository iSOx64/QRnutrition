import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../../admin/data/models/admin_log_model.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../data/repositories/super_admin_repository.dart';

class ManageAdminsController extends ChangeNotifier {
  ManageAdminsController(this._superAdminRepository, this._adminRepository);

  final SuperAdminRepository _superAdminRepository;
  final AdminRepository _adminRepository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _setState(ViewStatus.loading);
    try {
      _users = await _superAdminRepository.getAllUsers();
      _setState(_users.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les utilisateurs.');
    }
  }

  Future<void> updateUserRole({
    required String targetUserId,
    required String newRole,
    required String adminId,
    required String previousRole,
  }) async {
    _setUpdating(true);
    try {
      await _superAdminRepository.updateUserRole(
        uid: targetUserId,
        role: newRole,
      );
      _users = _users
          .map((u) => u.uid == targetUserId ? u.copyWith(role: newRole) : u)
          .toList();
      await _adminRepository.createAdminLog(
        AdminLog(
          id: '',
          adminId: adminId,
          action: 'role_update',
          targetId: targetUserId,
          details: 'Rôle: $previousRole -> $newRole',
          createdAt: DateTime.now(),
        ),
      );
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de mettre à jour le rôle.');
    } finally {
      _setUpdating(false);
    }
  }

  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  void _setState(ViewStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ViewStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
