// lib/features/home/presentation/viewmodels/home_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../services/models/firebase/story_model.dart';
import '../../../../shared/services/story_service.dart';
import '../../../../core/utils/logger.dart';

class HomeViewModel with ChangeNotifier {
  final StoryService _storyService;
  
  HomeViewModel(this._storyService);

  List<StoryModel> _recentStories = [];
  List<StoryModel> get recentStories => _recentStories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _recentStoriesSubscription;

  // Son hikayeleri dinle
  void listenToRecentStories() {
    try {
      _isLoading = true;
      notifyListeners();

      AppLogger.log('Listening to recent stories', tag: 'HomeViewModel');

      _recentStoriesSubscription?.cancel();
      _recentStoriesSubscription = _storyService.getRecentStories(limit: 5).listen(
        (stories) {
          _recentStories = stories;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          
          AppLogger.success('Loaded ${stories.length} recent stories', 
            tag: 'HomeViewModel'
          );
        },
        onError: (error) {
          _errorMessage = 'Hikayeler yüklenemedi: $error';
          _isLoading = false;
          notifyListeners();
          
          AppLogger.error('Error loading recent stories', 
            tag: 'HomeViewModel', 
            error: error
          );
        },
      );
    } catch (e, stackTrace) {
      _errorMessage = 'Bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      
      AppLogger.error('Error in listenToRecentStories', 
        tag: 'HomeViewModel', 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  // Temizle
  @override
  void dispose() {
    _recentStoriesSubscription?.cancel();
    super.dispose();
  }
}
