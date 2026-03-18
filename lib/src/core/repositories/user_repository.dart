import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_collections.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection(FirestoreCollections.users).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error fetching user profile',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, UserModel user) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update(user.toFirestore());
  }

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection(FirestoreCollections.users).doc(user.id).set(user.toFirestore());
  }
}
