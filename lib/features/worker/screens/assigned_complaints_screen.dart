import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/widgets/custom_error_widget.dart';
import 'package:geo_tag_camera/features/auth/services/auth_service.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';
import 'package:geo_tag_camera/features/complaints/widgets/complaint_card.dart';

/// Assigned Complaints Screen for Field Workers
class AssignedComplaintsScreen extends StatelessWidget {
  const AssignedComplaintsScreen({super.key});

  void _showResolveDialog(BuildContext context, String complaintId) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Complete Resolution'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resolution Notes & Actions Taken',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Repaired broken pipe, cleared debris, and tested water flow.',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera opened for completion photo capture')),
                );
              },
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Attach After-Work Photo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (notesController.text.trim().isEmpty) return;
              final authService = Provider.of<AuthService>(context, listen: false);
              final complaintService = Provider.of<ComplaintService>(context, listen: false);

              await complaintService.resolveComplaint(
                complaintId: complaintId,
                resolvedBy: authService.currentUser?.name ?? 'Field Worker',
                notes: notesController.text.trim(),
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint marked RESOLVED! Notification sent to citizen.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final complaintService = Provider.of<ComplaintService>(context);

    final currentUser = authService.currentUser;
    final assignedList = currentUser != null
        ? complaintService.getWorkerComplaints(currentUser.uid)
        : complaintService.complaints;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assigned Field Tasks'),
      ),
      body: SafeArea(
        child: assignedList.isEmpty
            ? const EmptyStateWidget(
                title: 'No tasks assigned',
                subtitle: 'Check back later or refresh when municipal admin dispatches new tickets.',
                icon: Icons.task_outlined,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: assignedList.length,
                itemBuilder: (context, index) {
                  final complaint = assignedList[index];
                  final isResolved = complaint.status == ComplaintStatus.resolved;

                  return Column(
                    children: [
                      ComplaintCard(
                        complaint: complaint,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.complaintDetail,
                          arguments: complaint.complaintId,
                        ),
                      ),
                      if (!isResolved) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await complaintService.updateComplaintStatus(
                                    complaint.complaintId,
                                    ComplaintStatus.inProgress,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Status updated to IN PROGRESS')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.build_outlined, size: 16),
                                label: const Text('Start Work', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showResolveDialog(context, complaint.complaintId),
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('Mark Resolved', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }
}
