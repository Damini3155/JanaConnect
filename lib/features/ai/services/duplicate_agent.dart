import 'package:flutter/foundation.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/services/location_service.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';

class DuplicateDetectionResult {
  final bool isDuplicate;
  final double duplicateProbability;
  final String? linkedComplaintId;
  final String reasoning;

  const DuplicateDetectionResult({
    required this.isDuplicate,
    required this.duplicateProbability,
    this.linkedComplaintId,
    required this.reasoning,
  });
}

/// Agent 3: AI Duplicate Complaint Detection Agent
class DuplicateAgent {
  final LocationService _locationService = LocationService();

  /// Check if candidate complaint is a duplicate of existing complaints in system
  DuplicateDetectionResult detectDuplicate({
    required double latitude,
    required double longitude,
    required String category,
    required List<ComplaintModel> existingComplaints,
  }) {
    ComplaintModel? closestDuplicate;
    double minDistance = AppConstants.duplicateRadiusMeters;

    for (final existing in existingComplaints) {
      // Only compare active/pending complaints in same category
      if (existing.category != category) continue;
      if (existing.status == ComplaintStatus.resolved || existing.status == ComplaintStatus.closed) continue;

      final dist = _locationService.calculateDistanceMeters(
        latitude,
        longitude,
        existing.location.latitude,
        existing.location.longitude,
      );

      if (dist <= minDistance) {
        minDistance = dist;
        closestDuplicate = existing;
      }
    }

    if (closestDuplicate != null) {
      final prob = (1.0 - (minDistance / AppConstants.duplicateRadiusMeters)).clamp(0.70, 0.98);
      debugPrint('DuplicateAgent: Found matching complaint #${closestDuplicate.complaintId} within ${minDistance.toStringAsFixed(1)}m');
      return DuplicateDetectionResult(
        isDuplicate: true,
        duplicateProbability: prob,
        linkedComplaintId: closestDuplicate.complaintId,
        reasoning: 'Matches active complaint #${closestDuplicate.complaintId} within ${minDistance.toStringAsFixed(1)}m radius',
      );
    }

    return const DuplicateDetectionResult(
      isDuplicate: false,
      duplicateProbability: 0.05,
      reasoning: 'Unique location and category',
    );
  }
}
