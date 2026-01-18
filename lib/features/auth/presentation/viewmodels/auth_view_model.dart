// lib/features/auth/presentation/viewmodels/auth_view_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../services/models/network/result.dart';
import '../../../../services/navigation/navigation.dart';
import '../../../../services/repositories/firebase_auth_repository.dart';
import '../../../../core/utils/logger.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseAuthRepository _authRepository;
  final NavigationService _navigationService;

  AuthViewModel(this._authRepository, this._navigationService);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _authRepository.currentUser;
  String? get currentUserId => _authRepository.currentUserId;
  bool get isAuthenticated => currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Google ile giriş yap
  Future<void> signInWithGoogle() async {
    try {
      setLoading(true);
      setError(null);

      AppLogger.log('Starting Google Sign In', tag: 'AuthViewModel');

      final result = await _authRepository.signInWithGoogle();

      if (result is Success) {
        AppLogger.success('Google Sign In successful', tag: 'AuthViewModel');
        
        // Kullanıcıyı yeniden yükle
        await FirebaseAuth.instance.currentUser?.reload();
        
        if (FirebaseAuth.instance.currentUser != null) {
          _navigationService.goHome();
        }
      } else if (result is Failure) {
        final error = 'Giriş yapılamadı: ${result.exception}';
        AppLogger.error(error, tag: 'AuthViewModel');
        setError(error);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in signInWithGoogle', 
        tag: 'AuthViewModel', 
        error: e, 
        stackTrace: stackTrace
      );
      setError('Bir hata oluştu: $e');
    } finally {
      setLoading(false);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      setLoading(true);
      setError(null);

      AppLogger.log('Starting Sign Out', tag: 'AuthViewModel');

      final result = await _authRepository.signOut();

      if (result is Success) {
        AppLogger.success('Sign Out successful', tag: 'AuthViewModel');
        _navigationService.goLogin();
      } else if (result is Failure) {
        final error = 'Çıkış yapılamadı: ${result.exception}';
        AppLogger.error(error, tag: 'AuthViewModel');
        setError(error);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in signOut', 
        tag: 'AuthViewModel', 
        error: e, 
        stackTrace: stackTrace
      );
      setError('Bir hata oluştu: $e');
    } finally {
      setLoading(false);
    }
  }

  // Misafir girişi
  Future<void> signInAsGuest() async {
    // Misafir girişi için geçici çözüm
    // TODO: Anonim authentication eklenebilir
    _navigationService.goHome();
  }
}
