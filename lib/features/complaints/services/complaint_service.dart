import 'package:flutter/foundation.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';

/// Complaint Service
/// Handles submission, querying, updating status, worker assignment, and resolution.
/// Maintains an in-memory/local store for dev testing and bridges to Firestore.
class ComplaintService extends ChangeNotifier {
  final List<ComplaintModel> _complaints = [];
  bool _isLoading = false;

  List<ComplaintModel> get complaints => List.unmodifiable(_complaints);
  bool get isLoading => _isLoading;

  /// Submit a new complaint
  Future<void> submitComplaint(ComplaintModel complaint) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 800));

    _complaints.insert(0, complaint);

    _setLoading(false);
    notifyListeners();
  }

  /// Get complaints submitted by a specific citizen
  List<ComplaintModel> getCitizenComplaints(String userId) {
    return _complaints.where((c) => c.userId == userId).toList();
  }

  /// Get complaints assigned to a specific field worker
  List<ComplaintModel> getWorkerComplaints(String workerId) {
    return _complaints.where((c) => c.assignment?.workerId == workerId).toList();
  }

  /// Get all complaints filtered by status or category (for Admin)
  List<ComplaintModel> filterComplaints({
    String? status,
    String? category,
    String? priority,
  }) {
    return _complaints.where((c) {
      if (status != null && c.status != status) return false;
      if (category != null && c.category != category) return false;
      if (priority != null && c.priority != priority) return false;
      return true;
    }).toList();
  }

  /// Update complaint status (Admin or Worker)
  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    final index = _complaints.indexWhere((c) => c.complaintId == complaintId);
    if (index != -1) {
      final old = _complaints[index];
      _complaints[index] = ComplaintModel(
        complaintId: old.complaintId,
        userId: old.userId,
        citizenName: old.citizenName,
        title: old.title,
        description: old.description,
        category: old.category,
        status: newStatus,
        priority: old.priority,
        location: old.location,
        images: old.images,
        aiAnalysis: old.aiAnalysis,
        assignment: old.assignment,
        resolution: old.resolution,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Assign complaint to department and field worker (Admin action)
  Future<void> assignWorker({
    required String complaintId,
    required String department,
    required String workerId,
    required String workerName,
    required String assignedBy,
  }) async {
    final index = _complaints.indexWhere((c) => c.complaintId == complaintId);
    if (index != -1) {
      final old = _complaints[index];
      _complaints[index] = ComplaintModel(
        complaintId: old.complaintId,
        userId: old.userId,
        citizenName: old.citizenName,
        title: old.title,
        description: old.description,
        category: old.category,
        status: ComplaintStatus.assigned,
        priority: old.priority,
        location: old.location,
        images: old.images,
        aiAnalysis: old.aiAnalysis,
        assignment: ComplaintAssignment(
          department: department,
          workerId: workerId,
          workerName: workerName,
          assignedBy: assignedBy,
          assignedAt: DateTime.now(),
        ),
        resolution: old.resolution,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Resolve complaint with resolution notes and after photo (Worker action)
  Future<void> resolveComplaint({
    required String complaintId,
    required String resolvedBy,
    required String notes,
    String? afterImage,
  }) async {
    final index = _complaints.indexWhere((c) => c.complaintId == complaintId);
    if (index != -1) {
      final old = _complaints[index];
      _complaints[index] = ComplaintModel(
        complaintId: old.complaintId,
        userId: old.userId,
        citizenName: old.citizenName,
        title: old.title,
        description: old.description,
        category: old.category,
        status: ComplaintStatus.resolved,
        priority: old.priority,
        location: old.location,
        images: old.images,
        aiAnalysis: old.aiAnalysis,
        assignment: old.assignment,
        resolution: ComplaintResolution(
          resolvedBy: resolvedBy,
          resolutionNotes: notes,
          beforeImage: old.images.geoTaggedUrl,
          afterImage: afterImage,
          resolvedAt: DateTime.now(),
        ),
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
