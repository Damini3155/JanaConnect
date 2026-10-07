import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geo_tag_camera/app/routes.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';
import 'package:geo_tag_camera/core/widgets/app_logo.dart';
import 'package:geo_tag_camera/features/auth/services/auth_service.dart';

/// Simplified Login screen with Mobile OTP as primary and separate Employee login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '98220 14820');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isOtpMode = true;
  bool _obscurePassword = true;
  String _selectedLang = 'English';

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.devSwitchRole(UserRole.citizen);
    Navigator.pushReplacementNamed(context, AppRoutes.citizenHome);
  }

  void _onPasswordLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.login(
      email: _emailController.text.trim().isEmpty
          ? 'citizen@pcmc.gov.in'
          : _emailController.text.trim(),
      password: _passwordController.text.isEmpty ? 'password' : _passwordController.text,
    );
    if (!mounted || user == null) return;
    _routeByUserRole(user.role);
  }

  void _routeByUserRole(String role) {
    switch (role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
      case UserRole.worker:
        Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
        break;
      case UserRole.citizen:
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.citizenHome);
        break;
    }
  }

  void _onDevRoleLogin(String role) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.devSwitchRole(role);
    _routeByUserRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language Selector Header
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.translate, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        DropdownButton<String>(
                          value: _selectedLang,
                          underline: const SizedBox(),
                          isDense: true,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'English', child: Text('English')),
                            DropdownMenuItem(value: 'मराठी', child: Text('मराठी')),
                            DropdownMenuItem(value: 'हिंदी', child: Text('हिंदी')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedLang = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Header Branding Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    const AppLogo(size: 64, showBackground: false),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance, size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Official Pimpri Chinchwad Municipal Corporation',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Citizen Civic Portal • नागरिक नागरी सेवा पोर्टल',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Citizen Login Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Citizen Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_outlined, size: 12, color: AppColors.success),
                              SizedBox(width: 4),
                              Text(
                                'Instant Access',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Login instantly using OTP sent to your registered mobile',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    if (_isOtpMode) ...[
                      const Text(
                        'Enter 10-Digit Mobile Number *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Text(
                              '+91',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          hintText: '98220 14820',
                          fillColor: AppColors.surfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.sms_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'A 6-digit verification code will be sent via SMS',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _onSendOtp,
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                          label: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get OTP / Send OTP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'ओटीपी मिळवा (Marathi)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _onPasswordLogin,
                          child: const Text('Sign In with Password'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() => _isOtpMode = !_isOtpMode),
                          icon: Icon(
                            _isOtpMode ? Icons.password : Icons.phone_android,
                            size: 16,
                          ),
                          label: Text(_isOtpMode ? 'Login with Password' : 'Use Mobile OTP'),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                          icon: const Icon(Icons.person_add_outlined, size: 16),
                          label: const Text('Register Citizen'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Employee & Staff Section (Separate & Clear)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'PCMC Staff & Officer Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Staff Only',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Authorized municipal officers & field engineers',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_right_outlined, color: AppColors.primary, size: 28),
                      onPressed: () => _showEmployeeModal(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Protected by DigiLocker & Civic OAuth 2.0',
                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmployeeModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Municipal Staff Portal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your official staff role to access operations',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
                title: const Text('Municipal Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Manage complaints, assign engineers & view analytics'),
                onTap: () {
                  Navigator.pop(context);
                  _onDevRoleLogin(UserRole.admin);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.engineering_outlined, color: AppColors.primary),
                title: const Text('Field Officer / Inspector Portal', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('View dispatches & update resolution photos'),
                onTap: () {
                  Navigator.pop(context);
                  _onDevRoleLogin(UserRole.worker);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
