import 'package:flutter/material.dart';

/// GPS status indicator displayed in the top-right of the camera screen.
/// Shows loading state, ready state, or error state.
class GpsStatusBadge extends StatelessWidget {
  final bool isLoading;
  final bool hasLocation;

  const GpsStatusBadge({
    super.key,
    required this.isLoading,
    required this.hasLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.60),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            )
          else
            Icon(
              hasLocation ? Icons.location_on : Icons.location_off,
              color: hasLocation ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
          const SizedBox(width: 6),
          Text(
            isLoading
                ? 'GPS...'
                : hasLocation
                    ? 'GPS Ready'
                    : 'No GPS',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
