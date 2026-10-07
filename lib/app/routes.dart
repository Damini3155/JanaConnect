/// Named route constants for the application.
/// All navigation happens through these constants to avoid magic strings.
class AppRoutes {
  AppRoutes._();

  // ─── Core ─────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ─── Citizen ──────────────────────────────────────────────────────────────
  static const String citizenHome = '/citizen/home';
  static const String citizenProfile = '/citizen/profile';

  // ─── Camera ───────────────────────────────────────────────────────────────
  static const String geoTagCamera = '/camera/geo-tag';
  static const String photoPreview = '/camera/photo-preview';

  // ─── Complaints ───────────────────────────────────────────────────────────
  static const String complaintForm = '/complaints/form';
  static const String complaintList = '/complaints/list';
  static const String complaintDetail = '/complaints/detail';
  static const String complaintTracking = '/complaints/tracking';

  // ─── Admin ────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminComplaints = '/admin/complaints';
  static const String complaintMap = '/admin/map';
  static const String analytics = '/admin/analytics';

  // ─── Worker ───────────────────────────────────────────────────────────────
  static const String workerHome = '/worker/home';
  static const String assignedComplaints = '/worker/assigned';
}
