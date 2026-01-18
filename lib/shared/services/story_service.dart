// lib/shared/services/story_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/models/firebase/story_model.dart';
import '../../services/models/network/result.dart';
import 'firestore_service.dart';
import '../../core/utils/logger.dart';

class StoryService {
  final FirestoreService _firestoreService;

  StoryService(this._firestoreService);

  // Yeni hikaye oluştur
  Future<Result<String, Exception>> createStory({
    required String title,
    required String content,
    required String category,
    required String ageGroup,
    required String userId,
  }) async {
    try {
      final story = StoryModel(
        id: '', // Firestore otomatik olarak oluşturacak
        title: title,
        content: content,
        category: category,
        ageGroup: ageGroup,
        userId: userId,
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      final storyId = await _firestoreService.createStory(story);
      
      return Success(storyId);
    } catch (e, stackTrace) {
      AppLogger.error('Error in createStory', 
        tag: 'StoryService', 
        error: e, 
        stackTrace: stackTrace
      );
      return Failure(Exception('Hikaye oluşturulamadı: $e'));
    }
  }

  // Hikaye getir
  Future<Result<StoryModel, Exception>> getStory(String storyId) async {
    try {
      final story = await _firestoreService.getStory(storyId);
      
      if (story == null) {
        return Failure(Exception('Hikaye bulunamadı'));
      }
      
      return Success(story);
    } catch (e, stackTrace) {
      AppLogger.error('Error in getStory', 
        tag: 'StoryService', 
        error: e, 
        stackTrace: stackTrace
      );
      return Failure(Exception('Hikaye yüklenemedi: $e'));
    }
  }

  // Kullanıcının hikayeleri
  Stream<List<StoryModel>> getUserStories(String userId) {
    return _firestoreService.getUserStories(userId);
  }

  // Kategoriye göre hikayeler
  Stream<List<StoryModel>> getStoriesByCategory(String category) {
    return _firestoreService.getStoriesByCategory(category);
  }

  // Yaş grubuna göre hikayeler
  Stream<List<StoryModel>> getStoriesByAgeGroup(String ageGroup) {
    return _firestoreService.getStoriesByAgeGroup(ageGroup);
  }

  // Son hikayeler
  Stream<List<StoryModel>> getRecentStories({int limit = 10}) {
    return _firestoreService.getRecentStories(limit: limit);
  }

  // Hikaye güncelle
  Future<Result<void, Exception>> updateStory(
    String storyId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestoreService.updateStory(storyId, updates);
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error in updateStory', 
        tag: 'StoryService', 
        error: e, 
        stackTrace: stackTrace
      );
      return Failure(Exception('Hikaye güncellenemedi: $e'));
    }
  }

  // Hikaye sil
  Future<Result<void, Exception>> deleteStory(String storyId) async {
    try {
      await _firestoreService.deleteStory(storyId);
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error in deleteStory', 
        tag: 'StoryService', 
        error: e, 
        stackTrace: stackTrace
      );
      return Failure(Exception('Hikaye silinemedi: $e'));
    }
  }

  // Favori durumunu değiştir
  Future<Result<void, Exception>> toggleFavorite(
    String storyId,
    bool isFavorite,
  ) async {
    try {
      await _firestoreService.toggleFavorite(storyId, isFavorite);
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error in toggleFavorite', 
        tag: 'StoryService', 
        error: e, 
        stackTrace: stackTrace
      );
      return Failure(Exception('Favori durumu değiştirilemedi: $e'));
    }
  }

  // Favori hikayeleri getir
  Stream<List<StoryModel>> getFavoriteStories(String userId) {
    return _firestoreService.getFavoriteStories(userId);
  }

  // Hikaye arama
  Future<Result<List<StoryModel>, Exception>> searchStories(
    String query,
    String userId,
  ) async {
    try {
      final stories = await _firestoreService.searchStories(query, userId);
      return Success(stories);
    } catch (e, stackTrace) {
      AppLogger.error('Error in searchStories', 
        tag: 'StoryService', 
        error: e, 
        stackTrace: stackTrace
      );
      return Failure(Exception('Arama yapılamadı: $e'));
    }
  }
}
