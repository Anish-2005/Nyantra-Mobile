import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import '../models/disbursement_model.dart';
import '../utils/firestore_query_helper.dart';

class DisbursementRepository {
  DisbursementRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<DisbursementModel>> getDisbursements() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(FirestoreCollections.beneficiaries)
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((beneficiariesSnapshot) async {
          final beneficiaryIds = beneficiariesSnapshot.docs
              .map((doc) => doc.id)
              .toList();

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

          final uniqueApplicationIds = FirestoreQueryHelper.dedupeDocsById([
            ...applicationsQuery1.docs,
            ...applicationsQuery2,
          ]).map((doc) => doc.id).toList();

          if (uniqueApplicationIds.isEmpty && beneficiaryIds.isEmpty) {
            return [];
          }

          final allDisbursements = <DisbursementModel>[];

          if (uniqueApplicationIds.isNotEmpty) {
            final disbursementsSnapshot = await FirestoreQueryHelper.queryByWhereIn(
              firestore: _firestore,
              collection: FirestoreCollections.disbursements,
              field: 'applicationId',
              values: uniqueApplicationIds,
            );

            allDisbursements.addAll(
              disbursementsSnapshot
                  .map(
                    (doc) => DisbursementModel.fromFirestore(doc.data(), doc.id),
                  )
                  .toList(),
            );
          }

          if (beneficiaryIds.isNotEmpty) {
            final beneficiaryDisbursementsSnapshot = await FirestoreQueryHelper.queryByWhereIn(
              firestore: _firestore,
              collection: FirestoreCollections.disbursements,
              field: 'beneficiaryId',
              values: beneficiaryIds,
            );

            allDisbursements.addAll(
              beneficiaryDisbursementsSnapshot
                  .map(
                    (doc) => DisbursementModel.fromFirestore(doc.data(), doc.id),
                  )
                  .toList(),
            );
          }

          final disbursementIds = <String>{};
          return allDisbursements.where((disbursement) {
            if (disbursementIds.contains(disbursement.id)) {
              return false;
            }
            disbursementIds.add(disbursement.id);
            return true;
          }).toList();
        });
  }

  Future<void> createDisbursement(DisbursementModel disbursement) async {
    await _firestore
        .collection(FirestoreCollections.disbursements)
        .add(disbursement.toFirestore());
  }

  Future<void> updateDisbursement(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(FirestoreCollections.disbursements)
        .doc(id)
        .update(data);
  }
}
