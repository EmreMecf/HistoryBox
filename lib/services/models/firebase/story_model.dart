// lib/services/models/firebase/story_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String ageGroup;
  final String userId;
  final DateTime createdAt;
  final bool isFavorite;
  final String? imageUrl;

  // ----- Sosyal / topluluk alanları -----
  final bool isPublic;
  final String? authorName;
  final String? authorPhoto;
  final bool authorIsPremium;
  final int likeCount;
  final int commentCount;
  final DateTime? publishedAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.ageGroup,
    required this.userId,
    required this.createdAt,
    this.isFavorite = false,
    this.imageUrl,
    this.isPublic = false,
    this.authorName,
    this.authorPhoto,
    this.authorIsPremium = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.publishedAt,
  });

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      title: data['title'] as String,
      content: data['content'] as String,
      category: data['category'] as String,
      ageGroup: data['ageGroup'] as String,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isFavorite: data['isFavorite'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
      isPublic: data['isPublic'] as bool? ?? false,
      authorName: data['authorName'] as String?,
      authorPhoto: data['authorPhoto'] as String?,
      authorIsPremium: data['authorIsPremium'] as bool? ?? false,
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      publishedAt: _toDate(data['publishedAt']),
    );
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      ageGroup: json['ageGroup'] as String,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      authorName: json['authorName'] as String?,
      authorPhoto: json['authorPhoto'] as String?,
      authorIsPremium: json['authorIsPremium'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      publishedAt: _toDate(json['publishedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'ageGroup': ageGroup,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'authorName': authorName,
      'authorPhoto': authorPhoto,
      'authorIsPremium': authorIsPremium,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  StoryModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? ageGroup,
    String? userId,
    DateTime? createdAt,
    bool? isFavorite,
    String? imageUrl,
    bool? isPublic,
    String? authorName,
    String? authorPhoto,
    bool? authorIsPremium,
    int? likeCount,
    int? commentCount,
    DateTime? publishedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      ageGroup: ageGroup ?? this.ageGroup,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      authorName: authorName ?? this.authorName,
      authorPhoto: authorPhoto ?? this.authorPhoto,
      authorIsPremium: authorIsPremium ?? this.authorIsPremium,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
