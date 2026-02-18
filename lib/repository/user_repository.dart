import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collectionName).doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_collectionName).doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection(_collectionName).doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<bool> userExists(String userId) async {
    final doc = await _firestore.collection(_collectionName).doc(userId).get();
    return doc.exists;
  }
}
