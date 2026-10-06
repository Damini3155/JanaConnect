import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/widgets/custom_error_widget.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';
import 'package:geo_tag_camera/features/complaints/widgets/complaint_card.dart';

/// Admin Complaints Screen
/// Admin portal to search, inspect, filter, and assign field workers to complaints.
class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String? _selectedStatusFilter;
  String _searchQuery = '';

  void _showAssignWorkerDialog(BuildContext context, String complaintId) {
    final workerController = TextEditingController();
    String selectedDept = Department.general;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.engineering_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Assign Field Officer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Department', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedDept,
              items: [
                Department.general,
                Department.sanitation,
                Department.road,
                Department.water,
                Department.electricity,
                Department.drainage,
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) {
                if (val != null) selectedDept = val;
              },
            ),
            const SizedBox(height: 16),
            const Text('Officer Name / ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: workerController,
              decoration: const InputDecoration(
                hintText: 'e.g. Officer Rajesh (WRK-102)',
                prefixIcon: Icon(Icons.person_outline),
              ),
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
              if (workerController.text.trim().isEmpty) return;
              final complaintService = Provider.of<ComplaintService>(context, listen: false);
              await complaintService.assignWorker(
                complaintId: complaintId,
                department: selectedDept,
                workerId: 'wrk_${DateTime.now().millisecondsSinceEpoch}',
                workerName: workerController.text.trim(),
                assignedBy: 'Admin',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Field officer assigned successfully!')),
                );
              }
            },
            child: const Text('Assign Officer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintService = Provider.of<ComplaintService>(context);
    var list = complaintService.complaints;

    if (_selectedStatusFilter != null) {
      list = list.where((c) => c.status == _selectedStatusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((c) =>
              c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.location.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.complaintId.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Complaints Directory'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search by ID, title, or location...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedStatusFilter == null,
                          onSelected: (_) => setState(() => _selectedStatusFilter = null),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Submitted'),
                          selected: _selectedStatusFilter == ComplaintStatus.submitted,
                          onSelected: (_) => setState(() => _selectedStatusFilter = ComplaintStatus.submitted),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Assigned'),
                          selected: _selectedStatusFilter == ComplaintStatus.assigned,
                          onSelected: (_) => setState(() => _selectedStatusFilter = ComplaintStatus.assigned),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('In Progress'),
                          selected: _selectedStatusFilter == ComplaintStatus.inProgress,
                          onSelected: (_) => setState(() => _selectedStatusFilter = ComplaintStatus.inProgress),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Resolved'),
                          selected: _selectedStatusFilter == ComplaintStatus.resolved,
                          onSelected: (_) => setState(() => _selectedStatusFilter = ComplaintStatus.resolved),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Complaints List
            Expanded(
              child: list.isEmpty
                  ? EmptyStateWidget(
                      title: 'No complaints found',
                      subtitle: _searchQuery.isNotEmpty || _selectedStatusFilter != null
                          ? 'Try clearing your filters or search terms.'
                          : 'No citizen complaints in the system yet.',
                      icon: Icons.inbox_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final complaint = list[index];
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
                            // Quick Admin Assign Bar
                            if (complaint.status == ComplaintStatus.submitted ||
                                complaint.status == ComplaintStatus.aiAnalyzed ||
                                complaint.status == ComplaintStatus.underReview) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showAssignWorkerDialog(context, complaint.complaintId),
                                    icon: const Icon(Icons.engineering_rounded, size: 16),
                                    label: const Text('Assign Field Worker', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
