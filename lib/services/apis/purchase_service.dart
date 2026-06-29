import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/token_repository.dart';

class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TokenRepository _tokenRepository;
  final FirebaseAuth _auth;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

  /// Bir satın alma teslim edildikten (token eklendikten) sonra çağrılır.
  /// ViewModel bu callback ile token sayısını yeniden yükler.
  void Function()? onTokensDelivered;

  /// Premium abonelik etkinleştiğinde çağrılır (filigran kalkar).
  void Function()? onPremiumActivated;

  /// Premium abonelik ürün kimlikleri (App Store / Play Console'da tanımlanmalı).
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  static const Set<String> premiumIds = {premiumMonthlyId, premiumYearlyId};

  static const Map<String, int> _productIds = {
    'small_token_package': 5,
    'medium_token_package': 15,
    'large_token_package': 50,
  };

  PurchaseService(this._tokenRepository, this._auth) {
    _initialize();
  }

  Future<void> _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) return;

    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        print('Satın alma hatası: $error');
      },
    );
  }

  Future<bool> buyTokenPackage(String productId) async {
    if (!_isAvailable || _auth.currentUser == null) return false;

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});

      if (response.productDetails.isEmpty) return false;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
        applicationUserName: _auth.currentUser!.uid,
      );

      return await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (e) {
      print('Satın alma başlatılamadı: $e');
      return false;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        continue;
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Satın alma hatası: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _deliverProduct(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Premium ürünlerini (aylık + yıllık, fiyatlarıyla) mağazadan getirir.
  Future<List<ProductDetails>> premiumProducts() async {
    if (!_isAvailable) return [];
    try {
      final response = await _inAppPurchase.queryProductDetails(premiumIds);
      return response.productDetails;
    } catch (e) {
      print('Premium ürün bilgisi alınamadı: $e');
      return [];
    }
  }

  /// Belirtilen premium planı (aylık/yıllık) başlatır.
  Future<bool> buyPremium(String productId) async {
    if (!_isAvailable || _auth.currentUser == null) return false;
    try {
      final response =
          await _inAppPurchase.queryProductDetails({productId});
      if (response.productDetails.isEmpty) return false;

      final param = PurchaseParam(
        productDetails: response.productDetails.first,
        applicationUserName: _auth.currentUser!.uid,
      );
      return await _inAppPurchase.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      print('Premium satın alma başlatılamadı: $e');
      return false;
    }
  }

  /// Önceki satın alımları geri yükler (App Store için zorunlu).
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Geri yükleme başarısız: $e');
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (_auth.currentUser == null) return;
    final userId = _auth.currentUser!.uid;

    // Premium abonelik (aylık veya yıllık)
    if (premiumIds.contains(purchaseDetails.productID)) {
      await _firestore.collection('users').doc(userId).set(
        {'isPremium': true, 'premiumSince': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      onPremiumActivated?.call();
      return;
    }

    // Token paketleri
    final tokenAmount = _productIds[purchaseDetails.productID];
    if (tokenAmount == null) return;
    await _tokenRepository.addTokens(userId, tokenAmount);
    onTokensDelivered?.call();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
