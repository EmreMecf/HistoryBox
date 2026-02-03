import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/token/token_model.dart';

class TokenService {
  final FirebaseFirestore _firestore;

  TokenService(this._firestore);

  Future<TokenModel?> getUserTokens(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('tokens').doc(userId).get();

      if (docSnapshot.exists) {
        return TokenModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Token verileri alınamadı: $e');
      return null;
    }
  }

  Future<bool> createUserTokens(TokenModel tokenModel) async {
    try {
      await _firestore.collection('tokens').doc(tokenModel.userId).set(tokenModel.toJson());
      return true;
    } catch (e) {
      print('Token kaydı oluşturulamadı: $e');
      return false;
    }
  }

  Future<bool> updateTokenCount(String userId, int newCount) async {
    try {
      await _firestore.collection('tokens').doc(userId).update({
        'tokenCount': newCount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Token sayısı güncellendi: $newCount');
      return true;
    } catch (e) {
      print('Token güncelleme başarısız: $e');
      return false;
    }
  }
}
