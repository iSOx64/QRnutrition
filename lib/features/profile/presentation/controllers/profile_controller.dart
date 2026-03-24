import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  AppUser? _user;
  AppUser? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> loadProfile(String uid) async {
    _setState(ViewStatus.loading);
    try {
      final fetched = await _repository.getUserById(uid);
      if (fetched == null) {
        _user = null;
        _setState(ViewStatus.empty);
      } else {
        _user = fetched;
        _setState(ViewStatus.success);
      }
    } catch (_) {
      _setError('Impossible de charger le profil.');
    }
  }

  Future<void> refreshCurrentProfile() async {
    _setState(ViewStatus.loading);
    try {
      final fetched = await _repository.getCurrentUserProfile();
      if (fetched == null) {
        _user = null;
        _setState(ViewStatus.empty);
      } else {
        _user = fetched;
        _setState(ViewStatus.success);
      }
    } catch (_) {
      _setError('Impossible de charger le profil.');
    }
  }

  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required int dailyCalorieGoal,
  }) async {
    _setSaving(true);
    try {
      await _repository.updateUserProfile(
        uid: uid,
        fullName: fullName,
        dailyCalorieGoal: dailyCalorieGoal,
        isProfileComplete: true,
      );
      await loadProfile(uid);
    } catch (_) {
      _setError('Impossible de mettre à jour le profil.');
    } finally {
      _setSaving(false);
    }
  }

  Future<void> updateDailyGoal({
    required String uid,
    required int dailyCalorieGoal,
  }) async {
    _setSaving(true);
    try {
      await _repository.updateDailyCalorieGoal(
        uid: uid,
        dailyCalorieGoal: dailyCalorieGoal,
      );
      await loadProfile(uid);
    } catch (_) {
      _setError('Impossible de mettre à jour l’objectif.');
    } finally {
      _setSaving(false);
    }
  }

  void setUser(AppUser? user) {
    _user = user;
    _status = user == null ? ViewStatus.empty : ViewStatus.success;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setSaving(bool value) {
    _isSaving = value;
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
