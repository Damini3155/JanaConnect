import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/features/auth/services/auth_service.dart';
import 'package:geo_tag_camera/features/ai/services/ai_orchestrator.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';
import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';
import 'package:geo_tag_camera/features/complaints/widgets/voice_recorder_widget.dart';

/// Complaint Form Screen
/// Responsive, accessible form for citizens to submit a complaint with optional voice note.
class ComplaintFormScreen extends StatefulWidget {
  final Map<String, dynamic> capturedData;

  const ComplaintFormScreen({
    super.key,
    required this.capturedData,
  });

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AIOrchestrator _aiOrchestrator = AIOrchestrator();

  String _selectedCategory = ComplaintCategory.garbageWaste;
  String? _recordedAudioPath;
  bool _isSubmitting = false;
  String _aiProgressMessage = 'Analyzing complaint...';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _imagePath => widget.capturedData['imagePath'] as String? ?? '';
  double get _latitude => (widget.capturedData['latitude'] as num?)?.toDouble() ?? 0.0;
  double get _longitude => (widget.capturedData['longitude'] as num?)?.toDouble() ?? 0.0;
  String get _address => widget.capturedData['address'] as String? ?? 'Location captured';

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _aiProgressMessage = 'Verifying complaint & routing team...';
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final complaintService = Provider.of<ComplaintService>(context, listen: false);
    final user = authService.currentUser;

    final aiResult = await _aiOrchestrator.analyzeComplaint(
      imagePath: _imagePath,
      description: _descriptionController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      existingComplaints: complaintService.complaints,
    );

    if (!mounted) return;

    final now = DateTime.now();
    final complaintId = 'CMP${now.millisecondsSinceEpoch.toString().substring(5)}';

    final complaint = ComplaintModel(
      complaintId: complaintId,
      userId: user?.uid ?? 'anon_user',
      citizenName: user?.name ?? 'Anonymous Citizen',
      title: _titleController.text.trim().isEmpty ? 'Civic Grievance' : _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: aiResult.category,
      status: ComplaintStatus.submitted,
      priority: aiResult.priority,
      location: ComplaintLocation(
        latitude: _latitude,
        longitude: _longitude,
        address: _address,
      ),
      images: ComplaintImages(
        originalUrl: _imagePath,
        geoTaggedUrl: _imagePath,
      ),
      aiAnalysis: aiResult,
      assignment: ComplaintAssignment(
        department: aiResult.recommendedDepartment,
      ),
      audioPath: _recordedAudioPath,
      createdAt: now,
      updatedAt: now,
    );

    await complaintService.submitComplaint(complaint);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
        ),
        title: const Text('Complaint Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Complaint ID: #${complaint.complaintId}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Text('• Department: ${aiResult.recommendedDepartment}'),
            Text('• Location: $_address'),
            if (_recordedAudioPath != null)
              const Text('• Voice Note Attached ✓', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.citizenHome,
                  (route) => false,
                );
              },
              child: const Text('Done / Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit Complaint'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Captured Image Preview with GeoTag Badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          _imagePath.isNotEmpty
                              ? Image.file(
                                  File(_imagePath),
                                  width: double.infinity,
                                  height: constraints.maxWidth > 600 ? 300 : 200,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 180,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.image, size: 50),
                                ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '📍 $_address',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Voice Complaint Recorder Widget
                    VoiceRecorderWidget(
                      onAudioRecorded: (path) => setState(() => _recordedAudioPath = path),
                      onAudioDeleted: () => setState(() => _recordedAudioPath = null),
                    ),

                    const SizedBox(height: 20),

                    // Category Selector
                    const Text(
                      'Issue Category *',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: ComplaintCategory.all.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text('${ComplaintCategory.emoji(cat)}  ${ComplaintCategory.displayName(cat)}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description Input
                    const Text(
                      'Complaint Details / Landmarks',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Describe the problem or landmark (e.g. Near Bus Stand)...',
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit CTA
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitComplaint,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isSubmitting ? _aiProgressMessage : 'Submit Complaint (तक्रार नोंदवा)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
