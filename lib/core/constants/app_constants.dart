/// Global application constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'PCMC JanConnect';
  static const String appTagline = 'Every Voice Matters.';
  static const String appVersion = '1.0.0';

  // Complaint ID prefix
  static const String complaintIdPrefix = 'CMP';

  // Pagination
  static const int pageSize = 20;

  // Image
  static const double geoTagImageQuality = 0.85;
  static const int maxImageSizeMB = 10;

  // GPS
  static const double duplicateRadiusMeters = 50.0;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);

  // AI Confidence threshold
  static const double aiConfidenceThreshold = 0.6;
}

/// Complaint status constants
class ComplaintStatus {
  ComplaintStatus._();

  static const String submitted = 'submitted';
  static const String aiAnalyzed = 'ai_analyzed';
  static const String underReview = 'under_review';
  static const String assigned = 'assigned';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String closed = 'closed';
  static const String rejected = 'rejected';

  static const List<String> all = [
    submitted,
    aiAnalyzed,
    underReview,
    assigned,
    inProgress,
    resolved,
    closed,
    rejected,
  ];

  static String displayName(String status) {
    switch (status) {
      case submitted:
        return 'Report Received';
      case aiAnalyzed:
        return 'Problem Verified';
      case underReview:
        return 'Being Reviewed';
      case assigned:
        return 'Team Assigned';
      case inProgress:
        return 'Work in Progress';
      case resolved:
        return 'Resolved';
      case closed:
        return 'Resolved';
      case rejected:
        return 'Needs Info';
      default:
        return status;
    }
  }
}

/// Complaint priority constants
class ComplaintPriority {
  ComplaintPriority._();

  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String critical = 'critical';

  static const List<String> all = [low, medium, high, critical];

  static String displayName(String priority) {
    switch (priority) {
      case low:
        return 'Low';
      case medium:
        return 'Medium';
      case high:
        return 'High';
      case critical:
        return 'Critical';
      default:
        return priority;
    }
  }
}

/// Complaint category constants
class ComplaintCategory {
  ComplaintCategory._();

  static const String garbageWaste = 'garbage_waste';
  static const String roadDamage = 'road_damage';
  static const String waterLeakage = 'water_leakage';
  static const String drainageProblem = 'drainage_problem';
  static const String streetlight = 'streetlight';
  static const String illegalDumping = 'illegal_dumping';
  static const String publicProperty = 'public_property';
  static const String treeEnvironment = 'tree_environment';
  static const String animalRelated = 'animal_related';
  static const String other = 'other';

  static const List<String> all = [
    garbageWaste,
    roadDamage,
    waterLeakage,
    drainageProblem,
    streetlight,
    illegalDumping,
    publicProperty,
    treeEnvironment,
    animalRelated,
    other,
  ];

  static String displayName(String category) {
    switch (category) {
      case garbageWaste:
        return 'Garbage / Waste';
      case roadDamage:
        return 'Road Damage / Pothole';
      case waterLeakage:
        return 'Water Leakage';
      case drainageProblem:
        return 'Drainage Problem';
      case streetlight:
        return 'Street Light Problem';
      case illegalDumping:
        return 'Illegal Dumping';
      case publicProperty:
        return 'Damaged Public Property';
      case treeEnvironment:
        return 'Tree / Environmental Issue';
      case animalRelated:
        return 'Animal Related Issue';
      case other:
        return 'Other';
      default:
        return category;
    }
  }

  static String emoji(String category) {
    switch (category) {
      case garbageWaste:
        return '🗑️';
      case roadDamage:
        return '🚧';
      case waterLeakage:
        return '💧';
      case drainageProblem:
        return '🌊';
      case streetlight:
        return '💡';
      case illegalDumping:
        return '⚠️';
      case publicProperty:
        return '🏚️';
      case treeEnvironment:
        return '🌳';
      case animalRelated:
        return '🐾';
      case other:
        return '📋';
      default:
        return '📋';
    }
  }
}

/// User role constants
class UserRole {
  UserRole._();

  static const String citizen = 'citizen';
  static const String admin = 'admin';
  static const String worker = 'worker';
}

/// Department routing constants
class Department {
  Department._();

  static const String sanitation = 'Sanitation Department';
  static const String road = 'Road Department';
  static const String water = 'Water Department';
  static const String electricity = 'Electricity Department';
  static const String drainage = 'Drainage Department';
  static const String publicWorks = 'Public Works Department';
  static const String environment = 'Environment Department';
  static const String animalControl = 'Animal Control Department';
  static const String general = 'General Department';

  static String forCategory(String category) {
    switch (category) {
      case ComplaintCategory.garbageWaste:
      case ComplaintCategory.illegalDumping:
        return sanitation;
      case ComplaintCategory.roadDamage:
        return road;
      case ComplaintCategory.waterLeakage:
        return water;
      case ComplaintCategory.streetlight:
        return electricity;
      case ComplaintCategory.drainageProblem:
        return drainage;
      case ComplaintCategory.publicProperty:
        return publicWorks;
      case ComplaintCategory.treeEnvironment:
        return environment;
      case ComplaintCategory.animalRelated:
        return animalControl;
      default:
        return general;
    }
  }
}
