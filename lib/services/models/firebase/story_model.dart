// lib/services/models/firestore/story_model.dart
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
  });

  // Firestore'dan dönüştürme için factory method
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
    );
  }

  // JSON'dan dönüştürme
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
    );
  }

  // JSON'a dönüştürme
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
    };
  }

  // Firestore'a kaydetmek için Map'e dönüştürme
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID Firestore tarafından yönetiliyor
    return json;
  }

  // CopyWith method
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
    );
  }
}
