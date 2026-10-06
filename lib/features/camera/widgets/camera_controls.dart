import 'package:flutter/material.dart';

/// Camera bottom controls: shutter button, location refresh, info.
/// Refactored from main.dart BOTTOM CAMERA CONTROLS section.
class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onRefreshLocation;
  final bool isCapturing;
  final bool hasLocation;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onRefreshLocation,
    required this.isCapturing,
    required this.hasLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // ── Refresh Location ───────────────────────────────────────────────
        _ControlButton(
          icon: Icons.my_location_rounded,
          onTap: onRefreshLocation,
          tooltip: 'Refresh location',
        ),

        // ── Shutter Button ─────────────────────────────────────────────────
        _ShutterButton(
          onCapture: onCapture,
          isCapturing: isCapturing,
        ),

        // ── Flash / Info ───────────────────────────────────────────────────
        _ControlButton(
          icon: Icons.info_outline_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Geo-Tag Camera — GPS location is embedded in photo'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Info',
        ),
      ],
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final VoidCallback onCapture;
  final bool isCapturing;

  const _ShutterButton({required this.onCapture, required this.isCapturing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onCapture,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCapturing ? Colors.white54 : Colors.white,
            width: 5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isCapturing ? Colors.white54 : Colors.white,
              shape: BoxShape.circle,
            ),
            child: isCapturing
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
