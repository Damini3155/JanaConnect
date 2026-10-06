import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/widgets/custom_error_widget.dart';
import 'package:geo_tag_camera/features/auth/services/auth_service.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';
import 'package:geo_tag_camera/features/complaints/widgets/complaint_card.dart';

/// Complaint List Screen for Citizens
class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final complaintService = Provider.of<ComplaintService>(context);

    final currentUser = authService.currentUser;
    final allComplaints = currentUser != null
        ? complaintService.getCitizenComplaints(currentUser.uid)
        : complaintService.complaints;

    final pendingList = allComplaints
        .where((c) =>
            c.status == ComplaintStatus.submitted ||
            c.status == ComplaintStatus.aiAnalyzed ||
            c.status == ComplaintStatus.underReview)
        .toList();

    final inProgressList = allComplaints
        .where((c) =>
            c.status == ComplaintStatus.assigned ||
            c.status == ComplaintStatus.inProgress)
        .toList();

    final resolvedList = allComplaints
        .where((c) =>
            c.status == ComplaintStatus.resolved ||
            c.status == ComplaintStatus.closed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Complaints'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'All (${allComplaints.length})'),
            Tab(text: 'Pending (${pendingList.length})'),
            Tab(text: 'Active (${inProgressList.length})'),
            Tab(text: 'Fixed (${resolvedList.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(allComplaints, 'No complaints submitted yet'),
          _buildList(pendingList, 'No pending complaints'),
          _buildList(inProgressList, 'No active complaints in progress'),
          _buildList(resolvedList, 'No resolved complaints yet'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.geoTagCamera),
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('New Complaint'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Widget _buildList(List list, String emptyTitle) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        subtitle: 'Tap the camera button below to snap and submit a geo-tagged issue.',
        icon: Icons.camera_alt_outlined,
        actionLabel: 'Report Issue',
        onAction: () => Navigator.pushNamed(context, AppRoutes.geoTagCamera),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ComplaintCard(complaint: list[index]);
      },
    );
  }
}
