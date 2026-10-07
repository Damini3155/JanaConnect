import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/features/auth/services/auth_service.dart';
import 'package:geo_tag_camera/features/auth/screens/splash_screen.dart';
import 'package:geo_tag_camera/features/auth/screens/login_screen.dart';
import 'package:geo_tag_camera/features/auth/screens/register_screen.dart';
import 'package:geo_tag_camera/features/citizen/screens/citizen_home_screen.dart';
import 'package:geo_tag_camera/features/citizen/screens/citizen_profile_screen.dart';
import 'package:geo_tag_camera/features/camera/screens/geo_tag_camera_screen.dart';
import 'package:geo_tag_camera/features/camera/screens/photo_preview_screen.dart';
import 'package:geo_tag_camera/features/complaints/screens/complaint_form_screen.dart';
import 'package:geo_tag_camera/features/complaints/screens/complaint_list_screen.dart';
import 'package:geo_tag_camera/features/complaints/screens/complaint_detail_screen.dart';
import 'package:geo_tag_camera/features/complaints/screens/complaint_tracking_screen.dart';
import 'package:geo_tag_camera/features/admin/screens/admin_dashboard_screen.dart';
import 'package:geo_tag_camera/features/admin/screens/admin_complaints_screen.dart';
import 'package:geo_tag_camera/features/admin/screens/complaint_map_screen.dart';
import 'package:geo_tag_camera/features/admin/screens/analytics_screen.dart';
import 'package:geo_tag_camera/features/worker/screens/worker_home_screen.dart';
import 'package:geo_tag_camera/features/worker/screens/assigned_complaints_screen.dart';

import 'package:geo_tag_camera/features/complaints/services/complaint_service.dart';

/// Root of the application.
/// Wrap with MultiProvider to make AuthService & ComplaintService available globally.
class MunicipalApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MunicipalApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ComplaintService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Municipal Complaint System',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) => _generateRoute(settings, cameras),
      ),
    );
  }
}

/// Central route generator — keeps all routing in one place.
Route<dynamic> _generateRoute(
  RouteSettings settings,
  List<CameraDescription> cameras,
) {
  switch (settings.name) {
    // ── Core ─────────────────────────────────────────────────────────────────
    case AppRoutes.splash:
      return _fadeRoute(const SplashScreen(), settings);

    case AppRoutes.login:
      return _slideRoute(const LoginScreen(), settings);

    case AppRoutes.register:
      return _slideRoute(const RegisterScreen(), settings);

    // ── Citizen ───────────────────────────────────────────────────────────────
    case AppRoutes.citizenHome:
      return _fadeRoute(const CitizenHomeScreen(), settings);

    case AppRoutes.citizenProfile:
      return _slideRoute(const CitizenProfileScreen(), settings);

    // ── Camera ────────────────────────────────────────────────────────────────
    case AppRoutes.geoTagCamera:
      return _slideRoute(
        GeoTagCameraScreen(cameras: cameras),
        settings,
      );

    case AppRoutes.photoPreview:
      final args = settings.arguments as Map<String, dynamic>?;
      return _slideRoute(
        PhotoPreviewScreen(
          imagePath: args?['imagePath'] as String? ?? '',
          latitude: args?['latitude'] as double?,
          longitude: args?['longitude'] as double?,
          address: args?['address'] as String?,
          timestamp: args?['timestamp'] as DateTime?,
        ),
        settings,
      );

    // ── Complaints ────────────────────────────────────────────────────────────
    case AppRoutes.complaintForm:
      final args = settings.arguments as Map<String, dynamic>?;
      return _slideRoute(
        ComplaintFormScreen(capturedData: args ?? {}),
        settings,
      );

    case AppRoutes.complaintList:
      return _slideRoute(const ComplaintListScreen(), settings);

    case AppRoutes.complaintDetail:
      final complaintId = settings.arguments as String? ?? '';
      return _slideRoute(
        ComplaintDetailScreen(complaintId: complaintId),
        settings,
      );

    case AppRoutes.complaintTracking:
      final complaintId = settings.arguments as String? ?? '';
      return _slideRoute(
        ComplaintTrackingScreen(complaintId: complaintId),
        settings,
      );

    // ── Admin ─────────────────────────────────────────────────────────────────
    case AppRoutes.adminDashboard:
      return _fadeRoute(const AdminDashboardScreen(), settings);

    case AppRoutes.adminComplaints:
      return _slideRoute(const AdminComplaintsScreen(), settings);

    case AppRoutes.complaintMap:
      return _slideRoute(const ComplaintMapScreen(), settings);

    case AppRoutes.analytics:
      return _slideRoute(const AnalyticsScreen(), settings);

    // ── Worker ────────────────────────────────────────────────────────────────
    case AppRoutes.workerHome:
      return _fadeRoute(const WorkerHomeScreen(), settings);

    case AppRoutes.assignedComplaints:
      return _slideRoute(const AssignedComplaintsScreen(), settings);

    // ── Fallback ─────────────────────────────────────────────────────────────
    default:
      return _fadeRoute(
        Scaffold(
          body: Center(
            child: Text(
              'Route not found: ${settings.name}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        settings,
      );
  }
}

/// Smooth fade transition
PageRoute<T> _fadeRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, anim1, anim2) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// Slide-up transition (modal feel)
PageRoute<T> _slideRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, anim1, anim2) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
