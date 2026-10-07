import 'package:camera/camera.dart' as cam_pkg;
import 'package:flutter/foundation.dart';

/// Camera service wrapping Flutter camera lifecycle and capture features.
class CameraService {
  cam_pkg.CameraController? _controller;
  List<cam_pkg.CameraDescription> _availableCameras = [];
  bool _isInitialized = false;

  cam_pkg.CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;
  List<cam_pkg.CameraDescription> get camerasList => _availableCameras;

  /// Initialize available cameras and select back camera by default
  Future<bool> initialize(List<cam_pkg.CameraDescription> initialCameras) async {
    _availableCameras = initialCameras;
    if (_availableCameras.isEmpty) {
      try {
        _availableCameras = await cam_pkg.availableCameras();
      } catch (e) {
        debugPrint('Camera discovery error: $e');
        return false;
      }
    }

    if (_availableCameras.isEmpty) return false;

    // Prefer rear camera
    cam_pkg.CameraDescription selectedCamera = _availableCameras.first;
    for (final cam in _availableCameras) {
      if (cam.lensDirection == cam_pkg.CameraLensDirection.back) {
        selectedCamera = cam;
        break;
      }
    }

    _controller = cam_pkg.CameraController(
      selectedCamera,
      cam_pkg.ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: cam_pkg.ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Camera controller init error: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Capture photo from live camera stream
  Future<cam_pkg.XFile?> takePicture() async {
    if (!isInitialized) return null;
    try {
      final photo = await _controller!.takePicture();
      return photo;
    } catch (e) {
      debugPrint('Photo capture error: $e');
      return null;
    }
  }

  /// Toggle flash mode (off/auto/always)
  Future<void> toggleFlash(cam_pkg.FlashMode mode) async {
    if (!isInitialized) return;
    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      debugPrint('Flash mode error: $e');
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    _isInitialized = false;
    await _controller?.dispose();
    _controller = null;
  }
}
