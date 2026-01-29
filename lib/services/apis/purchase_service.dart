import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/token_repository.dart';

class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final TokenRepository _tokenRepository;
  final FirebaseAuth _auth;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

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

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (_auth.currentUser == null) return;

    final tokenAmount = _productIds[purchaseDetails.productID];
    if (tokenAmount == null) return;

    final userId = _auth.currentUser!.uid;
    await _tokenRepository.addTokens(userId, tokenAmount);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
