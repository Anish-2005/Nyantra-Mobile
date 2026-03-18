import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import '../models/feedback_model.dart';
import '../utils/app_logger.dart';

class FeedbackRepository {
  FeedbackRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _alternateFeedbackCollection = 'feedbacks';

  List<String> get _feedbackCollectionNames {
    if (FirestoreCollections.feedback == _alternateFeedbackCollection) {
      return const [FirestoreCollections.feedback];
    }
    return const [FirestoreCollections.feedback, _alternateFeedbackCollection];
  }

  bool _isPermissionDenied(Object error) =>
      error is FirebaseException && error.code == 'permission-denied';

  bool _isRetryableCollectionError(Object error) =>
      error is FirebaseException &&
      (error.code == 'permission-denied' || error.code == 'not-found');

  List<CollectionReference<Map<String, dynamic>>> _topLevelCollections() {
    return [
      for (final collectionName in _feedbackCollectionNames)
        _firestore.collection(collectionName),
    ];
  }

  List<CollectionReference<Map<String, dynamic>>> _userScopedCollections(
    String userId,
  ) {
    return [
      for (final collectionName in _feedbackCollectionNames)
        _firestore
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(collectionName),
    ];
  }

  List<DocumentReference<Map<String, dynamic>>> _feedbackDocRefs(String feedbackId) {
    final refs = <DocumentReference<Map<String, dynamic>>>[];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      refs.addAll(
        _userScopedCollections(currentUserId).map(
          (collection) => collection.doc(feedbackId),
        ),
      );
    }
    refs.addAll(
      _topLevelCollections().map((collection) => collection.doc(feedbackId)),
    );
    return refs;
  }

  Future<void> submitFeedback({
    required String userId,
    required String subject,
    required String message,
    required int rating,
  }) async {
    try {
      final feedbackData = {
        'userId': userId,
        // Keep ownerId for compatibility with rules that scope by ownerId.
        'ownerId': userId,
        'subject': subject,
        'message': message,
        'rating': rating,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      Object? lastError;
      StackTrace? lastStackTrace;
      final collections = [
        ..._userScopedCollections(userId),
        ..._topLevelCollections(),
      ];

      for (final collection in collections) {
        try {
          await collection.add(feedbackData);
          return;
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
          if (_isRetryableCollectionError(error)) {
            continue;
          }
          rethrow;
        }
      }

      if (lastError != null) {
        Error.throwWithStackTrace(lastError, lastStackTrace ?? StackTrace.current);
      }
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
    return _getUserFeedbacksStream(userId).asBroadcastStream();
  }

  Stream<List<FeedbackModel>> _getUserFeedbacksStream(String userId) async* {
    final attempts = <({
      Stream<QuerySnapshot<Map<String, dynamic>>> Function() streamFactory,
    })>[
      for (final collection in _userScopedCollections(userId))
        (
          streamFactory: () => collection.snapshots(),
        ),
      for (final collection in _topLevelCollections()) ...[
        (
          streamFactory: () => collection.where('userId', isEqualTo: userId).snapshots(),
        ),
        (
          streamFactory: () => collection.where('ownerId', isEqualTo: userId).snapshots(),
        ),
      ],
    ];

    List<FeedbackModel> mapFeedbacks(QuerySnapshot<Map<String, dynamic>> snapshot) {
      final feedbacks = snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.id, doc.data()))
          .toList();
      feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return feedbacks;
    }

    for (var i = 0; i < attempts.length; i++) {
      final attempt = attempts[i];
      try {
        await for (final snapshot in attempt.streamFactory()) {
          yield mapFeedbacks(snapshot);
        }
        return;
      } on FirebaseException catch (error) {
        if (_isPermissionDenied(error)) {
          final hasNextAttempt = i + 1 < attempts.length;
          if (hasNextAttempt) {
            continue;
          }

          AppLogger.warning(
            'Permission denied while loading feedback. Returning empty list.',
          );
          yield <FeedbackModel>[];
          return;
        }
        rethrow;
      }
    }
  }

  Future<void> updateFeedback(
    String feedbackId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      Object? lastError;
      StackTrace? lastStackTrace;

      final docRefs = _feedbackDocRefs(feedbackId);
      for (final docRef in docRefs) {
        try {
          await docRef.update(updates);
          return;
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
          if (_isRetryableCollectionError(error)) {
            continue;
          }
          rethrow;
        }
      }

      if (lastError != null) {
        Error.throwWithStackTrace(lastError, lastStackTrace ?? StackTrace.current);
      }
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
      Object? lastError;
      StackTrace? lastStackTrace;

      final docRefs = _feedbackDocRefs(feedbackId);
      for (final docRef in docRefs) {
        try {
          await docRef.delete();
          return;
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
          if (_isRetryableCollectionError(error)) {
            continue;
          }
          rethrow;
        }
      }

      if (lastError != null) {
        Error.throwWithStackTrace(lastError, lastStackTrace ?? StackTrace.current);
      }
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
