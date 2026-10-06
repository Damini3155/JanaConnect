import 'package:flutter/material.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/utils/date_utils.dart';

class TimelineStep {
  final String status;
  final String title;
  final String description;
  final DateTime? timestamp;

  const TimelineStep({
    required this.status,
    required this.title,
    required this.description,
    this.timestamp,
  });
}

/// Visual Step-by-Step Status Timeline Widget
class StatusTimeline extends StatelessWidget {
  final String currentStatus;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const StatusTimeline({
    super.key,
    required this.currentStatus,
    required this.createdAt,
    this.resolvedAt,
  });

  List<TimelineStep> get _steps => [
        TimelineStep(
          status: ComplaintStatus.submitted,
          title: 'Complaint Submitted',
          description: 'Received & logged into system',
          timestamp: createdAt,
        ),
        TimelineStep(
          status: ComplaintStatus.aiAnalyzed,
          title: 'AI Classification',
          description: 'Category & priority analyzed',
          timestamp: createdAt.add(const Duration(minutes: 1)),
        ),
        TimelineStep(
          status: ComplaintStatus.underReview,
          title: 'Under Admin Review',
          description: 'Assigned to municipal department',
        ),
        TimelineStep(
          status: ComplaintStatus.assigned,
          title: 'Field Worker Assigned',
          description: 'Dispatched to local team',
        ),
        TimelineStep(
          status: ComplaintStatus.inProgress,
          title: 'Work In Progress',
          description: 'On-site resolution ongoing',
        ),
        TimelineStep(
          status: ComplaintStatus.resolved,
          title: 'Resolved & Closed',
          description: 'Issue fixed with after-photo',
          timestamp: resolvedAt,
        ),
      ];

  int _getStepIndex(String status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 0;
      case ComplaintStatus.aiAnalyzed:
        return 1;
      case ComplaintStatus.underReview:
        return 2;
      case ComplaintStatus.assigned:
        return 3;
      case ComplaintStatus.inProgress:
        return 4;
      case ComplaintStatus.resolved:
      case ComplaintStatus.closed:
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _getStepIndex(currentStatus);

    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isPassed = index <= activeIndex;
        final isCurrent = index == activeIndex;
        final isLast = index == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + indicator circle
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : isPassed
                            ? AppColors.success
                            : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : isPassed
                              ? AppColors.success
                              : AppColors.outline,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isPassed ? Icons.check : Icons.circle,
                    size: 14,
                    color: isPassed ? Colors.white : AppColors.onSurfaceMuted,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 44,
                    color: isPassed ? AppColors.success : AppColors.outline,
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Step details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                            color: isPassed ? AppColors.onSurface : AppColors.onSurfaceMuted,
                          ),
                        ),
                        const Spacer(),
                        if (step.timestamp != null)
                          Text(
                            AppDateUtils.formatDateTime(step.timestamp!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPassed ? AppColors.onSurfaceVariant : AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
