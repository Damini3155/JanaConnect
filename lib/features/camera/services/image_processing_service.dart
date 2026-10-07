import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:geo_tag_camera/core/services/location_service.dart';
import 'package:geo_tag_camera/core/utils/date_utils.dart';
import 'package:path/path.dart' as p;

/// Service for burning permanent geo-tag watermarks onto images.
class ImageProcessingService {
  /// Draw geo-tag information box on the bottom of the photo and save as new file.
  Future<String> addGeoTagWatermark({
    required String originalImagePath,
    required GeoLocationData locationData,
  }) async {
    return compute(_drawWatermarkTask, {
      'path': originalImagePath,
      'address': locationData.address,
      'lat': locationData.latitude,
      'lng': locationData.longitude,
      'timestamp': locationData.timestamp.toIso8601String(),
    });
  }
}

/// Top-level function executed in background isolate via compute()
Future<String> _drawWatermarkTask(Map<String, dynamic> params) async {
  final String originalPath = params['path'] as String;
  final String address = params['address'] as String;
  final double lat = params['lat'] as double;
  final double lng = params['lng'] as double;
  final DateTime timestamp = DateTime.parse(params['timestamp'] as String);

  final File originalFile = File(originalPath);
  final Uint8List bytes = await originalFile.readAsBytes();
  final img.Image? decodedImage = img.decodeImage(bytes);

  if (decodedImage == null) {
    throw Exception('Failed to decode image for watermarking.');
  }

  // Draw semi-transparent banner at the bottom of the image
  final int bannerHeight = (decodedImage.height * 0.18).round().clamp(120, 260);
  final int bannerY = decodedImage.height - bannerHeight;

  // Draw dark rectangle background
  img.fillRect(
    decodedImage,
    x1: 0,
    y1: bannerY,
    x2: decodedImage.width,
    y2: decodedImage.height,
    color: img.ColorRgba8(0, 0, 0, 180),
  );

  // Format strings
  final dateStr = AppDateUtils.formatGeoTagStamp(timestamp);
  final coordsStr = 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
  final line1 = 'GEO-TAGGED COMPLAINT PHOTO  |  $dateStr';
  final line2 = 'LOCATION: $address';
  final line3 = coordsStr;

  // Draw text onto banner
  img.drawString(
    decodedImage,
    line1,
    font: img.arial14,
    x: 20,
    y: bannerY + 15,
    color: img.ColorRgba8(255, 255, 255, 255),
  );

  img.drawString(
    decodedImage,
    line2,
    font: img.arial14,
    x: 20,
    y: bannerY + 45,
    color: img.ColorRgba8(255, 220, 100, 255),
  );

  img.drawString(
    decodedImage,
    line3,
    font: img.arial14,
    x: 20,
    y: bannerY + 75,
    color: img.ColorRgba8(200, 200, 200, 255),
  );

  // Encode watermarked image to JPEG
  final Uint8List watermarkedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));

  // Save to new file
  final dir = originalFile.parent.path;
  final filename = 'GEOTAG_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final watermarkedPath = p.join(dir, filename);
  final watermarkedFile = File(watermarkedPath);
  await watermarkedFile.writeAsBytes(watermarkedBytes);

  return watermarkedPath;
}
