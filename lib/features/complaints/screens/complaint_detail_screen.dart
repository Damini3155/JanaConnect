import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/utils/date_utils.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';
import 'package:geo_tag_camera/features/complaints/widgets/status_timeline.dart';

/// Complaint Detail Screen
/// Displays geo-tagged image, AI classification, location map, timeline, and assignment info.
class ComplaintDetailScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailScreen({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    final complaintService = Provider.of<ComplaintService>(context);
    final complaintList = complaintService.complaints;

    final complaint = complaintList.firstWhere(
      (c) => c.complaintId == complaintId,
      orElse: () => ComplaintModel(
        complaintId: complaintId,
        userId: 'demo',
        citizenName: 'Demo Citizen',
        title: 'Road Pothole Near Market Square',
        description: 'Large pothole causing severe traffic congestion and hazards for two-wheelers.',
        category: ComplaintCategory.roadDamage,
        status: ComplaintStatus.inProgress,
        priority: ComplaintPriority.high,
        location: const ComplaintLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          address: 'Market Square, Sector 4, Central Avenue',
        ),
        images: const ComplaintImages(
          originalUrl: '',
          geoTaggedUrl: '',
        ),
        aiAnalysis: const AIAnalysisResult(
          category: ComplaintCategory.roadDamage,
          confidence: 0.94,
          priority: ComplaintPriority.high,
          severityScore: 8,
          duplicateProbability: 0.05,
          recommendedDepartment: Department.road,
        ),
        assignment: const ComplaintAssignment(
          department: Department.road,
          workerName: 'Rajesh Kumar (Senior Engineer)',
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Complaint #${complaint.complaintId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_rounded),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.complaintTracking,
              arguments: complaint.complaintId,
            ),
            tooltip: 'Track Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Geo-Tagged Image Banner ──────────────────────────────────────
            SizedBox(
              height: 220,
              width: double.infinity,
              child: _buildImage(
                complaint.images.geoTaggedUrl.isNotEmpty
                    ? complaint.images.geoTaggedUrl
                    : complaint.images.originalUrl,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Category & Status & Priority
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.getStatusColor(complaint.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ComplaintStatus.displayName(complaint.status),
                          style: TextStyle(
                            color: AppTheme.getStatusColor(complaint.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.getPriorityColor(complaint.priority).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ComplaintPriority.displayName(complaint.priority).toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.getPriorityColor(complaint.priority),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        AppDateUtils.formatDateTime(complaint.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    complaint.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                complaint.location.address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const SizedBox(width: 28),
                            Text(
                              'Lat: ${complaint.location.latitude.toStringAsFixed(6)}  Lng: ${complaint.location.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AI Analysis Card (if available)
                  if (complaint.aiAnalysis != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'AI Diagnostic Insights',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _aiInfoRow('Detected Category', ComplaintCategory.displayName(complaint.aiAnalysis!.category)),
                          _aiInfoRow('Confidence Score', '${(complaint.aiAnalysis!.confidence * 100).toStringAsFixed(1)}%'),
                          _aiInfoRow('Severity Level', '${complaint.aiAnalysis!.severityScore} / 10'),
                          _aiInfoRow('Recommended Dept.', complaint.aiAnalysis!.recommendedDepartment),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Timeline Section
                  const Text(
                    'Resolution Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  StatusTimeline(
                    currentStatus: complaint.status,
                    createdAt: complaint.createdAt,
                    resolvedAt: complaint.resolution?.resolvedAt,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildImage(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      return Image.network(urlOrPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _placeholder());
    } else if (urlOrPath.isNotEmpty && File(urlOrPath).existsSync()) {
      return Image.file(File(urlOrPath), fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city_rounded, color: Colors.white38, size: 54),
            SizedBox(height: 8),
            Text('Geo-Tagged Photo Attached', style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
