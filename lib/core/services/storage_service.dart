import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Local storage service for permanent complaint photos and gallery saving.
class StorageService {
  /// Save image file to user's device gallery (Photo Gallery / Camera Roll)
  Future<bool> saveToGallery(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) return false;

      // gal API: Gal.putImage(path)
      await Gal.putImage(filePath);
      debugPrint('StorageService: Saved to gallery — $filePath');
      return true;
    } catch (e) {
      debugPrint('StorageService.saveToGallery error: $e');
      return false;
    }
  }

  /// Permanent local directory path for complaint photos
  Future<String> getComplaintPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'complaints_media'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir.path;
  }
}
