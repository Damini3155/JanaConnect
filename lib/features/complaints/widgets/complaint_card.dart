import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/utils/date_utils.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';

/// Reusable Complaint Card for Citizen and Admin list screens
class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryEmoji = ComplaintCategory.emoji(complaint.category);
    final categoryName = ComplaintCategory.displayName(complaint.category);
    final timeAgo = AppDateUtils.timeAgo(complaint.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap ??
            () => Navigator.pushNamed(
                  context,
                  AppRoutes.complaintDetail,
                  arguments: complaint.complaintId,
                ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status badge & Category
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(complaint.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ComplaintStatus.displayName(complaint.status),
                      style: TextStyle(
                        color: AppTheme.getStatusColor(complaint.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$categoryEmoji $categoryName',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Body: Image thumbnail + Title & Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: _buildImage(complaint.images.geoTaggedUrl.isNotEmpty
                          ? complaint.images.geoTaggedUrl
                          : complaint.images.originalUrl),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Title & Address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.onSurfaceMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                complaint.location.address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Footer: Priority badge & AI Tag if present
              if (complaint.aiAnalysis != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.outline),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'AI Categorized (${(complaint.aiAnalysis!.confidence * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.getPriorityColor(complaint.priority).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ComplaintPriority.displayName(complaint.priority).toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.getPriorityColor(complaint.priority),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('http')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) => _placeholder(),
      );
    } else if (pathOrUrl.isNotEmpty && File(pathOrUrl).existsSync()) {
      return Image.file(
        File(pathOrUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.onSurfaceMuted,
        size: 28,
      ),
    );
  }
}
