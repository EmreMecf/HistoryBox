import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:historybox/core/utils/logger.dart';
import 'package:historybox/services/models/firebase/token_model.dart';

class TokenViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TokenModel? _tokenModel;
  bool _isLoading = false;

  TokenModel? get tokenModel => _tokenModel;
  int? get tokenCount => _tokenModel?.remainingTokens;
  int? get usedTokens => _tokenModel?.usedTokens;
  int? get totalTokens => _tokenModel?.totalTokens;
  bool get isLoading => _isLoading;

  static const int defaultMonthlyTokens = 100;

  Future<void> loadTokens() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final docSnapshot =
          await _firestore.collection('tokens').doc(userId).get();

      if (docSnapshot.exists) {
        _tokenModel = TokenModel.fromJson(docSnapshot.data()!);
        await _checkAndResetMonthlyTokens();
      } else {
        // İlk kez token oluştur
        await _createInitialTokens(userId);
      }
    } catch (e) {
      AppLogger.error('Token yüklenirken hata', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createInitialTokens(String userId) async {
    _tokenModel = TokenModel(
      userId: userId,
      totalTokens: defaultMonthlyTokens,
      usedTokens: 0,
      remainingTokens: defaultMonthlyTokens,
      lastUpdated: DateTime.now(),
      lastResetDate: DateTime.now(),
    );

    await _firestore
        .collection('tokens')
        .doc(userId)
        .set(_tokenModel!.toJson());
    
    AppLogger.info('İlk tokenlar oluşturuldu: $defaultMonthlyTokens token');
  }

  Future<bool> useToken({int amount = 1}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _tokenModel == null) return false;

    if (_tokenModel!.remainingTokens < amount) {
      AppLogger.warning('Yetersiz token');
      return false;
    }

    try {
      final updatedModel = _tokenModel!.copyWith(
        usedTokens: _tokenModel!.usedTokens + amount,
        remainingTokens: _tokenModel!.remainingTokens - amount,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('tokens')
          .doc(userId)
          .update(updatedModel.toJson());

      _tokenModel = updatedModel;
      notifyListeners();

      AppLogger.info('$amount token kullanıldı. Kalan: ${_tokenModel!.remainingTokens}');
      return true;
    } catch (e) {
      AppLogger.error('Token kullanılırken hata', error: e);
      return false;
    }
  }

  Future<void> _checkAndResetMonthlyTokens() async {
    if (_tokenModel == null) return;

    final now = DateTime.now();
    final lastReset = _tokenModel!.lastResetDate ?? _tokenModel!.lastUpdated;

    // Ay değişti mi kontrol et
    if (now.month != lastReset.month || now.year != lastReset.year) {
      await _resetMonthlyTokens();
    }
  }

  Future<void> _resetMonthlyTokens() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _tokenModel == null) return;

    try {
      final updatedModel = _tokenModel!.copyWith(
        totalTokens: defaultMonthlyTokens,
        usedTokens: 0,
        remainingTokens: defaultMonthlyTokens,
        lastUpdated: DateTime.now(),
        lastResetDate: DateTime.now(),
      );

      await _firestore
          .collection('tokens')
          .doc(userId)
          .update(updatedModel.toJson());

      _tokenModel = updatedModel;
      notifyListeners();

      AppLogger.info('Aylık tokenlar sıfırlandı: $defaultMonthlyTokens token');
    } catch (e) {
      AppLogger.error('Token sıfırlanırken hata', error: e);
    }
  }

  Future<void> addBonusTokens(int amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _tokenModel == null) return;

    try {
      final updatedModel = _tokenModel!.copyWith(
        totalTokens: _tokenModel!.totalTokens + amount,
        remainingTokens: _tokenModel!.remainingTokens + amount,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('tokens')
          .doc(userId)
          .update(updatedModel.toJson());

      _tokenModel = updatedModel;
      notifyListeners();

      AppLogger.info('$amount bonus token eklendi');
    } catch (e) {
      AppLogger.error('Bonus token eklenirken hata', error: e);
    }
  }
}
