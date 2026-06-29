import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:historybox/core/utils/logger.dart';
import 'package:historybox/services/advert/ad_service.dart';

class ProfileViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _userName;
  String? _userEmail;
  String? _userPhoto;
  String? _userId;
  int _storiesCount = 0;
  int _favoriteCount = 0;
  bool _isPremium = false;

  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhoto => _userPhoto;
  String? get userId => _userId;
  int get storiesCount => _storiesCount;
  int get favoriteCount => _favoriteCount;

  /// Premium abone mi? (filigranı kaldırır, premium özellikleri açar)
  bool get isPremium => _isPremium;

  set setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    setLoading = true;
    final user = _auth.currentUser;

    if (user != null) {
      _userId = user.uid;
      _userName = user.displayName ?? 'User';
      _userEmail = user.email ?? 'No Email';
      _userPhoto = user.photoURL;

      // Load user stats + premium durumu
      await _loadUserStats();
      await _loadPremiumStatus();
    }
    setLoading = false;
  }

  Future<void> _loadPremiumStatus() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      _isPremium = (doc.data()?['isPremium'] as bool?) ?? false;
      // Premium kullanıcılarda banner/interstitial reklamları kapat
      AdService().setPremium(_isPremium);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading premium status', error: e);
    }
  }

  /// Premium satın alındıktan sonra UI'ı tazelemek için.
  Future<void> refreshPremium() => _loadPremiumStatus();

  Future<void> _loadUserStats() async {
    if (_userId == null) return;

    try {
      // Count total stories
      final storiesSnapshot = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: _userId)
          .get();
      _storiesCount = storiesSnapshot.docs.length;

      // Count favorite stories
      final favoritesSnapshot = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: _userId)
          .where('isFavorite', isEqualTo: true)
          .get();
      _favoriteCount = favoritesSnapshot.docs.length;

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading user stats', error: e);
    }
  }

  void updateUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? newName,
    String? newPhotoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (newName != null) {
        await user.updateDisplayName(newName);
        _userName = newName;
      }

      if (newPhotoUrl != null) {
        await user.updatePhotoURL(newPhotoUrl);
        _userPhoto = newPhotoUrl;
      }

      notifyListeners();
      AppLogger.info('Profile updated successfully');
    } catch (e) {
      AppLogger.error('Error updating profile', error: e);
    }
  }

  void refreshStats() {
    _loadUserStats();
  }
}
