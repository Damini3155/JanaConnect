import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize available cameras gracefully
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera Initialization Error: $e');
  }

  runApp(MunicipalApp(cameras: cameras));
}