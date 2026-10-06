import 'package:intl/intl.dart';

/// Date and time formatting utilities used across the app.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _displayTime = DateFormat('hh:mm a');
  static final DateFormat _displayDateTime = DateFormat('dd/MM/yyyy hh:mm a');
  static final DateFormat _geoTagStamp = DateFormat('dd/MM/yyyy  HH:mm');
  static final DateFormat _complaintId = DateFormat('yyyy');
  static final DateFormat _relativeDate = DateFormat('dd MMM yyyy');

  /// Format: 08/09/2026
  static String formatDate(DateTime dt) => _displayDate.format(dt);

  /// Format: 10:45 AM
  static String formatTime(DateTime dt) => _displayTime.format(dt);

  /// Format: 08/09/2026 10:45 AM
  static String formatDateTime(DateTime dt) => _displayDateTime.format(dt);

  /// Format for geo-tag watermark on image: 08/09/2026  10:45
  static String formatGeoTagStamp(DateTime dt) => _geoTagStamp.format(dt);

  /// Format: 08 Sep 2026
  static String formatRelativeDate(DateTime dt) => _relativeDate.format(dt);

  /// Returns year string for complaint ID generation (e.g. "2026")
  static String formatComplaintYear(DateTime dt) => _complaintId.format(dt);

  /// Human-readable relative time (e.g. "2 hours ago", "3 days ago")
  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    } else if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    } else {
      return formatRelativeDate(dt);
    }
  }
}
