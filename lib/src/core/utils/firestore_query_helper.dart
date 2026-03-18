import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQueryHelper {
  const FirestoreQueryHelper._();

  static const int whereInLimit = 10;

  static Iterable<List<T>> chunkList<T>(
    List<T> values, {
    int chunkSize = whereInLimit,
  }) sync* {
    if (chunkSize <= 0) {
      throw ArgumentError.value(chunkSize, 'chunkSize', 'Must be greater than 0');
    }

    for (var i = 0; i < values.length; i += chunkSize) {
      final end = (i + chunkSize) > values.length ? values.length : i + chunkSize;
      yield values.sublist(i, end);
    }
  }

  static List<QueryDocumentSnapshot<Map<String, dynamic>>> dedupeDocsById(
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

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> queryByWhereIn({
    required FirebaseFirestore firestore,
    required String collection,
    required String field,
    required List<String> values,
    int chunkSize = whereInLimit,
    String? equalsField,
    Object? equalsValue,
  }) async {
    if (values.isEmpty) {
      return [];
    }

    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final chunk in chunkList(values, chunkSize: chunkSize)) {
      Query<Map<String, dynamic>> query = firestore
          .collection(collection)
          .where(field, whereIn: chunk);

      if (equalsField != null) {
        query = query.where(equalsField, isEqualTo: equalsValue);
      }

      final snapshot = await query.get();
      docs.addAll(snapshot.docs);
    }

    return dedupeDocsById(docs);
  }
}
