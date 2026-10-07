import 'package:flutter/material.dart';
import 'package:geo_tag_camera/app/theme.dart';
import 'package:geo_tag_camera/core/widgets/loading_widget.dart';

/// Primary action button used throughout the app.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDestructive
        ? AppColors.error
        : (backgroundColor ?? AppColors.primary);
    final fgColor = foregroundColor ?? Colors.white;

    Widget child = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InlineLoader(size: 18, color: isOutlined ? bgColor : fgColor),
              const SizedBox(width: 10),
              Text(label),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: bgColor,
              side: BorderSide(color: bgColor, width: 1.5),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
            ),
            child: child,
          );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}

/// Full-width button (100% width)
class FullWidthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final Color? backgroundColor;

  const FullWidthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        isOutlined: isOutlined,
        isDestructive: isDestructive,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
