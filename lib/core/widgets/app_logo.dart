import 'package:flutter/material.dart';
import 'package:geo_tag_camera/app/theme.dart';

/// Centralized Logo widget for PCMC JanConnect.
/// Renders the official asset logo with fallback styling.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({
    super.key,
    this.size = 72.0,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoImage = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.location_city_rounded,
          size: size * 0.6,
          color: Colors.white,
        );
      },
    );

    if (!showBackground) {
      return logoImage;
    }

    return Container(
      width: size + 16,
      height: size + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(child: logoImage),
    );
  }
}
