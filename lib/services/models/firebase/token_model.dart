import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  final String userId;
  final int totalTokens;
  final int usedTokens;
  final int remainingTokens;
  final DateTime lastUpdated;
  final DateTime? lastResetDate;

  TokenModel({
    required this.userId,
    required this.totalTokens,
    required this.usedTokens,
    required this.remainingTokens,
    required this.lastUpdated,
    this.lastResetDate,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      userId: json['userId'] as String,
      totalTokens: json['totalTokens'] as int,
      usedTokens: json['usedTokens'] as int,
      remainingTokens: json['remainingTokens'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
      lastResetDate: json['lastResetDate'] != null
          ? (json['lastResetDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalTokens': totalTokens,
      'usedTokens': usedTokens,
      'remainingTokens': remainingTokens,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'lastResetDate': lastResetDate != null
          ? Timestamp.fromDate(lastResetDate!)
          : null,
    };
  }

  TokenModel copyWith({
    String? userId,
    int? totalTokens,
    int? usedTokens,
    int? remainingTokens,
    DateTime? lastUpdated,
    DateTime? lastResetDate,
  }) {
    return TokenModel(
      userId: userId ?? this.userId,
      totalTokens: totalTokens ?? this.totalTokens,
      usedTokens: usedTokens ?? this.usedTokens,
      remainingTokens: remainingTokens ?? this.remainingTokens,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}
