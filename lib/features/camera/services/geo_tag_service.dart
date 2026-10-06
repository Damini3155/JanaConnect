import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geo_tag_camera/core/services/location_service.dart';
import 'package:geo_tag_camera/core/utils/date_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Geo-tag photo data payload holding local file paths and location metadata.
class GeoTaggedPhoto {
  final String originalPath;
  final String? geoTaggedPath;
  final GeoLocationData locationData;
  final DateTime capturedAt;

  const GeoTaggedPhoto({
    required this.originalPath,
    this.geoTaggedPath,
    required this.locationData,
    required this.capturedAt,
  });

  String get displayStamp =>
      '${AppDateUtils.formatGeoTagStamp(capturedAt)}\n'
      '${locationData.address}\n'
      '${locationData.formattedCoordinates}';
}

/// Geo-tag service managing captured photo files and location binding.
class GeoTagService {
  /// Save captured photo to application document directory
  Future<GeoTaggedPhoto> processCapturedPhoto({
    required String rawImagePath,
    required GeoLocationData locationData,
  }) async {
    final now = DateTime.now();
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'complaint_photos'));

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final filename = 'IMG_${now.millisecondsSinceEpoch}.jpg';
    final savedPath = p.join(photosDir.path, filename);

    final rawFile = File(rawImagePath);
    await rawFile.copy(savedPath);

    debugPrint('GeoTagService: Photo saved permanently to $savedPath');

    return GeoTaggedPhoto(
      originalPath: savedPath,
      geoTaggedPath: savedPath,
      locationData: locationData,
      capturedAt: now,
    );
  }
}
