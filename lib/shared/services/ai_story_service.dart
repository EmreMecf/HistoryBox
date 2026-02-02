// lib/shared/services/ai_story_service.dart
import '../../services/apis/chat_gpt_api_client.dart';
import '../../services/models/network/result.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';

class AiStoryService {
  final ChatGptApiClient _chatGptClient;

  AiStoryService(this._chatGptClient);

  // Hikaye oluştur
  Future<Result<Map<String, String>, Exception>> generateStory({
    required String category,
    required String ageGroup,
    required String topic,
    int length = 500,
  }) async {
    try {
      AppLogger.log('Generating story with AI', tag: 'AiStoryService');
      AppLogger.debug('Category: $category, AgeGroup: $ageGroup, Topic: $topic',
        tag: 'AiStoryService'
      );

      // Prompt oluştur
      final prompt = _buildPrompt(
        category: category,
        ageGroup: ageGroup,
        topic: topic,
        length: length,
      );

      // ChatGPT'den yanıt al
      final response = await _chatGptClient.chaMessage(prompt);

      if (response.choices.isEmpty) {
        return Failure(Exception('AI yanıt vermedi'));
      }

      final content = response.choices.first.message.content;

      // Başlık ve içeriği ayır
      final storyData = _parseStoryContent(content);

      AppLogger.success('Story generated successfully', tag: 'AiStoryService');

      return Success(storyData);
    } catch (e, stackTrace) {
      AppLogger.error('Error generating story',
        tag: 'AiStoryService',
        error: e,
        stackTrace: stackTrace
      );
      return Failure(Exception('Hikaye oluşturulamadı: $e'));
    }
  }

  // Prompt oluştur
  String _buildPrompt({
    required String category,
    required String ageGroup,
    required String topic,
    required int length,
  }) {
    String ageGroupDescription = _getAgeGroupDescription(ageGroup);
    String categoryInstruction = _getCategoryInstruction(category);
    String categoryDescription = _getCategoryDescription(category);

    return '''
$categoryInstruction

Kategori: $categoryDescription
Yaş Grubu: $ageGroupDescription
Konu: $topic
Uzunluk: Yaklaşık $length kelime

Kurallar:
1. Başlığı ilk satıra "Başlık: " ile başlayarak yaz
2. İçerik başlıktan sonra gelsin
3. Çocuklar için eğitici ve eğlenceli olmalı
4. Dil basit ve anlaşılır olmalı
5. Türkçe olmalı
6. Pozitif bir mesaj içermeli

Lütfen sadece başlık ve içeriği yaz, ek açıklama yapma.
''';
  }

  // Yaş grubu açıklaması
  String _getAgeGroupDescription(String ageGroup) {
    switch (ageGroup) {
      case '3-5 Yaş':
        return 'Çok basit cümleler, tekrarlar ve renkli anlatım ile 3-5 yaş arası';
      case '6-8 Yaş':
        return 'Basit ve akıcı dil ile 6-8 yaş arası';
      case '9-12 Yaş':
        return 'Gelişmiş kelime hazinesi ve daha detaylı anlatım ile 9-12 yaş arası';
      case '13+ Yaş':
        return 'Zengin dil ve derin mesajlar ile 13 yaş ve üzeri';
      default:
        return '6-8 yaş arası';
    }
  }

  // Kategori talimatı (ne yazılacak)
  String _getCategoryInstruction(String category) {
    switch (category) {
      case 'Masal':
      case 'Fairy Tale':
        return 'Sihirli, fantastik ve büyülü bir MASAL yaz';
      case 'Şiir':
        return 'Uyaklı, ahenkli ve akıcı bir ŞİİR yaz';
      case 'Bilim':
      case 'Science':
      case 'Educational':
        return 'Bilim ve doğadan ilham alan EĞİTİCİ bir hikaye yaz';
      case 'Macera':
      case 'Adventure':
        return 'Heyecan dolu bir MACERA hikayesi yaz';
      case 'Bedtime':
        return 'Rahatlatıcı ve sakinleştirici bir UYKU MASALI yaz';
      case 'Fantasy':
        return 'Hayal gücünü zorlayan FANTASTİK bir hikaye yaz';
      case 'History':
        return 'Tarihi olaylardan ilham alan EĞİTİCİ bir hikaye yaz';
      case 'Moral Stories':
        return 'Ahlaki değerler öğreten bir HİKAYE yaz';
      case 'Komedi':
        return 'Eğlenceli ve güldürücü bir HİKAYE yaz';
      case 'Hikaye':
      default:
        return 'Günlük hayattan ilham alan gerçekçi bir HİKAYE yaz';
    }
  }

