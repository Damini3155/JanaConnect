import 'package:geo_tag_camera/core/constants/app_constants.dart';

/// Nested complaint location object
class ComplaintLocation {
  final double latitude;
  final double longitude;
  final String address;
  final double? accuracy;

  const ComplaintLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.accuracy,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
    };
  }

  factory ComplaintLocation.fromMap(Map<String, dynamic> map) {
    return ComplaintLocation(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      accuracy: (map['accuracy'] as num?)?.toDouble(),
    );
  }
}

/// Nested complaint images object
class ComplaintImages {
  final String originalUrl;
  final String geoTaggedUrl;

  const ComplaintImages({
    required this.originalUrl,
    required this.geoTaggedUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'originalUrl': originalUrl,
      'geoTaggedUrl': geoTaggedUrl,
    };
  }

  factory ComplaintImages.fromMap(Map<String, dynamic> map) {
    return ComplaintImages(
      originalUrl: map['originalUrl'] as String? ?? '',
      geoTaggedUrl: map['geoTaggedUrl'] as String? ?? '',
    );
  }
}

/// Nested AI Analysis object populated by Gemini AI Agents
class AIAnalysisResult {
  final String category;
  final double confidence;
  final String priority;
  final int severityScore;
  final double duplicateProbability;
  final String recommendedDepartment;
  final bool isDuplicate;
  final String? linkedComplaintId;

  const AIAnalysisResult({
    required this.category,
    required this.confidence,
    required this.priority,
    required this.severityScore,
    required this.duplicateProbability,
    required this.recommendedDepartment,
    this.isDuplicate = false,
    this.linkedComplaintId,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'confidence': confidence,
      'priority': priority,
      'severityScore': severityScore,
      'duplicateProbability': duplicateProbability,
      'recommendedDepartment': recommendedDepartment,
      'isDuplicate': isDuplicate,
      'linkedComplaintId': linkedComplaintId,
    };
  }

  factory AIAnalysisResult.fromMap(Map<String, dynamic> map) {
    return AIAnalysisResult(
      category: map['category'] as String? ?? ComplaintCategory.other,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      priority: map['priority'] as String? ?? ComplaintPriority.medium,
      severityScore: (map['severityScore'] as num?)?.toInt() ?? 5,
      duplicateProbability: (map['duplicateProbability'] as num?)?.toDouble() ?? 0.0,
      recommendedDepartment: map['recommendedDepartment'] as String? ?? Department.general,
      isDuplicate: map['isDuplicate'] as bool? ?? false,
      linkedComplaintId: map['linkedComplaintId'] as String?,
    );
  }
}

/// Nested Worker Assignment object
class ComplaintAssignment {
  final String department;
  final String? workerId;
  final String? workerName;
  final String? assignedBy;
  final DateTime? assignedAt;

  const ComplaintAssignment({
    required this.department,
    this.workerId,
    this.workerName,
    this.assignedBy,
    this.assignedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'department': department,
      'workerId': workerId,
      'workerName': workerName,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt?.toIso8601String(),
    };
  }

  factory ComplaintAssignment.fromMap(Map<String, dynamic> map) {
    return ComplaintAssignment(
      department: map['department'] as String? ?? Department.general,
      workerId: map['workerId'] as String?,
      workerName: map['workerName'] as String?,
      assignedBy: map['assignedBy'] as String?,
      assignedAt: map['assignedAt'] != null
          ? DateTime.tryParse(map['assignedAt'] as String)
          : null,
    );
  }
}

/// Nested Complaint Resolution object
class ComplaintResolution {
  final String? resolvedBy;
  final String? resolutionNotes;
  final String? beforeImage;
  final String? afterImage;
  final DateTime? resolvedAt;

  const ComplaintResolution({
    this.resolvedBy,
    this.resolutionNotes,
    this.beforeImage,
    this.afterImage,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'resolvedBy': resolvedBy,
      'resolutionNotes': resolutionNotes,
      'beforeImage': beforeImage,
      'afterImage': afterImage,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory ComplaintResolution.fromMap(Map<String, dynamic> map) {
    return ComplaintResolution(
      resolvedBy: map['resolvedBy'] as String?,
      resolutionNotes: map['resolutionNotes'] as String?,
      beforeImage: map['beforeImage'] as String?,
      afterImage: map['afterImage'] as String?,
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.tryParse(map['resolvedAt'] as String)
          : null,
    );
  }
}

/// Main Complaint Model
class ComplaintModel {
  final String complaintId;
  final String userId;
  final String citizenName;
  final String title;
  final String description;
  final String category;
  final String status;
  final String priority;
  final ComplaintLocation location;
  final ComplaintImages images;
  final AIAnalysisResult? aiAnalysis;
  final ComplaintAssignment? assignment;
  final ComplaintResolution? resolution;
  final String? audioPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComplaintModel({
    required this.complaintId,
    required this.userId,
    required this.citizenName,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.location,
    required this.images,
    this.aiAnalysis,
    this.assignment,
    this.resolution,
    this.audioPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'citizenName': citizenName,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'priority': priority,
      'location': location.toMap(),
      'images': images.toMap(),
      if (aiAnalysis != null) 'aiAnalysis': aiAnalysis!.toMap(),
      if (assignment != null) 'assignment': assignment!.toMap(),
      if (resolution != null) 'resolution': resolution!.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    return ComplaintModel(
      complaintId: id,
      userId: map['userId'] as String? ?? '',
      citizenName: map['citizenName'] as String? ?? 'Anonymous',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? ComplaintCategory.other,
      status: map['status'] as String? ?? ComplaintStatus.submitted,
      priority: map['priority'] as String? ?? ComplaintPriority.medium,
      location: ComplaintLocation.fromMap(
        (map['location'] as Map<String, dynamic>?) ?? {},
      ),
      images: ComplaintImages.fromMap(
        (map['images'] as Map<String, dynamic>?) ?? {},
      ),
      aiAnalysis: map['aiAnalysis'] != null
          ? AIAnalysisResult.fromMap(map['aiAnalysis'] as Map<String, dynamic>)
          : null,
      assignment: map['assignment'] != null
          ? ComplaintAssignment.fromMap(map['assignment'] as Map<String, dynamic>)
          : null,
      resolution: map['resolution'] != null
          ? ComplaintResolution.fromMap(map['resolution'] as Map<String, dynamic>)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
