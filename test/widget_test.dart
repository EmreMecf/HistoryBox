// HistoryBox birim testleri.
//
// Not: Tam uygulama widget testi Firebase, dotenv ve DI kurulumu gerektirir;
// bu yüzden burada Firebase'e ihtiyaç duymayan saf (pure) model/mantık
// testleri yer alır.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:historybox/services/models/network/result.dart';
import 'package:historybox/services/models/token/token_model.dart';

void main() {
  group('TokenModel', () {
    test('toJson/fromJson çift yönlü dönüşüm tutarlı', () {
      final now = DateTime(2026, 6, 26, 12, 0, 0);
      final model = TokenModel(
        userId: 'user-123',
        tokenCount: 7,
        lastUpdated: now,
      );

      final json = model.toJson();
      final restored = TokenModel.fromJson(json);

      expect(restored.userId, 'user-123');
      expect(restored.tokenCount, 7);
      expect(restored.lastUpdated, now);
      expect(json['lastUpdated'], isA<Timestamp>());
    });

    test('tokenCount eksikse 0 olarak okunur', () {
      final model = TokenModel.fromJson({
        'userId': 'user-x',
        'lastUpdated': '2026-06-26T00:00:00.000',
      });

      expect(model.tokenCount, 0);
      expect(model.userId, 'user-x');
    });
  });

  group('Result', () {
    test('Success değeri taşır', () {
      const Result<int, Exception> result = Success(42);
      expect(result, isA<Success<int, Exception>>());
      expect((result as Success<int, Exception>).value, 42);
    });

    test('Failure exception taşır', () {
      final result = Failure<int, Exception>(Exception('hata'));
      expect(result, isA<Failure<int, Exception>>());
      expect(result.exception.toString(), contains('hata'));
    });
  });
}
