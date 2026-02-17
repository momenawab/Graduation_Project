import 'package:intl/intl.dart';

class AppFormatters {
  /// Formats a DateTime to a readable date string
  static String formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return DateFormat('MMM dd, yyyy').format(date!);
  }

  /// Formats a DateTime to a readable date and time string
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime!);
  }

  /// Formats a DateTime to a time string only
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return DateFormat('HH:mm').format(dateTime!);
  }

  /// Formats a compliance percentage (0-100) with % sign
  static String formatCompliancePercentage(int? percentage) {
    if (percentage == null) {
      return '0%';
    }
    return '$percentage%';
  }

  /// Formats a duration in seconds to a readable string
  static String formatDuration(Duration? duration) {
    if (duration == null) {
      return '0s';
    }
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// Formats a number with commas for thousands
  static String formatNumber(int? number) {
    if (number == null) {
      return '0';
    }
    return NumberFormat.decimalPattern().format(number!);
  }

  /// Formats a trend percentage with + or - sign
  static String formatTrend(double? trend) {
    if (trend == null) {
      return '0%';
    }
    final sign = trend! >= 0 ? '+' : '';
    return '$sign${trend!.toStringAsFixed(1)}%';
  }

  /// Formats a file size in bytes to readable format
  static String formatFileSize(int? bytes) {
    if (bytes == null) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var value = bytes!.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < suffixes.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    return '${value.toStringAsFixed(1)} ${suffixes[unitIndex]}';
  }

  /// Formats a relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
}
