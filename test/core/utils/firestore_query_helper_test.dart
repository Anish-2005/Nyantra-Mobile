import 'package:flutter_test/flutter_test.dart';
import 'package:user_dashboard_app/src/core/utils/firestore_query_helper.dart';

void main() {
  group('FirestoreQueryHelper.chunkList', () {
    test('splits values into fixed-size chunks', () {
      final chunks = FirestoreQueryHelper.chunkList(
        [1, 2, 3, 4, 5],
        chunkSize: 2,
      ).toList();

      expect(chunks, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('returns empty chunks for empty input', () {
      final chunks = FirestoreQueryHelper.chunkList(<int>[]).toList();
      expect(chunks, isEmpty);
    });

    test('throws when chunk size is invalid', () {
      expect(
        () => FirestoreQueryHelper.chunkList([1, 2, 3], chunkSize: 0).toList(),
        throwsArgumentError,
      );
    });
  });
}
