import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/features/camera/widgets/geo_tag_overlay.dart';
import 'package:geo_tag_camera/features/camera/widgets/camera_controls.dart';
import 'package:geo_tag_camera/features/camera/widgets/gps_status_badge.dart';

/// Geo-Tag Camera Screen
class GeoTagCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const GeoTagCameraScreen({super.key, required this.cameras});

  @override
  State<GeoTagCameraScreen> createState() => _GeoTagCameraScreenState();
}

class _GeoTagCameraScreenState extends State<GeoTagCameraScreen> {
  CameraController? _controller;

  bool _isCameraReady = false;
  bool _isLoadingLocation = true;
  bool _isCapturing = false;

  double? _latitude;
  double? _longitude;
  double? _accuracy;

  String _address = 'Getting location...';
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getLocation();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    CameraDescription camera = widget.cameras.first;
    for (final cam in widget.cameras) {
      if (cam.lensDirection == CameraLensDirection.back) {
        camera = cam;
        break;
      }
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _address = 'Acquiring GPS location...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showEnableGpsDialog();
        }
        _setLocationError('GPS Location Services Disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setLocationError('Location Permission Denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionSettingsDialog();
        }
        _setLocationError('Location Permission Denied in Settings');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _accuracy = position.accuracy;

      await _getAddress(_latitude!, _longitude!);

      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _currentTime = DateTime.now();
      });
    } catch (e) {
      debugPrint('Location Error: $e');
      _setLocationError('Unable to lock GPS location');
    }
  }

  void _showEnableGpsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error),
            SizedBox(width: 8),
            Text('Turn On GPS Location'),
          ],
        ),
        content: const Text(
          'PCMC JanConnect needs high-accuracy GPS to automatically pin your complaint location for municipal team action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              _getLocation();
            },
            child: const Text('Enable GPS'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Needed'),
        content: const Text(
          'Location access is permanently disabled. Please allow location permission from app settings to geotag your report.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _address = message;
      _isLoadingLocation = false;
    });
  }

  Future<void> _getAddress(double lat, double lng) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        if (!mounted) return;
        setState(() {
          _address = [
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join(', ');

          if (_address.isEmpty) {
            _address = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
          }
        });
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
      if (!mounted) return;
      setState(() => _address = 'Address not available');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      _currentTime = DateTime.now();
      final XFile photo = await _controller!.takePicture();

      debugPrint('Photo captured: ${photo.path}');

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.photoPreview,
        arguments: {
          'imagePath': photo.path,
          'latitude': _latitude,
          'longitude': _longitude,
          'address': _address,
          'timestamp': _currentTime,
          'accuracy': _accuracy,
        },
      );
    } catch (e) {
      debugPrint('Capture Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white54),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_controller!),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: GpsStatusBadge(
                isLoading: _isLoadingLocation,
                hasLocation: _latitude != null,
              ),
            ),
            Positioned(
              left: 15,
              right: 15,
              bottom: 140,
              child: GeoTagOverlay(
                address: _address,
                latitude: _latitude,
                longitude: _longitude,
                timestamp: _currentTime,
                isLoading: _isLoadingLocation,
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: CameraControls(
                onCapture: _capturePhoto,
                onRefreshLocation: _getLocation,
                isCapturing: _isCapturing,
                hasLocation: _latitude != null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
