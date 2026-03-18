import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_model.dart';
import '../models/disbursement_model.dart';
import '../utils/app_logger.dart';
import 'email_service.dart';

class AlertService {
  static const String _dismissedAlertsKey = 'dismissed_disbursement_alerts';
  static const String _emailedAlertsKey = 'emailed_disbursement_alerts';
  static const String _emailedEventsKey = 'emailed_disbursement_events';
  static const String _lastViewedTimestampKey =
      'last_viewed_disbursements_timestamp';

  static Future<Set<String>> getDismissedAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedJson = prefs.getString(_dismissedAlertsKey);
    if (dismissedJson != null) {
      final List<dynamic> dismissedList = json.decode(dismissedJson);
      return dismissedList.map((e) => e as String).toSet();
    }
    return {};
  }

  static Future<void> saveDismissedAlerts(Set<String> dismissedAlerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dismissedAlertsKey,
      json.encode(dismissedAlerts.toList()),
    );
  }

  static Future<Set<String>> getEmailedAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final emailedJson = prefs.getString(_emailedAlertsKey);
    if (emailedJson != null) {
      final List<dynamic> emailedList = json.decode(emailedJson);
      return emailedList.map((e) => e as String).toSet();
    }
    return {};
  }

  static Future<void> saveEmailedAlerts(Set<String> emailedAlerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _emailedAlertsKey,
      json.encode(emailedAlerts.toList()),
    );
  }

  static Future<Set<String>> getEmailedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final emailedJson = prefs.getString(_emailedEventsKey);
    if (emailedJson != null) {
      final List<dynamic> emailedList = json.decode(emailedJson);
      return emailedList.map((e) => e as String).toSet();
    }
    return {};
  }

  static Future<void> saveEmailedEvents(Set<String> emailedEvents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _emailedEventsKey,
      json.encode(emailedEvents.toList()),
    );
  }

  static Future<DateTime?> getLastViewedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_lastViewedTimestampKey);
    if (timestampStr != null) {
      return DateTime.parse(timestampStr);
    }
    return null;
  }

  static Future<void> saveLastViewedTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastViewedTimestampKey, timestamp.toIso8601String());
  }

  static Future<List<DisbursementAlert>> generateAlerts(
    List<DisbursementModel> disbursements,
    Set<String> dismissedAlerts,
    DateTime? lastViewedTimestamp,
  ) async {
    final alerts = <DisbursementAlert>[];

    for (final disbursement in disbursements) {
      if (lastViewedTimestamp != null &&
          disbursement.createdAt != null &&
          disbursement.createdAt!.isAfter(lastViewedTimestamp) &&
          !dismissedAlerts.contains('new-${disbursement.id}')) {
        alerts.add(
          DisbursementAlert(
            id: 'new-${disbursement.id}',
            type: AlertType.newDisbursement,
            disbursementId: disbursement.id,
            message:
                'New disbursement of Rs. ${disbursement.reliefAmount.toStringAsFixed(0)} has been initiated',
            timestamp: disbursement.createdAt!,
            data: {'disbursement': disbursement.toFirestore()},
          ),
        );
      }

      if (disbursement.isProgressivePayment &&
          disbursement.completedInstallments > 0) {
        final lastCompletedInstallment = disbursement.completedInstallments;
        final alertId =
            'installment-${disbursement.id}-$lastCompletedInstallment';

        if (!dismissedAlerts.contains(alertId)) {
          final installmentAmount =
              disbursement.reliefAmount / disbursement.totalInstallments;

          alerts.add(
            DisbursementAlert(
              id: alertId,
              type: AlertType.installmentCompleted,
              disbursementId: disbursement.id,
              message:
                  'Installment $lastCompletedInstallment of Rs. ${installmentAmount.toStringAsFixed(0)} has been disbursed',
              timestamp: DateTime.now(),
              data: {'disbursement': disbursement.toFirestore()},
            ),
          );
        }
      }

      if (disbursement.status == DisbursementStatus.completed &&
          !dismissedAlerts.contains('completed-${disbursement.id}')) {
        alerts.add(
          DisbursementAlert(
            id: 'completed-${disbursement.id}',
            type: AlertType.statusCompleted,
            disbursementId: disbursement.id,
            message:
                'Your disbursement of Rs. ${disbursement.disbursedAmount.toStringAsFixed(0)} has been completed',
            timestamp: disbursement.disbursementDate ?? DateTime.now(),
            data: {'disbursement': disbursement.toFirestore()},
          ),
        );
      }
    }

    return alerts;
  }

  static Future<void> sendEmailNotifications(
    List<DisbursementAlert> alerts,
    String beneficiaryEmail,
    Set<String> emailedAlerts,
    Set<String> emailedEvents,
  ) async {
    if (beneficiaryEmail.isEmpty) return;

    for (final alert in alerts) {
      if (emailedAlerts.contains(alert.id)) continue;

      final eventKey = 'disbursement-${alert.disbursementId}-${alert.type.name}';
      if (emailedEvents.contains(eventKey)) continue;

      try {
        await EmailService.sendDisbursementNotification(
          alert: alert,
          beneficiaryEmail: beneficiaryEmail,
        );

        emailedAlerts.add(alert.id);
        emailedEvents.add(eventKey);

        AppLogger.info(
          'Email sent for alert: ${alert.type.name} to $beneficiaryEmail',
        );
      } catch (error, stackTrace) {
        AppLogger.error(
          'Failed to send email for alert ${alert.id}',
          error: error,
          stackTrace: stackTrace,
        );
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    await saveEmailedAlerts(emailedAlerts);
    await saveEmailedEvents(emailedEvents);
  }

  static Future<void> dismissAlert(String alertId) async {
    final dismissedAlerts = await getDismissedAlerts();
    dismissedAlerts.add(alertId);
    await saveDismissedAlerts(dismissedAlerts);
  }

  static Future<void> dismissAllAlerts(List<String> alertIds) async {
    final dismissedAlerts = await getDismissedAlerts();
    dismissedAlerts.addAll(alertIds);
    await saveDismissedAlerts(dismissedAlerts);
  }
}
