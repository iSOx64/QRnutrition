import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/data/models/app_user_model.dart';

class ProfileFirestoreService {
  ProfileFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _usersRef.doc(uid);

  Future<AppUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUserById(user.uid);
  }

  Future<AppUser?> getUserById(String uid) async {
    final snapshot = await _userDoc(uid).get();
    if (!snapshot.exists) return null;
    return AppUser.fromMap(snapshot.data()!);
  }

  Future<List<AppUser>> getAllUsers({int limit = 200}) async {
    final snapshot = await _usersRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    int? dailyCalorieGoal,
    String? photoUrl,
    bool? isProfileComplete,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (fullName != null) data['fullName'] = fullName;
    if (dailyCalorieGoal != null) data['dailyCalorieGoal'] = dailyCalorieGoal;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (isProfileComplete != null) {
      data['isProfileComplete'] = isProfileComplete;
    }
    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateDailyCalorieGoal({
    required String uid,
    required int dailyCalorieGoal,
  }) async {
    await updateUserProfile(
      uid: uid,
      dailyCalorieGoal: dailyCalorieGoal,
    );
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _userDoc(uid).set(
      {
        'role': role,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }
}
