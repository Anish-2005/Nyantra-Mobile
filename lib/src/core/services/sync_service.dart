// ignore_for_file: directives_ordering

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';
import '../models/application_model.dart';
import '../models/beneficiary_model.dart';
import '../models/disbursement_model.dart';
import '../models/grievance_model.dart';
import '../models/feedback_model.dart';
import '../models/report_model.dart';
import '../constants/firestore_collections.dart';
import '../providers/sync_status_provider.dart';
import '../utils/app_logger.dart';
import '../utils/firestore_query_helper.dart';

class SyncService {
  static SyncService? _instance;
  static DatabaseHelper? _dbHelper;
  static Connectivity? _connectivity;
  static SyncStatusProvider? _syncStatusProvider;

  factory SyncService({SyncStatusProvider? syncStatusProvider}) {
    _instance ??= SyncService._internal();
    if (syncStatusProvider != null) {
      _syncStatusProvider = syncStatusProvider;
    }
    return _instance!;
  }

  static void setSyncStatusProvider(SyncStatusProvider provider) {
    _syncStatusProvider = provider;
  }

  SyncService._internal() {
    _dbHelper = DatabaseHelper();
    _connectivity = Connectivity();
  }

  Future<bool> isOnline() async {
    var connectivityResults = await _connectivity!.checkConnectivity();
    return connectivityResults.isNotEmpty &&
        connectivityResults.any((result) => result != ConnectivityResult.none);
  }

