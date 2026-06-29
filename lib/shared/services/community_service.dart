// lib/shared/services/community_service.dart
//
// 🌐 Topluluk / sosyal katman: yayınlama, akış (feed), beğeni, yorum, kaydetme.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/models/firebase/story_model.dart';
import '../../services/models/firebase/comment_model.dart';
import '../../core/utils/logger.dart';

enum FeedSort { newest, popular }

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _stories =>
      _db.collection('stories');

  // ==================== YAYINLAMA ====================

  Future<void> publish(
    String storyId, {
    required String authorName,
    String? authorPhoto,
    bool authorIsPremium = false,
  }) async {
    await _stories.doc(storyId).update({
      'isPublic': true,
      'authorName': authorName,
      'authorPhoto': authorPhoto,
      'authorIsPremium': authorIsPremium,
      'publishedAt': FieldValue.serverTimestamp(),
    });
    AppLogger.success('Masal yayınlandı: $storyId', tag: 'Community');
  }

  Future<void> unpublish(String storyId) async {
    await _stories.doc(storyId).update({'isPublic': false});
  }

  // ==================== AKIŞ (FEED) ====================

  Stream<List<StoryModel>> publicFeed({
    FeedSort sort = FeedSort.newest,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query =
        _stories.where('isPublic', isEqualTo: true);
    query = sort == FeedSort.popular
        ? query.orderBy('likeCount', descending: true)
        : query.orderBy('publishedAt', descending: true);

    return query.limit(limit).snapshots().map(
          (snap) =>
              snap.docs.map((d) => StoryModel.fromFirestore(d)).toList(),
        );
  }

  // ==================== BEĞENİ ====================

  /// Beğeniyi aç/kapat. Yeni durumu (beğenildi mi) döndürür.
  Future<bool> toggleLike(String storyId, String userId) async {
    final likeRef = _stories.doc(storyId).collection('likes').doc(userId);
    final storyRef = _stories.doc(storyId);

    return _db.runTransaction<bool>((txn) async {
      final likeSnap = await txn.get(likeRef);
      if (likeSnap.exists) {
        txn.delete(likeRef);
        txn.update(storyRef, {'likeCount': FieldValue.increment(-1)});
        return false;
      } else {
        txn.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        txn.update(storyRef, {'likeCount': FieldValue.increment(1)});
        return true;
      }
    });
  }

  Stream<bool> isLiked(String storyId, String userId) {
    return _stories
        .doc(storyId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((d) => d.exists);
  }

  // ==================== YORUM ====================

  Future<void> addComment(String storyId, CommentModel comment) async {
    final storyRef = _stories.doc(storyId);
    final commentRef = storyRef.collection('comments').doc();
    final batch = _db.batch();
    batch.set(commentRef, comment.toFirestore());
    batch.update(storyRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Stream<List<CommentModel>> comments(String storyId) {
    return _stories
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromFirestore(d)).toList());
  }

  // ==================== KAYDETME (BOOKMARK) ====================

  /// Başkasının masalını koleksiyona ekle/çıkar. Yeni durumu döndürür.
  Future<bool> toggleBookmark(String userId, StoryModel story) async {
    final ref =
        _db.collection('users').doc(userId).collection('bookmarks').doc(story.id);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      return false;
    }
    await ref.set({
      'storyId': story.id,
      'title': story.title,
      'category': story.category,
      'authorName': story.authorName,
      'savedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  Stream<bool> isBookmarked(String userId, String storyId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(storyId)
        .snapshots()
        .map((d) => d.exists);
  }

  /// Kaydedilen masalların id listesi (gerçek masal dokümanları ayrı çekilir).
  Stream<List<String>> bookmarkIds(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  /// Kaydedilen masalların özet bilgileri (liste ekranı için).
  /// Kaydederken sakladığımız alanlar (title/category/authorName) kullanılır.
  Stream<List<Map<String, dynamic>>> savedBookmarks(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {...d.data(), 'storyId': d.id})
            .toList());
  }

  Future<void> removeBookmark(String userId, String storyId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(storyId)
        .delete();
  }
}
