import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum representing theme preference.
enum ThemeMode { light, dark, system }

/// Model representing user preferences and profile data.
@immutable
class UserSettings extends Equatable {
  /// User identifier
  final String userId;

  /// User's display name
  final String fullName;

  /// Job title
  final String title;

  /// Employee ID
  final String employeeId;

  /// Profile image URL (optional)
  final String? avatarUrl;

  /// App language code (default: "en_US")
  final String language;

  /// Theme preference (default: dark)
  final ThemeMode appearance;

  /// Hazard alert toggle
  final bool hazardAlerts;

  /// Zone monitoring toggle
  final bool safeZoneMonitoring;

  /// Biometric login enabled
  final bool biometricAuth;

  /// Current online status
  final bool isOnline;

  const UserSettings({
    required this.userId,
    required this.fullName,
    required this.title,
    required this.employeeId,
    this.avatarUrl,
    this.language = 'en_US',
    this.appearance = ThemeMode.dark,
    this.hazardAlerts = true,
    this.safeZoneMonitoring = true,
    this.biometricAuth = false,
    required this.isOnline,
  });

  /// Creates a UserSettings instance from JSON data.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      title: json['title'] as String,
      employeeId: json['employeeId'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      language: json['language'] as String? ?? 'en_US',
      appearance: json['appearance'] != null
          ? ThemeMode.values.byName(json['appearance'] as String)
          : ThemeMode.dark,
      hazardAlerts: json['hazardAlerts'] as bool? ?? true,
      safeZoneMonitoring: json['safeZoneMonitoring'] as bool? ?? true,
      biometricAuth: json['biometricAuth'] as bool? ?? false,
      isOnline: json['isOnline'] as bool,
    );
  }

  /// Converts UserSettings instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'title': title,
      'employeeId': employeeId,
      'avatarUrl': avatarUrl,
      'language': language,
      'appearance': appearance.name,
      'hazardAlerts': hazardAlerts,
      'safeZoneMonitoring': safeZoneMonitoring,
      'biometricAuth': biometricAuth,
      'isOnline': isOnline,
    };
  }

  /// Creates a copy of this UserSettings with optionally updated fields.
  UserSettings copyWith({
    String? userId,
    String? fullName,
    String? title,
    String? employeeId,
    String? avatarUrl,
    String? language,
    ThemeMode? appearance,
    bool? hazardAlerts,
    bool? safeZoneMonitoring,
    bool? biometricAuth,
    bool? isOnline,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      employeeId: employeeId ?? this.employeeId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      appearance: appearance ?? this.appearance,
      hazardAlerts: hazardAlerts ?? this.hazardAlerts,
      safeZoneMonitoring: safeZoneMonitoring ?? this.safeZoneMonitoring,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fullName,
    title,
    employeeId,
    avatarUrl,
    language,
    appearance,
    hazardAlerts,
    safeZoneMonitoring,
    biometricAuth,
    isOnline,
  ];

  @override
  String toString() => 'UserSettings(userId: $userId, name: $fullName)';
}
