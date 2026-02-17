import '../constants/app_strings.dart';

class AppValidators {
  /// Validates worker ID - must be exactly 8 digits
  static String? validateWorkerId(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.workerIdMustBe8Digits;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return AppStrings.workerIdMustBe8Digits;
    }
    return null;
  }

  /// Validates full name - must be 2-100 characters
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameMustBe2to100Chars;
    }
    if (value.length < 2 || value.length > 100) {
      return AppStrings.nameMustBe2to100Chars;
    }
    return null;
  }

  /// Validates that a field is not empty
  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates phone number format (10 digits)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
}
