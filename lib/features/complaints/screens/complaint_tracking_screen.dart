import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';
import 'package:geo_tag_camera/features/complaints/widgets/status_timeline.dart';

/// Dedicated Complaint Status Tracking Screen
class ComplaintTrackingScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintTrackingScreen({
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
        citizenName: 'Citizen',
        title: 'Road Pothole',
        description: 'Pothole issue',
        category: ComplaintCategory.roadDamage,
        status: ComplaintStatus.inProgress,
        priority: ComplaintPriority.high,
        location: const ComplaintLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          address: 'Central Avenue',
        ),
        images: const ComplaintImages(originalUrl: '', geoTaggedUrl: ''),
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Complaint'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket #${complaint.complaintId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            complaint.title,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ComplaintStatus.displayName(complaint.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Live Tracking Steps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // Step-by-step Timeline
              StatusTimeline(
                currentStatus: complaint.status,
                createdAt: complaint.createdAt,
                resolvedAt: complaint.resolution?.resolvedAt,
              ),

              const SizedBox(height: 20),

              // Worker assignment box if assigned
              if (complaint.assignment?.workerName != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.engineering, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned Field Officer',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
                            ),
                            Text(
                              complaint.assignment!.workerName!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
