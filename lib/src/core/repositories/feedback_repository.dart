import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_collections.dart';
import '../models/feedback_model.dart';
import '../utils/app_logger.dart';

class FeedbackRepository {
  FeedbackRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitFeedback({
    required String userId,
    required String subject,
    required String message,
    required int rating,
  }) async {
    try {
      final feedbackData = {
        'userId': userId,
        'subject': subject,
        'message': message,
        'rating': rating,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(FirestoreCollections.feedback).add(feedbackData);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error submitting feedback',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Stream<List<FeedbackModel>> getUserFeedbacks(String userId) {
    return _firestore
        .collection(FirestoreCollections.feedback)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final feedbacks = snapshot.docs
              .map((doc) => FeedbackModel.fromMap(doc.id, doc.data()))
              .toList();
          feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return feedbacks;
        });
  }

  Future<void> updateFeedback(
    String feedbackId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(FirestoreCollections.feedback)
          .doc(feedbackId)
          .update(updates);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error updating feedback',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection(FirestoreCollections.feedback).doc(feedbackId).delete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error deleting feedback',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
