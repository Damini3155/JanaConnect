import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';

/// Photo Preview Screen shown after capturing a geo-tagged photo.
class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime? timestamp;

  const PhotoPreviewScreen({
    super.key,
    required this.imagePath,
    this.latitude,
    this.longitude,
    this.address,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Photo Preview',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: imagePath.isNotEmpty
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 60,
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              children: [
                if (address != null)
                  _InfoRow(Icons.location_on_outlined, address!),
                if (latitude != null && longitude != null)
                  _InfoRow(
                    Icons.my_location_outlined,
                    'Lat: ${latitude!.toStringAsFixed(6)}  Lng: ${longitude!.toStringAsFixed(6)}',
                  ),
                if (timestamp != null)
                  _InfoRow(
                    Icons.access_time_outlined,
                    '${timestamp!.day}/${timestamp!.month}/${timestamp!.year}  '
                        '${timestamp!.hour.toString().padLeft(2, '0')}:${timestamp!.minute.toString().padLeft(2, '0')}',
                  ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white),
                        label: const Text(
                          'Retake',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.complaintForm,
                            arguments: {
                              'imagePath': imagePath,
                              'latitude': latitude,
                              'longitude': longitude,
                              'address': address,
                              'timestamp': timestamp,
                            },
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Submit Complaint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
