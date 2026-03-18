import '../models/activity_model.dart';
import '../models/application_model.dart';
import '../models/beneficiary_model.dart';
import '../models/disbursement_model.dart';
import '../models/feedback_model.dart';
import '../models/grievance_model.dart';
import '../models/user_model.dart';
import '../repositories/application_repository.dart';
import '../repositories/beneficiary_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/disbursement_repository.dart';
import '../repositories/feedback_repository.dart';
import '../repositories/grievance_repository.dart';
import '../repositories/user_repository.dart';

class DataService {
  static final DashboardRepository _dashboardRepository = DashboardRepository();
  static final ApplicationRepository _applicationRepository =
      ApplicationRepository();
  static final BeneficiaryRepository _beneficiaryRepository =
      BeneficiaryRepository();
  static final DisbursementRepository _disbursementRepository =
      DisbursementRepository();
  static final GrievanceRepository _grievanceRepository = GrievanceRepository();
  static final UserRepository _userRepository = UserRepository();
  static final FeedbackRepository _feedbackRepository = FeedbackRepository();

  static Future<Map<String, dynamic>> getDashboardStats() {
    return _dashboardRepository.getDashboardStats();
  }

  static Future<List<ActivityModel>> getRecentActivities({int limit = 10}) {
    return _dashboardRepository.getRecentActivities(limit: limit);
  }

  static Stream<List<ApplicationModel>> getApplications() {
    return _applicationRepository.getApplications();
  }

  static Future<void> createApplication(ApplicationModel application) {
    return _applicationRepository.createApplication(application);
  }

  static Future<void> updateApplication(
    String id,
    Map<String, dynamic> data,
  ) {
    return _applicationRepository.updateApplication(id, data);
  }

  static Future<void> deleteApplication(String id) {
    return _applicationRepository.deleteApplication(id);
  }

  static Stream<List<BeneficiaryModel>> getBeneficiaries() {
    return _beneficiaryRepository.getBeneficiaries();
  }

  static Future<void> createBeneficiary(BeneficiaryModel beneficiary) {
    return _beneficiaryRepository.createBeneficiary(beneficiary);
  }

  static Future<void> updateBeneficiary(
    String id,
    Map<String, dynamic> data,
  ) {
    return _beneficiaryRepository.updateBeneficiary(id, data);
  }

  static Stream<List<DisbursementModel>> getDisbursements() {
    return _disbursementRepository.getDisbursements();
  }

  static Future<void> createDisbursement(DisbursementModel disbursement) {
    return _disbursementRepository.createDisbursement(disbursement);
  }

  static Future<void> updateDisbursement(
    String id,
    Map<String, dynamic> data,
  ) {
    return _disbursementRepository.updateDisbursement(id, data);
  }

  static Stream<List<GrievanceModel>> getGrievances() {
    return _grievanceRepository.getGrievances();
  }

  static Future<void> createGrievance(GrievanceModel grievance) {
    return _grievanceRepository.createGrievance(grievance);
  }

  static Future<void> appendGrievanceMessage(
    String grievanceId,
    Map<String, dynamic> message,
  ) {
    return _grievanceRepository.appendGrievanceMessage(grievanceId, message);
  }

  static Future<UserModel?> getUserProfile(String userId) {
    return _userRepository.getUserProfile(userId);
  }

  static Future<void> updateUserProfile(String userId, UserModel user) {
    return _userRepository.updateUserProfile(userId, user);
  }

  static Future<void> createUserProfile(UserModel user) {
    return _userRepository.createUserProfile(user);
  }

  static Future<void> submitFeedback({
    required String userId,
    required String subject,
    required String message,
    required int rating,
  }) {
    return _feedbackRepository.submitFeedback(
      userId: userId,
      subject: subject,
      message: message,
      rating: rating,
    );
  }

  static Stream<List<FeedbackModel>> getUserFeedbacks(String userId) {
    return _feedbackRepository.getUserFeedbacks(userId);
  }

  static Future<void> updateFeedback(
    String feedbackId,
    Map<String, dynamic> updates,
  ) {
    return _feedbackRepository.updateFeedback(feedbackId, updates);
  }

  static Future<void> deleteFeedback(String feedbackId) {
    return _feedbackRepository.deleteFeedback(feedbackId);
  }
}
