// lib/core/utils/validators.dart
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gerekli';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi girin';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} gerekli';
    }
    return null;
  }

  // Min length validation
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} gerekli';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Bu alan'} en az $minLength karakter olmalı';
    }

    return null;
  }

  // Max length validation
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Bu alan'} en fazla $maxLength karakter olmalı';
    }

    return null;
  }

  // Story title validation
  static String? validateStoryTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hikaye başlığı gerekli';
    }

    if (value.trim().length < 3) {
      return 'Başlık en az 3 karakter olmalı';
    }

    if (value.length > 100) {
      return 'Başlık en fazla 100 karakter olmalı';
    }

    return null;
  }

  // Story content validation
  static String? validateStoryContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hikaye içeriği gerekli';
    }

    if (value.trim().length < 50) {
      return 'Hikaye en az 50 karakter olmalı';
    }

    return null;
  }
}
