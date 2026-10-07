import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/features/auth/services/auth_service.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';

/// Admin Dashboard Screen — Overview of all municipal complaints, status metrics, and department routing.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final complaintService = Provider.of<ComplaintService>(context);

    final allComplaints = complaintService.complaints;

    final totalCount = allComplaints.length;
    final pendingCount = allComplaints
        .where((c) =>
            c.status == ComplaintStatus.submitted ||
            c.status == ComplaintStatus.aiAnalyzed ||
            c.status == ComplaintStatus.underReview)
        .length;
    final assignedCount = allComplaints
        .where((c) => c.status == ComplaintStatus.assigned || c.status == ComplaintStatus.inProgress)
        .length;
    final resolvedCount = allComplaints
        .where((c) => c.status == ComplaintStatus.resolved || c.status == ComplaintStatus.closed)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('${AppConstants.appName} Admin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AppConstants.appTagline,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.admin_panel_settings, color: Colors.white30, size: 48),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Metrics Row
            Row(
              children: [
                _AdminStatCard('Total', '$totalCount', AppColors.info, Icons.inbox_rounded),
                const SizedBox(width: 10),
                _AdminStatCard('Pending', '$pendingCount', AppColors.warning, Icons.pending_actions_rounded),
                const SizedBox(width: 10),
                _AdminStatCard('Assigned', '$assignedCount', AppColors.accent, Icons.engineering_rounded),
                const SizedBox(width: 10),
                _AdminStatCard('Resolved', '$resolvedCount', AppColors.success, Icons.task_alt_rounded),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Access Modules
            const Text(
              'Management Modules',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            _adminTile(
              'All Complaints Directory',
              'View, filter, and assign field officers',
              Icons.list_alt_rounded,
              AppRoutes.adminComplaints,
              context,
            ),
            const SizedBox(height: 10),
            _adminTile(
              'Geographic Map View',
              'Plot complaint coordinates on municipal map',
              Icons.map_rounded,
              AppRoutes.complaintMap,
              context,
            ),
            const SizedBox(height: 10),
            _adminTile(
              'Analytics & Performance',
              'Resolution times and departmental breakdown',
              Icons.bar_chart_rounded,
              AppRoutes.analytics,
              context,
            ),

            const SizedBox(height: 24),

            // Department Breakdown Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Departments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _deptRow(Department.sanitation, Icons.cleaning_services_outlined, AppColors.accent),
                  _deptRow(Department.road, Icons.add_road_rounded, AppColors.warning),
                  _deptRow(Department.water, Icons.water_drop_outlined, AppColors.info),
                  _deptRow(Department.electricity, Icons.lightbulb_outline_rounded, AppColors.secondary),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _adminTile(
    String title,
    String subtitle,
    IconData icon,
    String route,
    BuildContext ctx,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceMuted),
        onTap: () => Navigator.pushNamed(ctx, route),
      ),
    );
  }

  Widget _deptRow(String name, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Active',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData icon;

  const _AdminStatCard(this.label, this.count, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
