// lib/features/story/detail/presentation/screens/story_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/core.dart';
import '../../../../../services/apis/story_image_service.dart';
import '../../../../../services/apis/eleven_labs_tts_service.dart';
import '../../../../../shared/services/voice_profile_service.dart';
import '../../../../../viewmodel/profile_view_model.dart';
import '../../../../../services/models/firebase/story_model.dart';
import '../../../../../shared/services/story_service.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/animated_button.dart';
import '../../../../../shared/widgets/story_narration_bar.dart';
import '../../../video/story_video_screen.dart';
import '../../../../community/presentation/widgets/social_action_bar.dart';
import '../../../../print/presentation/screens/print_book_screen.dart';
import '../../../../../services/injector.dart';
import '../../../../../services/models/network/result.dart';
import '../../../../../services/advert/ad_service.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final StoryService _storyService = injector<StoryService>();
  StoryModel? _story;
  bool _isLoading = true;
  String? _errorMessage;
  bool _didShowInterstitial = false;

  @override
  void initState() {
    super.initState();
    _loadStory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInterstitialOnce();
    });
  }

  Future<void> _showInterstitialOnce() async {
    if (_didShowInterstitial) return;
    _didShowInterstitial = true;
    await AdService().showInterstitialAd();
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _storyService.getStory(widget.storyId);

    if (result is Success<StoryModel, Exception>) {
      setState(() {
        _story = (result as Success<StoryModel, Exception>).value;
        _isLoading = false;
      });
    } else if (result is Failure<StoryModel, Exception>) {
      setState(() {
        _errorMessage = (result as Failure<StoryModel, Exception>).exception.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _shareAsImage() async {
    if (_story == null) return;
    final isPremium = context.read<ProfileViewModel>().isPremium;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Görsel hazırlanıyor…')),
    );
    try {
      final path = await injector<StoryImageService>().renderStoryCard(
        title: _story!.title,
        content: _story!.content,
        category: _story!.category,
        addWatermark: !isPremium,
      );
      messenger.hideCurrentSnackBar();
      await Share.shareXFiles(
        [XFile(path)],
        text: '${_story!.title} 🌙 — HistoryBox ile oluşturuldu',
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('Paylaşılamadı: $e')),
      );
    }
  }

  Future<void> _downloadAudio() async {
    if (_story == null) return;
    final tts = injector<ElevenLabsTtsService>();
    final messenger = ScaffoldMessenger.of(context);
    if (!tts.isConfigured) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Ses indirmek için ElevenLabs API anahtarı gerekli (.env)')),
      );
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Ses hazırlanıyor…')),
    );
    try {
      final voiceId = await injector<VoiceProfileService>().activeVoiceId();
      final src = await tts.synthesizeToFile(
        _story!.content,
        calm: true,
        voiceIdOverride: voiceId,
      );
      // İndirme için güzel bir dosya adı
      final safe = _story!.title
          .replaceAll(RegExp(r'[^A-Za-z0-9çğıöşüÇĞİÖŞÜ _-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      final dir = await getTemporaryDirectory();
      final outPath = '${dir.path}/${safe.isEmpty ? 'masal' : safe}.mp3';
      await File(src).copy(outPath);

      messenger.hideCurrentSnackBar();
      await Share.shareXFiles(
        [XFile(outPath, mimeType: 'audio/mpeg')],
        text: '${_story!.title} 🌙 — HistoryBox',
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('Ses indirilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: LoadingWidget(message: 'Hikaye yükleniyor...'),
        ),
      );
    }

    if (_errorMessage != null || _story == null) {
      return Scaffold(
        body: SafeArea(
          child: EmptyState(
            emoji: AppAssets.cloudEmoji,
            title: 'Bir Hata Oluştu',
            message: _errorMessage ?? 'Hikaye bulunamadı',
            buttonText: 'Tekrar Dene',
            onButtonPressed: _loadStory,
          ),
        ),
      );
    }

    final categoryColor = AppColors.categoryColors[_story!.category] ?? 
                          AppColors.primaryRed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: AnimatedSoftBackground(
          colors: AppColors.premiumBackgroundGradient,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BackButtonHeader(
                  title: _story!.title,
                  fallbackRoute: '/history',
                ),
              ),
              // Content
              SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            AppAssets.categoryEmojis[_story!.category] ??
                                AppAssets.bookEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Text(
                          _story!.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Sosyal aksiyonlar (beğeni / yorum / kaydet / paylaş)
                SocialActionBar(story: _story!),

                const SizedBox(height: AppDimensions.paddingL),

                // Sesli anlatım (uyku masalı modu)
                StoryNarrationBar(
                  text: _story!.content,
                  title: _story!.title,
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Metadata
                Row(
                  children: [
                    _buildChip(
                      _story!.category,
                      categoryColor,
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    _buildChip(
                      _story!.ageGroup,
                      AppColors.ageGroupColors[_story!.ageGroup] ?? 
                        AppColors.accentBlue,
                    ),
                    const Spacer(),
                    Text(
                      _story!.createdAt.toFormattedDate(),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingXL),

                const BannerAdSlot(),

                const SizedBox(height: AppDimensions.paddingXL),

                // Content
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    _story!.content,
                    style: AppTextStyles.storyReading.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Yazıyı görsel kart olarak paylaş
                OutlinedButton.icon(
                  onPressed: _shareAsImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Yazıyı görsel olarak paylaş'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Seslendirmeyi MP3 olarak indir
                OutlinedButton.icon(
                  onPressed: _downloadAudio,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Sesi indir (MP3)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Otomatik masal videosu
                AnimatedButton(
                  text: 'Bu masaldan video oluştur',
                  icon: Icons.movie_creation_rounded,
                  gradientColors: AppColors.premiumGradient,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryVideoScreen(
                          title: _story!.title,
                          content: _story!.content,
                          category: _story!.category,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Fiziksel kitap baskısı
                AnimatedButton(
                  text: 'Bu masalı kitap olarak bastır',
                  icon: Icons.menu_book_rounded,
                  backgroundColor: AppColors.gold,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrintBookScreen(
                          storyId: _story!.id,
                          title: _story!.title,
                          content: _story!.content,
                          category: _story!.category,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.paddingXL),
              ]),
            ),
          ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _storyService.toggleFavorite(
            _story!.id,
            !_story!.isFavorite,
          );
          
          _loadStory(); // Reload to get updated favorite status
        },
        child: Icon(
          _story!.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
