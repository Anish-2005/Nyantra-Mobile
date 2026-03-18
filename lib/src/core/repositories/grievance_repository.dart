import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import '../models/grievance_model.dart';

class GrievanceRepository {
  GrievanceRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<GrievanceModel>> getGrievances() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final controller = StreamController<List<GrievanceModel>>();
    final allGrievances = <String, GrievanceModel>{};
    final unsubscribers = <void Function()>[];

    final userQuery = _firestore
        .collection(FirestoreCollections.grievances)
        .where('userId', isEqualTo: currentUser.uid);

    final userUnsub = userQuery.snapshots().listen((snapshot) {
      for (final doc in snapshot.docs) {
        final grievance = GrievanceModel.fromFirestore(doc.data(), doc.id);
        allGrievances[grievance.id] = grievance;
      }

      final currentIds = snapshot.docs.map((doc) => doc.id).toSet();
      allGrievances.removeWhere(
        (id, grievance) =>
            grievance.userId == currentUser.uid && !currentIds.contains(id),
      );

      _emitSortedGrievances(controller, allGrievances);
    });

    unsubscribers.add(userUnsub.cancel);

    final beneficiariesQuery = _firestore
        .collection(FirestoreCollections.beneficiaries)
        .where('ownerId', isEqualTo: currentUser.uid);

    final beneficiariesUnsub = beneficiariesQuery.snapshots().listen((
      beneficiariesSnapshot,
    ) {
      final beneficiaryIds = beneficiariesSnapshot.docs.map((doc) => doc.id).toList();

      while (unsubscribers.length > 1) {
        unsubscribers.removeLast()();
      }

      for (final beneficiaryId in beneficiaryIds) {
        final beneficiaryQuery = _firestore
            .collection(FirestoreCollections.grievances)
            .where('beneficiaryId', isEqualTo: beneficiaryId);

        final unsub = beneficiaryQuery.snapshots().listen((snapshot) {
          for (final doc in snapshot.docs) {
            final grievance = GrievanceModel.fromFirestore(doc.data(), doc.id);
            allGrievances[grievance.id] = grievance;
          }

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

  Future<void> createGrievance(GrievanceModel grievance) async {
    await _firestore
        .collection(FirestoreCollections.grievances)
        .doc(grievance.id)
        .set(grievance.toFirestore());
  }

  Future<void> appendGrievanceMessage(
    String grievanceId,
    Map<String, dynamic> message,
  ) async {
    await _firestore.collection(FirestoreCollections.grievances).doc(grievanceId).update({
      'communication': FieldValue.arrayUnion([message]),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  void _emitSortedGrievances(
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
}
