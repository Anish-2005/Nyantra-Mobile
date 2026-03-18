import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/application_model.dart';
import '../models/beneficiary_model.dart';
import '../models/disbursement_model.dart';
import '../models/grievance_model.dart';
import '../models/feedback_model.dart';
import '../models/activity_model.dart';
import '../utils/app_logger.dart';

class DataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const int _whereInLimit = 10;

  static Iterable<List<T>> _chunkList<T>(List<T> values, int size) sync* {
    for (var i = 0; i < values.length; i += size) {
      final end = (i + size) > values.length ? values.length : i + size;
      yield values.sublist(i, end);
    }
  }

  static List<QueryDocumentSnapshot<Map<String, dynamic>>> _dedupeDocsById(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final seenIds = <String>{};
    final uniqueDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final doc in docs) {
      if (seenIds.add(doc.id)) {
        uniqueDocs.add(doc);
      }
    }
    return uniqueDocs;
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _queryCollectionByIds({
    required String collection,
    required String whereInField,
    required List<String> ids,
    String? equalsField,
    Object? equalsValue,
  }) async {
    if (ids.isEmpty) {
      return [];
    }

    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (final chunk in _chunkList(ids, _whereInLimit)) {
      Query<Map<String, dynamic>> query = _firestore
          .collection(collection)
          .where(whereInField, whereIn: chunk);

      if (equalsField != null) {
        query = query.where(equalsField, isEqualTo: equalsValue);
      }

      final snapshot = await query.get();
      docs.addAll(snapshot.docs);
    }

    return _dedupeDocsById(docs);
  }

  // Dashboard Stats - filtered by current user
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'totalApplications': 0,
          'approvedApplications': 0,
          'pendingApplications': 0,
          'totalDisbursed': 0.0,
          'beneficiariesCount': 0,
        };
      }

      // Get user's beneficiaries first
      final beneficiariesQuery = await _firestore
          .collection('beneficiaries')
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      final beneficiaryIds = beneficiariesQuery.docs
          .map((doc) => doc.id)
          .toList();

      // Get applications by user (ownerId) or by beneficiary
      final applicationsQuery1 = await _firestore
          .collection('applications')
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      final applicationsQuery2 = await _queryCollectionByIds(
        collection: 'applications',
        whereInField: 'beneficiaryId',
        ids: beneficiaryIds,
      );

      final allApplicationDocs = [
        ...applicationsQuery1.docs,
        ...applicationsQuery2,
      ];

      // Remove duplicates
      final applicationIds = <String>{};
      final uniqueApplications = allApplicationDocs.where((doc) {
        if (applicationIds.contains(doc.id)) return false;
        applicationIds.add(doc.id);
        return true;
      }).toList();

      // Get disbursements for user's applications (sum completed amounts)
      final applicationIdsList = uniqueApplications
          .map((doc) => doc.id)
          .toList();
      final applications = uniqueApplications;

      // Calculate stats
      final totalApplications = applications.length;
      final approvedApplications = applications
          .where((doc) => doc.data()['status'] == 'approved')
          .length;
      final pendingApplications = applications
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      final totalDisbursed = await _sumCompletedDisbursementsForApplicationIds(
        applicationIdsList,
      );

      final beneficiariesCount = beneficiariesQuery.docs.length;

      return {
        'totalApplications': totalApplications,
        'approvedApplications': approvedApplications,
        'pendingApplications': pendingApplications,
        'totalDisbursed': totalDisbursed,
        'beneficiariesCount': beneficiariesCount,
      };
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error fetching dashboard stats',
        error: error,
        stackTrace: stackTrace,
      );
      return {
        'totalApplications': 0,
        'approvedApplications': 0,
        'pendingApplications': 0,
        'totalDisbursed': 0.0,
        'beneficiariesCount': 0,
      };
    }
  }

  // Recent Activities - filtered by current user
  static Future<List<ActivityModel>> getRecentActivities({
    int limit = 10,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final activities = <ActivityModel>[];

      // Get user's beneficiaries first
      final beneficiariesQuery = await _firestore
          .collection('beneficiaries')
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      final beneficiaryIds = beneficiariesQuery.docs
          .map((doc) => doc.id)
          .toList();

      // Get recent applications
      final applicationsQuery1 = await _firestore
          .collection('applications')
          .where('ownerId', isEqualTo: currentUser.uid)
          .orderBy('applicationDate', descending: true)
          .limit(limit)
          .get();

      final applicationsQuery2 = await _queryCollectionByIds(
        collection: 'applications',
        whereInField: 'beneficiaryId',
        ids: beneficiaryIds,
      );

      final allApplicationDocs = [
        ...applicationsQuery1.docs,
        ...applicationsQuery2,
      ];

      // Remove duplicates and sort by date
      final applicationIds = <String>{};
      final uniqueApplications =
          allApplicationDocs.where((doc) {
            if (applicationIds.contains(doc.id)) return false;
            applicationIds.add(doc.id);
            return true;
          }).toList()..sort(
            (a, b) => (b.data()['applicationDate'] as Timestamp).compareTo(
              a.data()['applicationDate'] as Timestamp,
            ),
          );

      // Convert to activities
      for (final doc in uniqueApplications.take(limit)) {
        final data = doc.data();
        final status = data['status'] as String?;
        final applicantName = data['applicantName'] as String? ?? 'Unknown';
        final applicationDate = (data['applicationDate'] as Timestamp).toDate();

        ActivityType activityType;
        String title;
        String description;

        switch (status) {
          case 'approved':
            activityType = ActivityType.applicationApproved;
            title = 'Application Approved';
            description = 'Application by $applicantName was approved';
            break;
          case 'rejected':
            activityType = ActivityType.applicationRejected;
            title = 'Application Rejected';
            description = 'Application by $applicantName was rejected';
            break;
          default:
            activityType = ActivityType.applicationSubmitted;
            title = 'Application Submitted';
            description = 'New application submitted by $applicantName';
        }

        activities.add(
          ActivityModel(
            id: 'app_${doc.id}',
            type: activityType,
            title: title,
            description: description,
            timestamp: applicationDate,
            relatedId: doc.id,
          ),
        );
      }

      // Get recent grievances
      final grievancesQuery = await _firestore
          .collection('grievances')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdDate', descending: true)
          .limit(limit)
          .get();

      for (final doc in grievancesQuery.docs.take(limit - activities.length)) {
        final data = doc.data();
        final status = data['status'] as String?;
        final titleText = data['title'] as String? ?? 'Grievance';
        final createdDate =
            (data['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now();

        ActivityType activityType;
        String title;
        String description;

        if (status == 'resolved' || status == 'closed') {
          activityType = ActivityType.grievanceResolved;
          title = 'Grievance Resolved';
          description = '$titleText has been resolved';
        } else {
          activityType = ActivityType.grievanceFiled;
          title = 'Grievance Filed';
          description = 'New grievance: $titleText';
        }

        activities.add(
          ActivityModel(
            id: 'grievance_${doc.id}',
            type: activityType,
            title: title,
            description: description,
            timestamp: createdDate,
            relatedId: doc.id,
          ),
        );
      }

      // Get recent disbursements
      final applicationIdsList = uniqueApplications
          .map((doc) => doc.id)
          .toList();
      if (applicationIdsList.isNotEmpty) {
        final disbursementDocs = await _queryCollectionByIds(
          collection: 'disbursements',
          whereInField: 'applicationId',
          ids: applicationIdsList,
          equalsField: 'status',
          equalsValue: 'completed',
        );
        final remainingSlots =
            (limit - activities.length).clamp(0, limit) as int;
        final disbursementsQuery = disbursementDocs
            .take(remainingSlots)
            .toList();

        for (final doc in disbursementsQuery) {
          final data = doc.data();
          final amount = (data['reliefAmount'] as num?)?.toDouble() ?? 0.0;
          final disbursementDate =
              (data['disbursementDate'] as Timestamp?)?.toDate() ??
              DateTime.now();

          activities.add(
            ActivityModel(
              id: 'disbursement_${doc.id}',
              type: ActivityType.disbursementCompleted,
              title: 'Disbursement Completed',
              description:
                  'Rs. ${amount.toStringAsFixed(2)} disbursed successfully',
              timestamp: disbursementDate,
              relatedId: doc.id,
            ),
          );
        }
      }

      // Sort all activities by timestamp (most recent first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activities.take(limit).toList();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error fetching recent activities',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Applications - filtered by current user (ownerId) or user's beneficiaries
  static Stream<List<ApplicationModel>> getApplications() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    // First get user's beneficiaries to get beneficiary IDs
    return _firestore
        .collection('beneficiaries')
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((beneficiariesSnapshot) async {
          final beneficiaryIds = beneficiariesSnapshot.docs
              .map((doc) => doc.id)
              .toList();

          // Get applications where ownerId is current user
          final applicationsQuery1 = await _firestore
              .collection('applications')
              .where('ownerId', isEqualTo: currentUser.uid)
              .get();

          // Get applications where beneficiaryId is in user's beneficiaries
          final applicationsQuery2 = await _queryCollectionByIds(
            collection: 'applications',
            whereInField: 'beneficiaryId',
            ids: beneficiaryIds,
          );

          final allApplicationDocs = [
            ...applicationsQuery1.docs,
            ...applicationsQuery2,
          ];

          // Remove duplicates
          final applicationIds = <String>{};
          final uniqueApplications = allApplicationDocs.where((doc) {
            if (applicationIds.contains(doc.id)) return false;
            applicationIds.add(doc.id);
            return true;
          }).toList();

          return uniqueApplications.map((doc) {
            return ApplicationModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  static Future<void> createApplication(ApplicationModel application) async {
    await _firestore
        .collection('applications')
        .doc(application.id)
        .set(application.toFirestore());
  }

  static Future<void> updateApplication(
    String id,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('applications').doc(id).update(data);
  }

  static Future<void> deleteApplication(String id) async {
    await _firestore.collection('applications').doc(id).delete();
  }

  // Beneficiaries - filtered by current user
  static Stream<List<BeneficiaryModel>> getBeneficiaries() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('beneficiaries')
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BeneficiaryModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  static Future<void> createBeneficiary(BeneficiaryModel beneficiary) async {
    await _firestore
        .collection('beneficiaries')
        .doc(beneficiary.id)
        .set(beneficiary.toFirestore());
  }

  static Future<void> updateBeneficiary(
    String id,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('beneficiaries').doc(id).update(data);
  }

  // Disbursements - filtered by current user's applications or user's beneficiaries
  static Stream<List<DisbursementModel>> getDisbursements() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    // First get user's beneficiaries and applications
    return _firestore
        .collection('beneficiaries')
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((beneficiariesSnapshot) async {
          final beneficiaryIds = beneficiariesSnapshot.docs
              .map((doc) => doc.id)
              .toList();

          // Get applications where ownerId is current user
          final applicationsQuery1 = await _firestore
              .collection('applications')
              .where('ownerId', isEqualTo: currentUser.uid)
              .get();

          // Get applications where beneficiaryId is in user's beneficiaries
          final applicationsQuery2 = await _queryCollectionByIds(
            collection: 'applications',
            whereInField: 'beneficiaryId',
            ids: beneficiaryIds,
          );

          final allApplicationDocs = [
            ...applicationsQuery1.docs,
            ...applicationsQuery2,
          ];

          // Remove duplicates
          final applicationIds = <String>{};
          final uniqueApplicationIds = allApplicationDocs
              .where((doc) {
                if (applicationIds.contains(doc.id)) return false;
                applicationIds.add(doc.id);
                return true;
              })
              .map((doc) => doc.id)
              .toList();

          if (uniqueApplicationIds.isEmpty && beneficiaryIds.isEmpty) {
            return [];
          }

          List<DisbursementModel> allDisbursements = [];

          // Get disbursements for applications
          if (uniqueApplicationIds.isNotEmpty) {
            final disbursementsSnapshot = await _queryCollectionByIds(
              collection: 'disbursements',
              whereInField: 'applicationId',
              ids: uniqueApplicationIds,
            );

            allDisbursements.addAll(
              disbursementsSnapshot.map((doc) {
                return DisbursementModel.fromFirestore(doc.data(), doc.id);
              }).toList(),
            );
          }

          // Get disbursements directly for beneficiaries
          if (beneficiaryIds.isNotEmpty) {
            final beneficiaryDisbursementsSnapshot = await _queryCollectionByIds(
              collection: 'disbursements',
              whereInField: 'beneficiaryId',
              ids: beneficiaryIds,
            );

            allDisbursements.addAll(
              beneficiaryDisbursementsSnapshot.map((doc) {
                return DisbursementModel.fromFirestore(doc.data(), doc.id);
              }).toList(),
            );
          }

          // Remove duplicates based on ID
          final disbursementIds = <String>{};
          final uniqueDisbursements = allDisbursements.where((disbursement) {
            if (disbursementIds.contains(disbursement.id)) return false;
            disbursementIds.add(disbursement.id);
            return true;
          }).toList();

          return uniqueDisbursements;
        });
  }

  static Future<void> createDisbursement(DisbursementModel disbursement) async {
    await _firestore
        .collection('disbursements')
        .add(disbursement.toFirestore());
  }

  static Future<void> updateDisbursement(
    String id,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('disbursements').doc(id).update(data);
  }

  // Sum completed disbursements for a list of application IDs. Handles Firestore
  // `whereIn` 10-item limit by querying in batches.
  static Future<double> _sumCompletedDisbursementsForApplicationIds(
    List<String> applicationIds,
  ) async {
    if (applicationIds.isEmpty) return 0.0;

    double total = 0.0;
    for (var i = 0; i < applicationIds.length; i += _whereInLimit) {
      final end = (i + _whereInLimit) < applicationIds.length
          ? i + _whereInLimit
          : applicationIds.length;
      final chunk = applicationIds.sublist(i, end);

      final snapshot = await _firestore
          .collection('disbursements')
          .where('applicationId', whereIn: chunk)
          .where('status', isEqualTo: 'completed')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Support both 'reliefAmount' and 'amount' naming
        final num? amt =
            (data['reliefAmount'] as num?) ?? (data['amount'] as num?);
        if (amt != null) total += amt.toDouble();
      }
    }

    return total;
  }

  // Grievances - proper implementation with user filtering and beneficiary filtering
  static Stream<List<GrievanceModel>> getGrievances() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final controller = StreamController<List<GrievanceModel>>();
    final allGrievances = <String, GrievanceModel>{};
    final unsubscribers = <void Function()>[];

    // Query for grievances by userId
    final userQuery = _firestore
        .collection('grievances')
        .where('userId', isEqualTo: currentUser.uid);

    final userUnsub = userQuery.snapshots().listen((snapshot) {
      // Add/update user grievances
      for (final doc in snapshot.docs) {
        final grievance = GrievanceModel.fromFirestore(doc.data(), doc.id);
        allGrievances[grievance.id] = grievance;
      }

      // Remove grievances that no longer match (in case of updates)
      final currentIds = snapshot.docs.map((doc) => doc.id).toSet();
      allGrievances.removeWhere(
        (id, grievance) =>
            grievance.userId == currentUser.uid && !currentIds.contains(id),
      );

      _emitSortedGrievances(controller, allGrievances);
    });

    unsubscribers.add(userUnsub.cancel);

    // Query for beneficiaries owned by user
    final beneficiariesQuery = _firestore
        .collection('beneficiaries')
        .where('ownerId', isEqualTo: currentUser.uid);

    final beneficiariesUnsub = beneficiariesQuery.snapshots().listen((
      beneficiariesSnapshot,
    ) {
      final beneficiaryIds = beneficiariesSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      // Clean up previous beneficiary grievance listeners
      while (unsubscribers.length > 1) {
        unsubscribers.removeLast()();
      }

      // Create listeners for each beneficiary's grievances
      for (final beneficiaryId in beneficiaryIds) {
        final beneficiaryQuery = _firestore
            .collection('grievances')
            .where('beneficiaryId', isEqualTo: beneficiaryId);

        final unsub = beneficiaryQuery.snapshots().listen((snapshot) {
          // Add/update beneficiary grievances
          for (final doc in snapshot.docs) {
            final grievance = GrievanceModel.fromFirestore(doc.data(), doc.id);
            allGrievances[grievance.id] = grievance;
          }

          // Remove grievances that no longer match
          final currentIds = snapshot.docs.map((doc) => doc.id).toSet();
          allGrievances.removeWhere(
            (id, grievance) =>
                grievance.beneficiaryId == beneficiaryId &&
                !currentIds.contains(id),
          );

          _emitSortedGrievances(controller, allGrievances);
        });

        unsubscribers.add(unsub.cancel);
      }
    });

    unsubscribers.add(beneficiariesUnsub.cancel);

    controller.onCancel = () {
      for (final unsub in unsubscribers) {
        unsub();
      }
      controller.close();
    };

    return controller.stream;
  }

  static void _emitSortedGrievances(
    StreamController<List<GrievanceModel>> controller,
    Map<String, GrievanceModel> grievances,
  ) {
    final sortedGrievances = grievances.values.toList()
      ..sort((a, b) {
        final aDate = a.createdDate;
        final bDate = b.createdDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    controller.add(sortedGrievances);
  }

  static Future<void> createGrievance(GrievanceModel grievance) async {
    await _firestore
        .collection('grievances')
        .doc(grievance.id)
        .set(grievance.toFirestore());
  }

  // Append a communication message to a grievance's `communication` array
  static Future<void> appendGrievanceMessage(
    String grievanceId,
    Map<String, dynamic> message,
  ) async {
    await _firestore.collection('grievances').doc(grievanceId).update({
      'communication': FieldValue.arrayUnion([message]),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // User Profile
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
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

  static Future<void> updateUserProfile(String userId, UserModel user) async {
    await _firestore.collection('users').doc(userId).update(user.toFirestore());
  }

  static Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  // Feedback Methods
  static Future<void> submitFeedback({
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

      await _firestore.collection('feedback').add(feedbackData);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error submitting feedback',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Stream<List<FeedbackModel>> getUserFeedbacks(String userId) {
    return _firestore
        .collection('feedback')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final feedbacks = snapshot.docs.map((doc) {
            return FeedbackModel.fromMap(doc.id, doc.data());
          }).toList();
          // Sort client-side to avoid needing composite index
          feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return feedbacks;
        });
  }

  static Future<void> updateFeedback(
    String feedbackId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('feedback').doc(feedbackId).update(updates);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error updating feedback',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).delete();
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