  // Sync data from Firestore to local DB
  Future<void> syncFromFirestore() async {
    if (kIsWeb) return;
    if (!await isOnline()) return;

    final currentUser = FirebaseService.auth.currentUser;
    if (currentUser == null) return;
    try {
      // Sync current user's profile
      final userDoc = await FirebaseService.firestore
          .collection(FirestoreCollections.users)
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        final user = UserModel.fromFirestore(userDoc.data()!, userDoc.id);
        await _dbHelper!.insertUser(user);
      }

      // Sync user's beneficiaries
      final beneficiariesSnapshot = await FirebaseService.firestore
          .collection(FirestoreCollections.beneficiaries)
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();
      for (var doc in beneficiariesSnapshot.docs) {
        final beneficiary = BeneficiaryModel.fromFirestore(doc.data(), doc.id);
        await _dbHelper!.insertBeneficiary(beneficiary);
      }

      final beneficiaryIds =
          beneficiariesSnapshot.docs.map((doc) => doc.id).toList();

      // Sync applications owned by user or related to user's beneficiaries
      final applicationsQuery1 = await FirebaseService.firestore
          .collection(FirestoreCollections.applications)
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      final applications = <QueryDocumentSnapshot<Map<String, dynamic>>>[
        ...applicationsQuery1.docs,
      ];

      if (beneficiaryIds.isNotEmpty) {
        final applicationsQuery2 = await FirestoreQueryHelper.queryByWhereIn(
          firestore: FirebaseService.firestore,
          collection: FirestoreCollections.applications,
          field: 'beneficiaryId',
          values: beneficiaryIds,
        );
        applications.addAll(applicationsQuery2);
      }

      final uniqueApplications = FirestoreQueryHelper.dedupeDocsById(
        applications,
      );
      final applicationIds = uniqueApplications.map((doc) => doc.id).toList();

      for (var doc in uniqueApplications) {
        final application = ApplicationModel.fromFirestore(doc.data(), doc.id);
        await _dbHelper!.insertApplication(application);
      }

      // Sync disbursements for user's applications
      if (applicationIds.isNotEmpty) {
        final disbursementsSnapshot = await FirestoreQueryHelper.queryByWhereIn(
          firestore: FirebaseService.firestore,
          collection: FirestoreCollections.disbursements,
          field: 'applicationId',
          values: applicationIds,
        );
        for (var doc in disbursementsSnapshot) {
          final disbursement = DisbursementModel.fromFirestore(
            doc.data(),
            doc.id,
          );
          await _dbHelper!.insertDisbursement(disbursement);
        }
      }

      // Also sync disbursements directly for user's beneficiaries
      if (beneficiaryIds.isNotEmpty) {
        final beneficiaryDisbursementsSnapshot =
            await FirestoreQueryHelper.queryByWhereIn(
          firestore: FirebaseService.firestore,
          collection: FirestoreCollections.disbursements,
          field: 'beneficiaryId',
          values: beneficiaryIds,
        );
        for (var doc in beneficiaryDisbursementsSnapshot) {
          final disbursement = DisbursementModel.fromFirestore(
            doc.data(),
            doc.id,
          );
          await _dbHelper!.insertDisbursement(disbursement);
        }
      }

      // Sync grievances created by user or related to user's beneficiaries
      final grievancesQuery1 = await FirebaseService.firestore
          .collection(FirestoreCollections.grievances)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final grievances = <QueryDocumentSnapshot<Map<String, dynamic>>>[
        ...grievancesQuery1.docs,
      ];

      if (beneficiaryIds.isNotEmpty) {
        final grievancesQuery2 = await FirestoreQueryHelper.queryByWhereIn(
          firestore: FirebaseService.firestore,
          collection: FirestoreCollections.grievances,
          field: 'beneficiaryId',
          values: beneficiaryIds,
        );
        grievances.addAll(grievancesQuery2);
      }

      final uniqueGrievances = FirestoreQueryHelper.dedupeDocsById(grievances);

      for (var doc in uniqueGrievances) {
        final grievance = GrievanceModel.fromFirestore(doc.data(), doc.id);
        await _dbHelper!.insertGrievance(grievance);
      }

      // Sync user's feedback
      final feedbackSnapshot = await FirebaseService.firestore
          .collection(FirestoreCollections.feedback)
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      for (var doc in feedbackSnapshot.docs) {
        final feedback = FeedbackModel.fromMap(doc.id, doc.data());
        await _dbHelper!.insertFeedback(feedback);
      }

      // Sync reports
      AppLogger.info('SyncService: syncFromFirestore - Syncing reports');
      final reportsSnapshot = await FirebaseService.firestore
          .collection(FirestoreCollections.reports)
          .get();
      AppLogger.info(
        'SyncService: syncFromFirestore - Found ${reportsSnapshot.docs.length} reports in Firestore',
      );

      // If no reports exist in Firestore, create some sample reports
      if (reportsSnapshot.docs.isEmpty) {
        AppLogger.info(
          'SyncService: No reports found in Firestore, creating sample reports',
        );

        // Check if sample reports already exist in local DB to avoid duplicates
        final localReports = await _dbHelper!.getReports();
        final hasSampleReports = localReports.any(
          (report) =>
              report.name.contains('Monthly Applications') ||
              report.name.contains('Beneficiary Disbursement') ||
              report.name.contains('Grievance Resolution') ||
              report.name.contains('User Feedback') ||
              report.name.contains('System Performance'),
        );

        if (!hasSampleReports) {
          await _createSampleReports();
        }

        // Re-fetch after creating samples (or if they already exist)
        final updatedReportsSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.reports)
            .get();
        for (var doc in updatedReportsSnapshot.docs) {
          final report = Report.fromJson(doc.data(), doc.id);
          await _dbHelper!.insertReport(report);
          AppLogger.info(
            'SyncService: syncFromFirestore - Synced sample report: ${report.name}',
          );
        }
      } else {
        // Sync existing reports from Firestore, but avoid duplicates
        final localReports = await _dbHelper!.getReports();
        final localReportIds = localReports.map((r) => r.id).toSet();

        for (var doc in reportsSnapshot.docs) {
          // Only sync if this report doesn't already exist locally
          if (!localReportIds.contains(doc.id)) {
            final report = Report.fromJson(doc.data(), doc.id);
            await _dbHelper!.insertReport(report);
            AppLogger.info(
              'SyncService: syncFromFirestore - Synced new report: ${report.name}',
            );
          }
        }
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error syncing from Firestore',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // Create or update beneficiary with sync tracking
  Future<void> createOrUpdateBeneficiary(BeneficiaryModel beneficiary) async {
    await _dbHelper!.upsertWithSync(
      'beneficiaries',
      beneficiary.toJson(),
      markForSync: true,
    );
    await _dbHelper!.insertBeneficiary(beneficiary); // Ensure it's in the DB
    _syncStatusProvider?.incrementPendingSync();

    // Try to sync immediately if online
    if (await isOnline()) {
      try {
        await syncToFirestore();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error syncing beneficiary immediately',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  // Create or update application with sync tracking
  Future<void> createOrUpdateApplication(ApplicationModel application) async {
    await _dbHelper!.upsertWithSync(
      'applications',
      application.toJson(),
      markForSync: true,
    );
    await _dbHelper!.insertApplication(application); // Ensure it's in the DB
    _syncStatusProvider?.incrementPendingSync();

    // Try to sync immediately if online
    if (await isOnline()) {
      try {
        await syncToFirestore();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error syncing application immediately',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  // Create or update grievance with sync tracking
  Future<void> createOrUpdateGrievance(GrievanceModel grievance) async {
    await _dbHelper!.upsertWithSync(
      'grievances',
      grievance.toJson(),
      markForSync: true,
    );
    await _dbHelper!.insertGrievance(grievance); // Ensure it's in the DB
    _syncStatusProvider?.incrementPendingSync();

    // Try to sync immediately if online
    if (await isOnline()) {
      try {
        await syncToFirestore();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error syncing grievance immediately',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  // Create or update feedback with sync tracking
  Future<void> createOrUpdateFeedback(FeedbackModel feedback) async {
    await _dbHelper!.upsertWithSync(
      'feedback',
      feedback.toMap(),
      markForSync: true,
    );
    await _dbHelper!.insertFeedback(feedback); // Ensure it's in the DB
    _syncStatusProvider?.incrementPendingSync();

    // Try to sync immediately if online
    if (await isOnline()) {
      try {
        await syncToFirestore();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error syncing feedback immediately',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  // Sync local changes to Firestore
  Future<void> syncToFirestore() async {
    if (!await isOnline()) return;

    _syncStatusProvider?.setStatus(SyncStatus.syncing);

    try {
      final currentUser = FirebaseService.auth.currentUser;
      if (currentUser == null) {
        _syncStatusProvider?.setStatus(
          SyncStatus.error,
          error: 'User not authenticated',
        );
        return;
      }

      // Get pending sync count
      final unsyncedBeneficiaries = await _dbHelper!.getRecordsNeedingSync(
        'beneficiaries',
      );
      final unsyncedApplications = await _dbHelper!.getRecordsNeedingSync(
        'applications',
      );
      final unsyncedGrievances = await _dbHelper!.getRecordsNeedingSync(
        'grievances',
      );
      final unsyncedFeedback = await _dbHelper!.getRecordsNeedingSync(
        'feedback',
      );

      final totalPending = unsyncedBeneficiaries.length +
          unsyncedApplications.length +
          unsyncedGrievances.length +
          unsyncedFeedback.length;

      _syncStatusProvider?.setPendingSyncCount(totalPending);

      // Sync beneficiaries that need syncing
      for (var beneficiaryData in unsyncedBeneficiaries) {
        try {
          final beneficiary = BeneficiaryModel.fromJson(beneficiaryData);
          if (beneficiary.ownerId == currentUser.uid) {
            await FirebaseService.firestore
                .collection(FirestoreCollections.beneficiaries)
                .doc(beneficiary.id)
                .set(beneficiary.toJson());
            await _dbHelper!.markAsSynced('beneficiaries', beneficiary.id);
            _syncStatusProvider?.decrementPendingSync();
            AppLogger.info(
              'SyncService: syncToFirestore - Synced beneficiary: ${beneficiary.name}',
            );
          }
        } catch (error, stackTrace) {
          AppLogger.error(
            'Error syncing beneficiary ${beneficiaryData['id']}',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      // Sync applications that need syncing
      for (var applicationData in unsyncedApplications) {
        try {
          final application = ApplicationModel.fromJson(applicationData);
          if (application.ownerId == currentUser.uid) {
            await FirebaseService.firestore
                .collection(FirestoreCollections.applications)
                .doc(application.id)
                .set(application.toJson());
            await _dbHelper!.markAsSynced('applications', application.id);
            _syncStatusProvider?.decrementPendingSync();
            AppLogger.info(
              'SyncService: syncToFirestore - Synced application: ${application.id}',
            );
          }
        } catch (error, stackTrace) {
          AppLogger.error(
            'Error syncing application ${applicationData['id']}',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      // Sync grievances that need syncing
      for (var grievanceData in unsyncedGrievances) {
        try {
          final grievance = GrievanceModel.fromJson(grievanceData);
          if (grievance.userId == currentUser.uid) {
            await FirebaseService.firestore
                .collection(FirestoreCollections.grievances)
                .doc(grievance.id)
                .set(grievance.toJson());
            await _dbHelper!.markAsSynced('grievances', grievance.id);
            _syncStatusProvider?.decrementPendingSync();
            AppLogger.info(
              'SyncService: syncToFirestore - Synced grievance: ${grievance.title}',
            );
          }
        } catch (error, stackTrace) {
          AppLogger.error(
            'Error syncing grievance ${grievanceData['id']}',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      // Sync feedback that need syncing
      for (var feedbackData in unsyncedFeedback) {
        try {
          final feedback = FeedbackModel.fromMap(
            feedbackData['id'],
            feedbackData,
          );
          if (feedback.userId == currentUser.uid) {
            await FirebaseService.firestore
                .collection(FirestoreCollections.feedback)
                .doc(feedback.id)
                .set(feedback.toMap());
            await _dbHelper!.markAsSynced('feedback', feedback.id);
            _syncStatusProvider?.decrementPendingSync();
            AppLogger.info(
              'SyncService: syncToFirestore - Synced feedback: ${feedback.id}',
            );
          }
        } catch (error, stackTrace) {
          AppLogger.error(
            'Error syncing feedback ${feedbackData['id']}',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      _syncStatusProvider?.setStatus(SyncStatus.success);
      AppLogger.info('SyncService: syncToFirestore - Upload sync completed');
    } catch (error, stackTrace) {
      _syncStatusProvider?.setStatus(SyncStatus.error, error: error.toString());
      AppLogger.error(
        'Error syncing to Firestore',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // Get data with fallback to local DB if offline
  Future<List<UserModel>> getUsers() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final currentUser = FirebaseService.auth.currentUser;
        if (currentUser == null) return [];
        final userDoc = await FirebaseService.firestore
            .collection(FirestoreCollections.users)
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          return [UserModel.fromFirestore(userDoc.data()!, userDoc.id)];
        }
        return [];
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching users from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }
    if (await isOnline()) {
      await syncFromFirestore();
    }
    return await _dbHelper!.getUsers();
  }

  Future<List<ApplicationModel>> getApplications() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final currentUser = FirebaseService.auth.currentUser;
        if (currentUser == null) return [];
        final applicationsSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.applications)
            .where('ownerId', isEqualTo: currentUser.uid)
            .get();
        return applicationsSnapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc.data(), doc.id))
            .toList();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching applications from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }
    if (await isOnline()) {
      await syncFromFirestore();
    }
    return await _dbHelper!.getApplications();
  }

  Future<List<BeneficiaryModel>> getBeneficiaries() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final currentUser = FirebaseService.auth.currentUser;
        if (currentUser == null) return [];
        final beneficiariesSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.beneficiaries)
            .where('ownerId', isEqualTo: currentUser.uid)
            .get();
        return beneficiariesSnapshot.docs
            .map((doc) => BeneficiaryModel.fromFirestore(doc.data(), doc.id))
            .toList();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching beneficiaries from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }
    if (await isOnline()) {
      await syncFromFirestore();
    }
    return await _dbHelper!.getBeneficiaries();
  }

  Future<List<DisbursementModel>> getDisbursements() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final currentUser = FirebaseService.auth.currentUser;
        if (currentUser == null) return [];

        // First get user's applications to get application IDs
        final applicationsSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.applications)
            .where('ownerId', isEqualTo: currentUser.uid)
            .get();

        if (applicationsSnapshot.docs.isEmpty) return [];

        final applicationIds =
            applicationsSnapshot.docs.map((doc) => doc.id).toList();

        // Then get disbursements for these applications
        final disbursementsSnapshot = await FirestoreQueryHelper.queryByWhereIn(
          firestore: FirebaseService.firestore,
          collection: FirestoreCollections.disbursements,
          field: 'applicationId',
          values: applicationIds,
        );

        return disbursementsSnapshot
            .map((doc) => DisbursementModel.fromFirestore(doc.data(), doc.id))
            .toList();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching disbursements from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }
    if (await isOnline()) {
      await syncFromFirestore();
    }
    return await _dbHelper!.getDisbursements();
  }

  Future<List<GrievanceModel>> getGrievances() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final currentUser = FirebaseService.auth.currentUser;
        if (currentUser == null) return [];

        // Get grievances created by user
        final grievancesQuery1 = await FirebaseService.firestore
            .collection(FirestoreCollections.grievances)
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        final grievances = <QueryDocumentSnapshot<Map<String, dynamic>>>[
          ...grievancesQuery1.docs,
        ];

        // Get user's beneficiaries to get beneficiary IDs
        final beneficiariesSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.beneficiaries)
            .where('ownerId', isEqualTo: currentUser.uid)
            .get();

        if (beneficiariesSnapshot.docs.isNotEmpty) {
          final beneficiaryIds =
              beneficiariesSnapshot.docs.map((doc) => doc.id).toList();

          // Get grievances related to user's beneficiaries
          final grievancesQuery2 = await FirestoreQueryHelper.queryByWhereIn(
            firestore: FirebaseService.firestore,
            collection: FirestoreCollections.grievances,
            field: 'beneficiaryId',
            values: beneficiaryIds,
          );

          grievances.addAll(grievancesQuery2);
        }

        final uniqueGrievances = FirestoreQueryHelper.dedupeDocsById(
          grievances,
        );

        return uniqueGrievances
            .map((doc) => GrievanceModel.fromFirestore(doc.data(), doc.id))
            .toList();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching grievances from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }
    if (await isOnline()) {
      await syncFromFirestore();
    }
    return await _dbHelper!.getGrievances();
  }

  Future<List<FeedbackModel>> getFeedback() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final currentUser = FirebaseService.auth.currentUser;
        if (currentUser == null) return [];
        final feedbackSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.feedback)
            .where('userId', isEqualTo: currentUser.uid)
            .get();
        return feedbackSnapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.id, doc.data()))
            .toList();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching feedback from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }
    if (await isOnline()) {
      await syncFromFirestore();
    }
    return await _dbHelper!.getFeedback();
  }

  Future<List<Report>> getReports() async {
    if (kIsWeb) {
      // On web, fetch directly from Firebase
      try {
        final reportsSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.reports)
            .get();
        return reportsSnapshot.docs
            .map((doc) => Report.fromJson(doc.data(), doc.id))
            .toList();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error fetching reports from Firebase',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    }

    // First try to get from local DB
    final localReports = await _dbHelper!.getReports();
    AppLogger.info(
      'SyncService: getReports - Retrieved ${localReports.length} reports from local DB',
    );

    // If we have local reports, try to sync in background but return local data immediately
    if (localReports.isNotEmpty) {
      final online = await isOnline();
      AppLogger.info('SyncService: getReports - Online status: $online');
      if (online) {
        AppLogger.info(
          'SyncService: getReports - Starting background sync from Firestore',
        );
        try {
          await syncFromFirestore();
          AppLogger.info('SyncService: getReports - Background sync completed');
        } catch (error, stackTrace) {
          AppLogger.warning(
            'SyncService: getReports - Background sync failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      return localReports;
    }

    // If no local reports, try to fetch from Firebase directly
    final online = await isOnline();
    AppLogger.info(
        'SyncService: getReports - No local reports, online status: $online');

    if (online) {
      try {
        AppLogger.info(
          'SyncService: getReports - Fetching reports directly from Firestore',
        );
        final reportsSnapshot = await FirebaseService.firestore
            .collection(FirestoreCollections.reports)
            .get();
        AppLogger.info(
          'SyncService: getReports - Found ${reportsSnapshot.docs.length} reports in Firestore',
        );

        final reports = reportsSnapshot.docs
            .map((doc) => Report.fromJson(doc.data(), doc.id))
            .toList();

        // Save to local DB for future use
        for (var report in reports) {
          await _dbHelper!.insertReport(report);
        }

        AppLogger.info(
          'SyncService: getReports - Saved ${reports.length} reports to local DB',
        );
        return reports;
      } catch (error, stackTrace) {
        AppLogger.error(
          'SyncService: getReports - Error fetching from Firestore',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    } else {
      AppLogger.warning(
          'SyncService: getReports - Offline and no local reports available');
      return [];
    }
  }

  Future<void> _createSampleReports() async {
    final sampleReports = [
      {
        'name': 'Monthly Applications Report',
        'type': 'applications',
        'category': 'statistical',
        'frequency': 'monthly',
        'status': 'completed',
        'fileSize': '2.5 MB',
        'fileFormat': 'PDF',
        'generatedDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'generatedBy': 'System',
        'lastRun':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'nextRun':
            DateTime.now().add(const Duration(days: 25)).toIso8601String(),
        'recordCount': 150,
        'description':
            'Comprehensive report of all applications submitted in the current month',
        'parameters': {'month': 'December', 'year': 2024},
        'downloadCount': 5,
        'isScheduled': true,
        'recipients': ['admin@nyantara.com'],
        'columns': ['id', 'name', 'status', 'amount', 'date'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Beneficiary Disbursement Summary',
        'type': 'disbursements',
        'category': 'financial',
        'frequency': 'weekly',
        'status': 'completed',
        'fileSize': '1.8 MB',
        'fileFormat': 'PDF',
        'generatedDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'generatedBy': 'System',
        'lastRun':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'nextRun':
            DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'recordCount': 89,
        'description':
            'Weekly summary of all disbursements made to beneficiaries',
        'parameters': {'week': '48', 'year': 2024},
        'downloadCount': 3,
        'isScheduled': true,
        'recipients': ['finance@nyantara.com'],
        'columns': ['beneficiaryId', 'amount', 'date', 'status'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Grievance Resolution Report',
        'type': 'grievances',
        'category': 'performance',
        'frequency': 'quarterly',
        'status': 'processing',
        'fileSize': null,
        'fileFormat': 'PDF',
        'generatedDate': null,
        'generatedBy': 'System',
        'lastRun': null,
        'nextRun':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'recordCount': null,
        'description':
            'Analysis of grievance resolution times and effectiveness',
        'parameters': {'quarter': 'Q4', 'year': 2024},
        'downloadCount': 0,
        'isScheduled': true,
        'recipients': ['support@nyantara.com'],
        'columns': ['id', 'type', 'status', 'resolutionTime'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'User Feedback Analysis',
        'type': 'feedback',
        'category': 'analytical',
        'frequency': 'monthly',
        'status': 'scheduled',
        'fileSize': null,
        'fileFormat': 'PDF',
        'generatedDate': null,
        'generatedBy': 'System',
        'lastRun': null,
        'nextRun':
            DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'recordCount': null,
        'description': 'Analysis of user feedback and satisfaction metrics',
        'parameters': {'month': 'December', 'year': 2024},
        'downloadCount': 0,
        'isScheduled': true,
        'recipients': ['ux@nyantara.com'],
        'columns': ['rating', 'category', 'comments', 'date'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'System Performance Report',
        'type': 'technical',
        'category': 'technical',
        'frequency': 'daily',
        'status': 'completed',
        'fileSize': '500 KB',
        'fileFormat': 'PDF',
        'generatedDate':
            DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'generatedBy': 'System',
        'lastRun':
            DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'nextRun':
            DateTime.now().add(const Duration(hours: 18)).toIso8601String(),
        'recordCount': 24,
        'description': 'Daily system performance metrics and uptime statistics',
        'parameters': {'date': DateTime.now().toIso8601String().split('T')[0]},
        'downloadCount': 1,
        'isScheduled': true,
        'recipients': ['tech@nyantara.com'],
        'columns': ['metric', 'value', 'timestamp'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final reportData in sampleReports) {
      try {
        await FirebaseService.firestore
            .collection(FirestoreCollections.reports)
            .add(reportData);
        AppLogger.info(
            'SyncService: Created sample report: ${reportData['name']}');
      } catch (error, stackTrace) {
        AppLogger.error(
          'SyncService: Error creating sample report ${reportData['name']}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
