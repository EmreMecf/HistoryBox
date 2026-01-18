// lib/shared/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/models/firebase/story_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stories Collection
  CollectionReference get storiesRef =>
      _firestore.collection(AppConstants.storiesCollection);

  // Users Collection
  CollectionReference get usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  // ==================== STORY OPERATIONS ====================

  // Yeni hikaye oluştur
  Future<String> createStory(StoryModel story) async {
    try {
      AppLogger.log('Creating new story: ${story.title}', tag: 'Firestore');
      
      final docRef = await storiesRef.add(story.toFirestore());
      
      AppLogger.success('Story created with ID: ${docRef.id}', tag: 'Firestore');
      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error('Error creating story', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Hikaye getir
  Future<StoryModel?> getStory(String storyId) async {
    try {
      AppLogger.log('Fetching story: $storyId', tag: 'Firestore');
      
      final doc = await storiesRef.doc(storyId).get();
      
      if (!doc.exists) {
        AppLogger.warning('Story not found: $storyId', tag: 'Firestore');
        return null;
      }
      
      return StoryModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching story', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Kullanıcının hikayeleri
  Stream<List<StoryModel>> getUserStories(String userId) {
    try {
      AppLogger.log('Fetching stories for user: $userId', tag: 'Firestore');
      
      return storiesRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => StoryModel.fromFirestore(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user stories', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Kategoriye göre hikayeler
  Stream<List<StoryModel>> getStoriesByCategory(String category) {
    try {
      AppLogger.log('Fetching stories for category: $category', tag: 'Firestore');
      
      return storiesRef
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.storiesPerPage)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => StoryModel.fromFirestore(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching stories by category', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Yaş grubuna göre hikayeler
  Stream<List<StoryModel>> getStoriesByAgeGroup(String ageGroup) {
    try {
      AppLogger.log('Fetching stories for age group: $ageGroup', tag: 'Firestore');
      
      return storiesRef
          .where('ageGroup', isEqualTo: ageGroup)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.storiesPerPage)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => StoryModel.fromFirestore(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching stories by age group', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Son oluşturulan hikayeler
  Stream<List<StoryModel>> getRecentStories({int limit = 10}) {
    try {
      AppLogger.log('Fetching recent stories', tag: 'Firestore');
      
      return storiesRef
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => StoryModel.fromFirestore(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching recent stories', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Hikaye güncelle
  Future<void> updateStory(String storyId, Map<String, dynamic> updates) async {
    try {
      AppLogger.log('Updating story: $storyId', tag: 'Firestore');
      
      await storiesRef.doc(storyId).update(updates);
      
      AppLogger.success('Story updated: $storyId', tag: 'Firestore');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating story', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Hikaye sil
  Future<void> deleteStory(String storyId) async {
    try {
      AppLogger.log('Deleting story: $storyId', tag: 'Firestore');
      
      await storiesRef.doc(storyId).delete();
      
      AppLogger.success('Story deleted: $storyId', tag: 'Firestore');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting story', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Favori durumunu değiştir
  Future<void> toggleFavorite(String storyId, bool isFavorite) async {
    try {
      AppLogger.log('Toggling favorite for story: $storyId', tag: 'Firestore');
      
      await storiesRef.doc(storyId).update({'isFavorite': isFavorite});
      
      AppLogger.success('Favorite toggled: $storyId = $isFavorite', tag: 'Firestore');
    } catch (e, stackTrace) {
      AppLogger.error('Error toggling favorite', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Favori hikayeleri getir
  Stream<List<StoryModel>> getFavoriteStories(String userId) {
    try {
      AppLogger.log('Fetching favorite stories for user: $userId', tag: 'Firestore');
      
      return storiesRef
          .where('userId', isEqualTo: userId)
          .where('isFavorite', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => StoryModel.fromFirestore(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching favorite stories', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Hikaye arama
  Future<List<StoryModel>> searchStories(String query, String userId) async {
    try {
      AppLogger.log('Searching stories with query: $query', tag: 'Firestore');
      
      final snapshot = await storiesRef
          .where('userId', isEqualTo: userId)
          .get();
      
      final stories = snapshot.docs
          .map((doc) => StoryModel.fromFirestore(doc))
          .where((story) =>
              story.title.toLowerCase().contains(query.toLowerCase()) ||
              story.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      AppLogger.success('Found ${stories.length} stories', tag: 'Firestore');
      return stories;
    } catch (e, stackTrace) {
      AppLogger.error('Error searching stories', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // ==================== USER OPERATIONS ====================

  // Kullanıcı profili oluştur/güncelle
  Future<void> saveUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      AppLogger.log('Saving user profile: $userId', tag: 'Firestore');
      
      await usersRef.doc(userId).set(data, SetOptions(merge: true));
      
      AppLogger.success('User profile saved: $userId', tag: 'Firestore');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving user profile', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // Kullanıcı profili getir
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      AppLogger.log('Fetching user profile: $userId', tag: 'Firestore');
      
      final doc = await usersRef.doc(userId).get();
      
      if (!doc.exists) {
        AppLogger.warning('User profile not found: $userId', tag: 'Firestore');
        return null;
      }
      
      return doc.data() as Map<String, dynamic>?;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user profile', 
        tag: 'Firestore', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }
}
