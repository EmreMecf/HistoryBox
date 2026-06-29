// lib/core/extensions/string_extensions.dart
extension StringExtensions on String {
  // İlk harfi büyük yap
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  // Tüm kelimelerin ilk harfini büyük yap
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
  
  // String'i kısalt
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
  
  // Boşluk kontrolü
  bool get isNotBlank => trim().isNotEmpty;
  
  // Email kontrolü
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}
