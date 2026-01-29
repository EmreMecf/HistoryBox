// lib/features/story/create/presentation/viewmodels/story_create_view_model.dart
import 'package:flutter/material.dart';
import '../../../../../services/models/network/result.dart';
import '../../../../../shared/services/ai_story_service.dart';
import '../../../../../shared/services/story_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/constants/app_constants.dart';

enum StoryCreationStep {
  selectCategory,
  selectAgeGroup,
  enterTopic,
  generating,
  preview,
  complete,
}

class StoryCreateViewModel with ChangeNotifier {
  final AiStoryService _aiStoryService;
  final StoryService _storyService;

  StoryCreateViewModel(this._aiStoryService, this._storyService);

  // Step Management
  StoryCreationStep _currentStep = StoryCreationStep.selectCategory;
  StoryCreationStep get currentStep => _currentStep;

  // Story Data
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedAgeGroup;
  String? get selectedAgeGroup => _selectedAgeGroup;

  String? _topic;
  String? get topic => _topic;

  String? _generatedTitle;
  String? get generatedTitle => _generatedTitle;

  String? _generatedContent;
  String? get generatedContent => _generatedContent;

  // UI States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> _topicSuggestions = [];
  List<String> get topicSuggestions => _topicSuggestions;

  // Kategori seç
  void selectCategory(String category) {
    _selectedCategory = category;
    _currentStep = StoryCreationStep.selectAgeGroup;
    notifyListeners();

    // Konu önerilerini al
    _loadTopicSuggestions(category);
  }

  // Yaş grubu seç
  void selectAgeGroup(String ageGroup) {
    _selectedAgeGroup = ageGroup;
    _currentStep = StoryCreationStep.enterTopic;
    notifyListeners();
  }

  // Konu gir
  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  // Konu önerilerini yükle
  Future<void> _loadTopicSuggestions(String category) async {
    try {
      AppLogger.log('Loading topic suggestions for: $category',
        tag: 'StoryCreateVM'
      );

      final result = await _aiStoryService.suggestTopics(category);

      if (result is Success<List<String>, Exception>) {
        _topicSuggestions = (result as Success<List<String>, Exception>).value ?? [];
        notifyListeners();

        AppLogger.success('Loaded ${_topicSuggestions.length} suggestions',
          tag: 'StoryCreateVM'
        );
      }
    } catch (e) {
      AppLogger.error('Error loading topic suggestions',
        tag: 'StoryCreateVM',
        error: e
      );
    }
  }

  // Hikaye oluştur
  Future<void> generateStory() async {
    if (_selectedCategory == null ||
        _selectedAgeGroup == null ||
        _topic == null ||
        _topic!.isEmpty) {
      _errorMessage = 'Lütfen tüm alanları doldurun';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _currentStep = StoryCreationStep.generating;
      _errorMessage = null;
      notifyListeners();

      AppLogger.log('Generating story', tag: 'StoryCreateVM');

      final result = await _aiStoryService.generateStory(
        category: _selectedCategory!,
        ageGroup: _selectedAgeGroup!,
        topic: _topic!,
        length: 500,
      );

      if (result is Success<Map<String, String>, Exception>) {
        final storyData = (result as Success<Map<String, String>, Exception>).value!;
        _generatedTitle = storyData['title'];
        _generatedContent = storyData['content'];
        _currentStep = StoryCreationStep.preview;

        AppLogger.success('Story generated successfully', tag: 'StoryCreateVM');
      } else if (result is Failure<Map<String, String>, Exception>) {
        _errorMessage = (result as Failure<Map<String, String>, Exception>).exception.toString();
        _currentStep = StoryCreationStep.enterTopic;

        AppLogger.error('Failed to generate story',
          tag: 'StoryCreateVM',
          error: (result as Failure<Map<String, String>, Exception>).exception
        );
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Hikaye oluşturulamadı: $e';
      _currentStep = StoryCreationStep.enterTopic;

      AppLogger.error('Error in generateStory',
        tag: 'StoryCreateVM',
        error: e,
        stackTrace: stackTrace
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hikayeyi kaydet
  Future<bool> saveStory(String userId) async {
    if (_generatedTitle == null || _generatedContent == null) {
      _errorMessage = 'Hikaye oluşturulmamış';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      AppLogger.log('Saving story', tag: 'StoryCreateVM');

      final result = await _storyService.createStory(
        title: _generatedTitle!,
        content: _generatedContent!,
        category: _selectedCategory!,
        ageGroup: _selectedAgeGroup!,
        userId: userId,
      );

      if (result is Success<String, Exception>) {
        _currentStep = StoryCreationStep.complete;

        AppLogger.success('Story saved with ID: ${(result as Success<String, Exception>).value}',
          tag: 'StoryCreateVM'
        );

        notifyListeners();
        return true;
      } else if (result is Failure<String, Exception>) {
        _errorMessage = (result as Failure<String, Exception>).exception.toString();

        AppLogger.error('Failed to save story',
          tag: 'StoryCreateVM',
          error: (result as Failure<String, Exception>).exception
        );

        notifyListeners();
        return false;
      }

      return false;
    } catch (e, stackTrace) {
      _errorMessage = 'Hikaye kaydedilemedi: $e';

      AppLogger.error('Error in saveStory',
        tag: 'StoryCreateVM',
        error: e,
        stackTrace: stackTrace
      );

      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hikayeyi düzenle
  void editTitle(String newTitle) {
    _generatedTitle = newTitle;
    notifyListeners();
  }

  void editContent(String newContent) {
    _generatedContent = newContent;
    notifyListeners();
  }

  // Yeniden oluştur
  Future<void> regenerateStory() async {
    await generateStory();
  }

  // Geri git
  void goBack() {
    switch (_currentStep) {
      case StoryCreationStep.selectAgeGroup:
        _currentStep = StoryCreationStep.selectCategory;
        break;
      case StoryCreationStep.enterTopic:
        _currentStep = StoryCreationStep.selectAgeGroup;
        break;
      case StoryCreationStep.preview:
        _currentStep = StoryCreationStep.enterTopic;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  // Sıfırla
  void reset() {
    _currentStep = StoryCreationStep.selectCategory;
    _selectedCategory = null;
    _selectedAgeGroup = null;
    _topic = null;
    _generatedTitle = null;
    _generatedContent = null;
    _errorMessage = null;
    _topicSuggestions = [];
    notifyListeners();
  }
}
