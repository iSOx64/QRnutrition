import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class UserHomeController extends ChangeNotifier {
  UserHomeController(this._profileRepository);

  final ProfileRepository _profileRepository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  AppUser? _user;
  AppUser? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUser(String uid) async {
    _setState(ViewStatus.loading);
    try {
      final fetched = await _profileRepository.getUserById(uid);
      if (fetched == null) {
        _user = null;
        _setState(ViewStatus.empty);
      } else {
        _user = fetched;
        _setState(ViewStatus.success);
      }
    } catch (e) {
      _setError('Impossible de charger les informations utilisateur.');
    }
  }

  void setUser(AppUser? user) {
    _user = user;
    if (user == null) {
      _status = ViewStatus.empty;
    } else {
      _status = ViewStatus.success;
    }
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
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
