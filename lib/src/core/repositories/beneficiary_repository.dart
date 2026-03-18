import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import '../models/beneficiary_model.dart';

class BeneficiaryRepository {
  BeneficiaryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<BeneficiaryModel>> getBeneficiaries() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(FirestoreCollections.beneficiaries)
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BeneficiaryModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> createBeneficiary(BeneficiaryModel beneficiary) async {
    await _firestore
        .collection(FirestoreCollections.beneficiaries)
        .doc(beneficiary.id)
        .set(beneficiary.toFirestore());
  }

  Future<void> updateBeneficiary(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(FirestoreCollections.beneficiaries)
        .doc(id)
        .update(data);
  }
}
