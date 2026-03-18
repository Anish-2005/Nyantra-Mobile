import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_dashboard_app/src/core/models/report_model.dart';

void main() {
  group('Report.fromJson', () {
    test('parses Firestore/native values correctly', () {
      final generatedAt = DateTime.utc(2026, 1, 15, 10, 30);

      final report = Report.fromJson({
        'name': 'Monthly Applications',
        'type': 'applications',
        'category': 'statistical',
        'frequency': 'monthly',
        'status': 'completed',
        'generatedDate': Timestamp.fromDate(generatedAt),
        'schedule': {'day': 'Monday'},
        'parameters': {'year': 2026},
        'downloadCount': '4',
        'isScheduled': 'true',
        'recipients': ['ops@nyantra.gov.in'],
        'columns': ['id', 'status'],
        'description': 'Generated report',
      }, 'report-1');

      expect(report.id, 'report-1');
      expect(report.name, 'Monthly Applications');
      expect(report.downloadCount, 4);
      expect(report.isScheduled, isTrue);
      expect(report.generatedDate, generatedAt.toIso8601String());
      expect(report.schedule?['day'], 'Monday');
      expect(report.parameters?['year'], 2026);
      expect(report.recipients, ['ops@nyantra.gov.in']);
      expect(report.columns, ['id', 'status']);
    });

    test('parses JSON-string encoded map/list values safely', () {
      final report = Report.fromJson({
        'name': 'Disbursement Summary',
        'schedule': '{"hour":"09"}',
        'parameters': '{"quarter":"Q1"}',
        'recipients': '["finance@nyantra.gov.in"]',
        'columns': '["amount","beneficiaryId"]',
        'description': 'Report from encoded fields',
      }, 'report-2');

      expect(report.schedule?['hour'], '09');
      expect(report.parameters?['quarter'], 'Q1');
      expect(report.recipients, ['finance@nyantra.gov.in']);
      expect(report.columns, ['amount', 'beneficiaryId']);
    });
  });
}