  // Kategori açıklaması
  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Masal':
        return 'Sihirli dünya, fantastik karakterler';
      case 'Hikaye':
        return 'Gerçekçi, günlük hayat';
      case 'Şiir':
        return 'Uyaklı, ritmik, kısa';
      case 'Bilim':
        return 'Bilim, doğa, keşif';
      case 'Macera':
        return 'Heyecan, aksiyon, keşif';
      case 'Komedi':
        return 'Komik, eğlenceli';
      default:
        return 'Eğlenceli içerik';
    }
  }

  // Hikaye içeriğini parse et
  Map<String, String> _parseStoryContent(String content) {
    try {
      // Başlığı bul
      String title = '';
      String story = content;

      if (content.contains('Başlık:')) {
        final lines = content.split('\n');
        for (var line in lines) {
          if (line.trim().startsWith('Başlık:')) {
            title = line.replaceFirst('Başlık:', '').trim();
            // Başlık satırını kaldır
            story = content.replaceFirst(line, '').trim();
            break;
          }
        }
      } else {
        // Başlık yoksa, ilk satırı başlık olarak al
        final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
        if (lines.isNotEmpty) {
          title = lines.first.trim();
          story = lines.skip(1).join('\n').trim();
        }
      }

      // Başlık yoksa varsayılan
      if (title.isEmpty) {
        title = 'Yeni Hikaye';
      }

      // Hikaye boşsa hata
      if (story.isEmpty) {
        story = content;
      }

      return {
        'title': title,
        'content': story,
      };
    } catch (e) {
      AppLogger.error('Error parsing story content',
        tag: 'AiStoryService',
        error: e
      );

      return {
        'title': 'Yeni Hikaye',
        'content': content,
      };
    }
  }

  // Hikaye devam ettir
  Future<Result<String, Exception>> continueStory(String currentStory) async {
    try {
      AppLogger.log('Continuing story with AI', tag: 'AiStoryService');

      final prompt = '''
Aşağıdaki hikayenin devamını yaz. Aynı tarzda ve karakterlerle devam et.
Yaklaşık 200 kelime ekle. Sadece devam metnini yaz, açıklama yapma.

Mevcut Hikaye:
$currentStory

Devam:
''';

      final response = await _chatGptClient.chaMessage(prompt);

      if (response.choices.isEmpty) {
        return Failure(Exception('AI yanıt vermedi'));
      }

      final continuation = response.choices.first.message.content.trim();

      AppLogger.success('Story continued successfully', tag: 'AiStoryService');

      return Success(continuation);
    } catch (e, stackTrace) {
      AppLogger.error('Error continuing story',
        tag: 'AiStoryService',
        error: e,
        stackTrace: stackTrace
      );
      return Failure(Exception('Hikaye devam ettirilemedi: $e'));
    }
  }

  // Hikaye önerisi
  Future<Result<List<String>, Exception>> suggestTopics(String category) async {
    try {
      AppLogger.log('Getting topic suggestions', tag: 'AiStoryService');

      final prompt = '''
$category kategorisinde çocuklar için 5 hikaye konusu öner.
Sadece konu başlıklarını listele, numaralandırma yap.
Kısa ve öz başlıklar olsun.

Örnek format:
1. Konu başlığı
2. Konu başlığı
...
''';

      final response = await _chatGptClient.chaMessage(prompt);

      if (response.choices.isEmpty) {
        return Failure(Exception('AI yanıt vermedi'));
      }

      final content = response.choices.first.message.content;

      // Liste olarak parse et
      final topics = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            // Numaraları kaldır
            return line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
          })
          .where((topic) => topic.isNotEmpty)
          .toList();

      AppLogger.success('Got ${topics.length} topic suggestions', tag: 'AiStoryService');

      return Success(topics);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting topic suggestions',
        tag: 'AiStoryService',
        error: e,
        stackTrace: stackTrace
      );
      return Failure(Exception('Konular alınamadı: $e'));
    }
  }
}
