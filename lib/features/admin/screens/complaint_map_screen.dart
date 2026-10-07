import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';

/// Geographic Complaint Location Map View
class ComplaintMapScreen extends StatefulWidget {
  const ComplaintMapScreen({super.key});

  @override
  State<ComplaintMapScreen> createState() => _ComplaintMapScreenState();
}

class _ComplaintMapScreenState extends State<ComplaintMapScreen> {
  ComplaintModel? _selectedComplaint;

  @override
  Widget build(BuildContext context) {
    final complaintService = Provider.of<ComplaintService>(context);
    final complaints = complaintService.complaints;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complaint Map View'),
      ),
      body: Stack(
        children: [
          // ── Simulated Interactive Map Container ────────────────────────────
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE5E9F0),
              child: Stack(
                children: [
                  // Map background grid styling
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MapGridPainter(),
                  ),

                  const Center(
                    child: Text(
                      'Interactive Geographic Map\n(Municipal Area Grid)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Pins for complaints
                  if (complaints.isNotEmpty)
                    ...complaints.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final c = entry.value;
                      // Spread pins evenly across screen for visual map representation
                      final topOffset = 120.0 + (idx * 90.0) % 400;
                      final leftOffset = 60.0 + (idx * 110.0) % 280;

                      return Positioned(
                        top: topOffset,
                        left: leftOffset,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedComplaint = c);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.getStatusColor(c.status),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Text(
                                  '#${c.complaintId}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: AppTheme.getStatusColor(c.status),
                                size: 36,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),

          // ── Top Category Legend ───────────────────────────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _legendItem('Submitted', AppColors.statusSubmitted),
                    const SizedBox(width: 12),
                    _legendItem('Assigned', AppColors.statusAssigned),
                    const SizedBox(width: 12),
                    _legendItem('In Progress', AppColors.statusInProgress),
                    const SizedBox(width: 12),
                    _legendItem('Resolved', AppColors.statusResolved),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Selected Complaint Card ────────────────────────────────
          if (_selectedComplaint != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getStatusColor(_selectedComplaint!.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ComplaintStatus.displayName(_selectedComplaint!.status),
                              style: TextStyle(
                                color: AppTheme.getStatusColor(_selectedComplaint!.status),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _selectedComplaint = null),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedComplaint!.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedComplaint!.location.address,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.complaintDetail,
                            arguments: _selectedComplaint!.complaintId,
                          ),
                          child: const Text('View Full Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
  ..color = Colors.black.withOpacity(0.04)
  ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
