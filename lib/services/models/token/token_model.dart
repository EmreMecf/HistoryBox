import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  final String userId;
  final int tokenCount;
  final DateTime lastUpdated;

  TokenModel({
    required this.userId,
    required this.tokenCount,
    required this.lastUpdated,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final rawLastUpdated = json['lastUpdated'];
    DateTime lastUpdated;

    if (rawLastUpdated is Timestamp) {
      lastUpdated = rawLastUpdated.toDate();
    } else if (rawLastUpdated is String) {
      lastUpdated = DateTime.tryParse(rawLastUpdated) ?? DateTime.now();
    } else {
      lastUpdated = DateTime.now();
    }

    return TokenModel(
      userId: json['userId'] as String,
      tokenCount: json['tokenCount'] as int? ?? 0,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tokenCount': tokenCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
