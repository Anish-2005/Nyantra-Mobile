import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import '../models/activity_model.dart';
import '../utils/app_logger.dart';
import '../utils/firestore_query_helper.dart';

class DashboardRepository {
  DashboardRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Map<String, Object> _emptyDashboardStats = {
    'totalApplications': 0,
    'approvedApplications': 0,
    'pendingApplications': 0,
    'totalDisbursed': 0.0,
    'beneficiariesCount': 0,
  };

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Map<String, dynamic>.from(_emptyDashboardStats);
      }

      final beneficiariesQuery = await _firestore
          .collection(FirestoreCollections.beneficiaries)
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      final beneficiaryIds = beneficiariesQuery.docs.map((doc) => doc.id).toList();

      final applicationsQuery1 = await _firestore
          .collection(FirestoreCollections.applications)
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      final applicationsQuery2 = await FirestoreQueryHelper.queryByWhereIn(
        firestore: _firestore,
        collection: FirestoreCollections.applications,
        field: 'beneficiaryId',
        values: beneficiaryIds,
      );

      final uniqueApplications = FirestoreQueryHelper.dedupeDocsById([
        ...applicationsQuery1.docs,
        ...applicationsQuery2,
      ]);

      final totalApplications = uniqueApplications.length;
      final approvedApplications = uniqueApplications
          .where((doc) => doc.data()['status'] == 'approved')
          .length;
      final pendingApplications = uniqueApplications
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      final totalDisbursed = await _sumCompletedDisbursementsForApplicationIds(
        uniqueApplications.map((doc) => doc.id).toList(),
      );

      return {
        'totalApplications': totalApplications,
        'approvedApplications': approvedApplications,
        'pendingApplications': pendingApplications,
        'totalDisbursed': totalDisbursed,
        'beneficiariesCount': beneficiariesQuery.docs.length,
      };
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error fetching dashboard stats',
        error: error,
        stackTrace: stackTrace,
      );
      return Map<String, dynamic>.from(_emptyDashboardStats);
    }
  }

  Future<List<ActivityModel>> getRecentActivities({int limit = 10}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final activities = <ActivityModel>[];

      final beneficiariesQuery = await _firestore
          .collection(FirestoreCollections.beneficiaries)
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();
      final beneficiaryIds = beneficiariesQuery.docs.map((doc) => doc.id).toList();

      final applicationsQuery1 = await _firestore
          .collection(FirestoreCollections.applications)
          .where('ownerId', isEqualTo: currentUser.uid)
          .orderBy('applicationDate', descending: true)
          .limit(limit)
          .get();

      final applicationsQuery2 = await FirestoreQueryHelper.queryByWhereIn(
        firestore: _firestore,
        collection: FirestoreCollections.applications,
        field: 'beneficiaryId',
        values: beneficiaryIds,
      );

      final uniqueApplications = FirestoreQueryHelper.dedupeDocsById([
        ...applicationsQuery1.docs,
        ...applicationsQuery2,
      ])
        ..sort(
          (a, b) =>
              (b.data()['applicationDate'] as Timestamp).compareTo(
                a.data()['applicationDate'] as Timestamp,
              ),
        );

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

      final grievancesQuery = await _firestore
          .collection(FirestoreCollections.grievances)
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

        final isResolved = status == 'resolved' || status == 'closed';
        activities.add(
          ActivityModel(
            id: 'grievance_${doc.id}',
            type: isResolved
                ? ActivityType.grievanceResolved
                : ActivityType.grievanceFiled,
            title: isResolved ? 'Grievance Resolved' : 'Grievance Filed',
            description: isResolved
                ? '$titleText has been resolved'
                : 'New grievance: $titleText',
            timestamp: createdDate,
            relatedId: doc.id,
          ),
        );
      }

      final applicationIds = uniqueApplications.map((doc) => doc.id).toList();
      if (applicationIds.isNotEmpty) {
        final disbursementDocs = await FirestoreQueryHelper.queryByWhereIn(
          firestore: _firestore,
          collection: FirestoreCollections.disbursements,
          field: 'applicationId',
          values: applicationIds,
          equalsField: 'status',
          equalsValue: 'completed',
        );

        final remainingSlots =
            (limit - activities.length).clamp(0, limit) as int;
        for (final doc in disbursementDocs.take(remainingSlots)) {
          final data = doc.data();
          final amount = (data['reliefAmount'] as num?)?.toDouble() ?? 0.0;
          final disbursementDate =
              (data['disbursementDate'] as Timestamp?)?.toDate() ?? DateTime.now();

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

  Future<double> _sumCompletedDisbursementsForApplicationIds(
    List<String> applicationIds,
  ) async {
    if (applicationIds.isEmpty) return 0.0;

    double total = 0.0;
    for (final chunk in FirestoreQueryHelper.chunkList(applicationIds)) {
      final snapshot = await _firestore
          .collection(FirestoreCollections.disbursements)
          .where('applicationId', whereIn: chunk)
          .where('status', isEqualTo: 'completed')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount =
            (data['reliefAmount'] as num?) ?? (data['amount'] as num?);
        if (amount != null) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }
}
