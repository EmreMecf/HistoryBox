// lib/core/constants/app_constants.dart
class AppConstants {
  // App Bilgileri
  static const String appName = 'HistoryBox';
  static const String appSlogan = 'Hayal gücünü keşfet!';
  
  // Firestore Collection İsimleri
  static const String storiesCollection = 'stories';
  static const String usersCollection = 'users';
  static const String favoritesCollection = 'favorites';
  
  // Story Kategorileri
  static const List<String> storyCategories = [
    'Masal',
    'Hikaye',
    'Şiir',
    'Bilim',
    'Macera',
    'Komedi',
  ];
  
  // Yaş Grupları
  static const List<String> ageGroups = [
    '3-5 Yaş',
    '6-8 Yaş',
    '9-12 Yaş',
    '13+ Yaş',
  ];
  
  // ChatGPT Prompt Templates
  static const String storyPromptTemplate = '''
Bir çocuk hikayesi yaz. Detaylar:
- Kategori: {category}
- Yaş Grubu: {ageGroup}
- Konu: {topic}
- Uzunluk: {length} kelime

Hikaye eğlenceli, öğretici ve çocuklara uygun olmalı. 
Başlık ve hikaye metnini ayrı ayrı yaz.
''';

  // Animasyon Süreleri
  static const int splashDuration = 2000; // ms
  static const int cardAnimationDelay = 100; // ms
  
  // API Limits
  static const int maxStoryLength = 1000;
  static const int minStoryLength = 100;
  static const int storiesPerPage = 10;
}
