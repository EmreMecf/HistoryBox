import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/advert/ad_service.dart';
import '../services/apis/purchase_service.dart';
import '../services/models/network/result.dart';
import '../services/models/token/token_model.dart';
import '../services/repositories/token_repository.dart';

class TokenViewModel extends ChangeNotifier {
  final TokenRepository _tokenRepository;
  final FirebaseAuth _auth;
  final PurchaseService _purchaseService;

  TokenModel? _tokenModel;
  static const int _adRewardTokens = 2;
  bool _isLoading = false;
  String? _errorMessage;
  BuildContext? _context;

  TokenModel? get tokenModel => _tokenModel;
  int get tokenCount => _tokenModel?.tokenCount ?? 0;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTokens => _tokenModel != null && _tokenModel!.tokenCount > 0;

  StreamSubscription<User?>? _authSubscription;

  TokenViewModel(this._tokenRepository, this._auth, this._purchaseService) {
    // Satın alma teslim edildiğinde token sayısını Firestore'dan yeniden yükle
    _purchaseService.onTokensDelivered = loadTokens;

    // Giriş/çıkışta token'ları Firestore ile senkronize et
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        clearTokens();
      } else {
        loadTokens();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void setContext(BuildContext? context) {
    _context = context;
  }

  Future<void> loadTokens() async {
    try {
      if (_auth.currentUser == null) {
        _tokenModel = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _auth.currentUser!.uid;

      // Token bilgilerini Firestore'dan al (yoksa repository 5 token ile oluşturur)
      final result = await _tokenRepository.getUserTokens(userId);
      if (result is Success<TokenModel, Exception>) {
        _tokenModel = result.value;
      } else if (result is Failure<TokenModel, Exception>) {
        _errorMessage = result.exception.toString();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      debugPrint('Token load exception: $e');
      notifyListeners();
    }
  }

  Future<bool> useToken() async {
    try {
      if (_auth.currentUser == null) return false;
      if (_tokenModel == null || _tokenModel!.tokenCount <= 0) return false;

      final userId = _auth.currentUser!.uid;

      // Token'ı Firestore üzerinde düşür
      final result = await _tokenRepository.useToken(userId);
      if (result is Success<bool, Exception> && result.value == true) {
        _tokenModel = TokenModel(
          userId: _tokenModel!.userId,
          tokenCount: _tokenModel!.tokenCount - 1,
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
        return true;
      }

      // Success(false) => token kalmamış, Firestore ile senkronize et
      await loadTokens();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Token use exception: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTokensByAd() async {
    try {
      if (_auth.currentUser == null) return false;

      final userId = _auth.currentUser!.uid;
      final completer = Completer<bool>();
      final adService = AdService();

      await adService.showRewardedAd(
        onRewarded: () async {
          // Ödülü Firestore'a kalıcı olarak ekle
          final result =
              await _tokenRepository.addTokens(userId, _adRewardTokens);
          if (result is Success<bool, Exception>) {
            await loadTokens();
            if (!completer.isCompleted) completer.complete(true);
          } else {
            if (!completer.isCompleted) completer.complete(false);
          }
        },
      );

      return completer.future;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Ad show exception: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> purchaseTokens(String packageId) async {
    try {
      if (_auth.currentUser == null) return false;

      return await _purchaseService.buyTokenPackage(packageId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Purchase exception: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkTokenForChatGPT() async {
    try {
      if (_auth.currentUser == null) return false;

      await loadTokens();

      return hasTokens;
    } catch (e) {
      debugPrint('Token check exception: $e');
      return false;
    }
  }

  void clearTokens() {
    _tokenModel = null;
    _errorMessage = null;
    _isLoading = false;
    _context = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> getTokenPackages({BuildContext? context}) {
    final effectiveContext = context ?? _context;
    final isEnglish = effectiveContext != null
        ? Localizations.localeOf(effectiveContext).languageCode == 'en'
        : false;

    if (isEnglish) {
      return [
        {
          'amount': 5,
          'price': '₺9.99',
          'label': 'Small Package',
          'id': 'small_token_package'
        },
        {
          'amount': 15,
          'price': '₺24.99',
          'label': 'Medium Package',
          'id': 'medium_token_package'
        },
        {
          'amount': 50,
          'price': '₺69.99',
          'label': 'Large Package',
          'id': 'large_token_package'
        },
      ];
    } else {
      return [
        {
          'amount': 5,
          'price': '₺9.99',
          'label': 'Küçük Paket',
          'id': 'small_token_package'
        },
        {
          'amount': 15,
          'price': '₺24.99',
          'label': 'Orta Paket',
          'id': 'medium_token_package'
        },
        {
          'amount': 50,
          'price': '₺69.99',
          'label': 'Büyük Paket',
          'id': 'large_token_package'
        },
      ];
    }
  }
}
