import 'package:flutter/foundation.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/features/auth/models/user_model.dart';

/// Authentication Service
/// Handles user login, registration, role fetching, and session state.
class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String get currentRole => _currentUser?.role ?? UserRole.citizen;

  /// Login with email & password
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Determine mock role based on email or default to citizen
    String role = UserRole.citizen;
    if (email.contains('admin')) {
      role = UserRole.admin;
    } else if (email.contains('worker')) {
      role = UserRole.worker;
    }

    _currentUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    _setLoading(false);
    notifyListeners();
    return _currentUser;
  }

  /// Register new citizen user
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: UserRole.citizen,
      createdAt: DateTime.now(),
    );

    _setLoading(false);
    notifyListeners();
    return _currentUser;
  }

  /// Direct role switch for dev preview / testing
  void devSwitchRole(String role) {
    _currentUser = UserModel(
      uid: 'dev_${role}_123',
      name: 'Demo ${role.toUpperCase()}',
      email: '$role@municipal.gov.in',
      role: role,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Sign out current user
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
