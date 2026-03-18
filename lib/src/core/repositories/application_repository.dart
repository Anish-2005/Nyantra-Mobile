import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import '../models/application_model.dart';
import '../utils/firestore_query_helper.dart';

class ApplicationRepository {
  ApplicationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<ApplicationModel>> getApplications() {
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

          final uniqueApplications = FirestoreQueryHelper.dedupeDocsById([
            ...applicationsQuery1.docs,
            ...applicationsQuery2,
          ]);

          return uniqueApplications
              .map((doc) => ApplicationModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> createApplication(ApplicationModel application) async {
    await _firestore
        .collection(FirestoreCollections.applications)
        .doc(application.id)
        .set(application.toFirestore());
  }

  Future<void> updateApplication(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(FirestoreCollections.applications)
        .doc(id)
        .update(data);
  }

  Future<void> deleteApplication(String id) async {
    await _firestore.collection(FirestoreCollections.applications).doc(id).delete();
  }
}
