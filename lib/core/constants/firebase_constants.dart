/// Firestore collection and field name constants.
/// Using constants prevents typo bugs in collection names.
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String complaints = 'complaints';
}

/// Firestore field names for the `users` collection
class UserFields {
  UserFields._();

  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String role = 'role';
  static const String profileImage = 'profileImage';
  static const String createdAt = 'createdAt';
  static const String isActive = 'isActive';
}

/// Firestore field names for the `complaints` collection
class ComplaintFields {
  ComplaintFields._();

  static const String complaintId = 'complaintId';
  static const String userId = 'userId';
  static const String citizenName = 'citizenName';
  static const String title = 'title';
  static const String description = 'description';
  static const String category = 'category';
  static const String status = 'status';
  static const String priority = 'priority';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // Nested: location
  static const String location = 'location';
  static const String latitude = 'location.latitude';
  static const String longitude = 'location.longitude';
  static const String address = 'location.address';
  static const String accuracy = 'location.accuracy';

  // Nested: images
  static const String images = 'images';
  static const String originalUrl = 'images.originalUrl';
  static const String geoTaggedUrl = 'images.geoTaggedUrl';

  // Nested: aiAnalysis
  static const String aiAnalysis = 'aiAnalysis';
  static const String aiCategory = 'aiAnalysis.category';
  static const String aiConfidence = 'aiAnalysis.confidence';
  static const String aiPriority = 'aiAnalysis.priority';
  static const String aiSeverityScore = 'aiAnalysis.severityScore';
  static const String aiDuplicateProbability = 'aiAnalysis.duplicateProbability';
  static const String aiRecommendedDepartment = 'aiAnalysis.recommendedDepartment';
  static const String aiIsDuplicate = 'aiAnalysis.isDuplicate';
  static const String aiLinkedComplaintId = 'aiAnalysis.linkedComplaintId';

  // Nested: assignment
  static const String assignment = 'assignment';
  static const String assignedDepartment = 'assignment.department';
  static const String workerId = 'assignment.workerId';
  static const String workerName = 'assignment.workerName';
  static const String assignedBy = 'assignment.assignedBy';
  static const String assignedAt = 'assignment.assignedAt';

  // Nested: resolution
  static const String resolution = 'resolution';
  static const String resolvedBy = 'resolution.resolvedBy';
  static const String resolutionNotes = 'resolution.resolutionNotes';
  static const String beforeImage = 'resolution.beforeImage';
  static const String afterImage = 'resolution.afterImage';
  static const String resolvedAt = 'resolution.resolvedAt';
}

/// Firebase Storage path helpers
class StoragePaths {
  StoragePaths._();

  /// Original captured photo
  static String originalImage(String userId, String complaintId) {
    return 'complaints/$userId/$complaintId/original.jpg';
  }

  /// Geo-tagged watermarked photo
  static String geoTaggedImage(String userId, String complaintId) {
    return 'complaints/$userId/$complaintId/geotagged.jpg';
  }

  /// Before-work photo (worker upload)
  static String beforeImage(String userId, String complaintId) {
    return 'complaints/$userId/$complaintId/before.jpg';
  }

  /// After-work photo (worker upload)
  static String afterImage(String userId, String complaintId) {
    return 'complaints/$userId/$complaintId/after.jpg';
  }

  /// User profile picture
  static String profileImage(String userId) {
    return 'users/$userId/profile.jpg';
  }
}
