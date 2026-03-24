import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/models/app_user_model.dart';

class SuperAdminService {
  SuperAdminService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<List<AppUser>> getAllUsers({int limit = 200}) async {
    final snapshot = await _usersRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data()))
        .toList();
  }

  Future<AppUser?> getUserById(String uid) async {
    final snapshot = await _usersRef.doc(uid).get();
    if (!snapshot.exists) return null;
    return AppUser.fromMap(snapshot.data()!);
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _usersRef.doc(uid).set(
      {
        'role': role,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }
}
