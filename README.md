# 📚 HistoryBox - Çocuklar İçin Hikaye Oluşturma Uygulaması

HistoryBox, çocukların hayal güçlerini keşfetmeleri için tasarlanmış modern bir Flutter uygulamasıdır. Yapay zeka (ChatGPT) desteği ile çocuklar kendi hikayelerini oluşturabilir, okuyabilir ve kaydedebilirler.

## ✨ Özellikler

### 🎨 Çocuk Dostu Tasarım
- Renkli ve modern arayüz
- Emoji ve animasyonlarla zenginleştirilmiş deneyim
- Dark/Light tema desteği
- Smooth animasyonlar ve geçişler

### 🤖 AI Destekli Hikaye Oluşturma
- ChatGPT ile özelleştirilmiş hikaye oluşturma
- 6 farklı kategori: Masal, Hikaye, Şiir, Bilim, Macera, Komedi
- 4 yaş grubu desteği: 3-5, 6-8, 9-12, 13+ yaş
- Akıllı konu önerileri

### 👤 Kullanıcı Yönetimi
- Google ile giriş
- Misafir girişi
- Profil yönetimi
- Hikaye geçmişi

### 💾 Hikaye Yönetimi
- Firebase Firestore ile bulut depolama
- Favori hikayeleri kaydetme
- Kategoriye göre filtreleme
- Arama özelliği

## 🏗️ Mimari

Uygulama modern ve ölçeklenebilir bir mimari ile geliştirilmiştir:

```
lib/
├── core/                    # Temel yapılar
│   ├── constants/          # Sabitler
│   ├── extensions/         # Extension metodları
│   ├── thema/             # Tema ve renkler
│   └── utils/             # Yardımcı fonksiyonlar
├── features/               # Feature-based mimari
│   ├── auth/              # Kimlik doğrulama
│   ├── home/              # Ana sayfa
│   ├── story/             # Hikaye özellikleri
│   │   ├── create/       # Hikaye oluşturma
│   │   ├── detail/       # Hikaye detayı
│   │   └── list/         # Hikaye listesi
│   └── profile/           # Profil yönetimi
├── shared/                 # Paylaşılan bileşenler
│   ├── services/          # İş mantığı servisleri
│   └── widgets/           # Ortak widget'lar
└── services/              # Temel servisler
    ├── apis/             # API istemcileri
    ├── firebase/         # Firebase servisleri
    ├── models/           # Veri modelleri
    └── navigation/       # Routing
```

## 🚀 Teknolojiler

- **Flutter 3.8+** - Cross-platform UI framework
- **Firebase Authentication** - Kullanıcı kimlik doğrulama
- **Cloud Firestore** - NoSQL veritabanı
- **OpenAI ChatGPT API** - AI hikaye oluşturma
- **Provider** - State management
- **GetIt** - Dependency injection
- **GoRouter** - Navigasyon
- **Freezed** - Immutable model generation
- **Dio** - HTTP client

## 📦 Kurulum

### Gereksinimler
- Flutter SDK (3.8.1 veya üzeri)
- Dart SDK
- Firebase projesi
- OpenAI API anahtarı

### Adımlar

1. **Projeyi klonlayın:**
```bash
git clone <repository-url>
cd HistoryBox
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **Environment dosyasını oluşturun:**
`.env` dosyası oluşturun ve aşağıdaki anahtarları ekleyin:
```
CHATGPT_BASE_URL=https://api.openai.com/v1
CHATGPT_SECRET_KEY=your_openai_api_key
CHATGPT_ORGANIZATION=your_organization_id
CHATGPT_PROJECT=your_project_id
CHATGPT_MODEL=gpt-3.5-turbo
```

4. **Firebase'i yapılandırın:**
- Firebase Console'da yeni proje oluşturun
- Android/iOS uygulamalarınızı ekleyin
- `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
- FlutterFire CLI ile yapılandırın:
```bash
flutterfire configure
```

5. **Uygulamayı çalıştırın:**
```bash
flutter run
```

## 🎯 Kullanım

### Hikaye Oluşturma
1. Ana sayfada "Yeni Hikaye" butonuna tıklayın
2. Bir kategori seçin (Masal, Hikaye, Şiir, vb.)
3. Yaş grubunu belirleyin
4. Hikaye konusunu yazın veya önerilerden seçin
5. "Hikaye Oluştur" butonuna tıklayın
6. AI tarafından oluşturulan hikayeyi önizleyin
7. Beğendiyseniz kaydedin!

### Hikaye Okuma
- Ana sayfada son hikayeleri görüntüleyin
- Kategorilere göre hikayelere göz atın
- Hikaye kartlarına tıklayarak detayları okuyun
- Favori butonuyla beğendiğiniz hikayeleri işaretleyin

### Profil Yönetimi
- Profil sayfasında tüm hikayelerinizi görün
- Tema değiştirin (Aydınlık/Karanlık)
- Çıkış yapın

## 🎨 Tasarım Prensipleri

- **Çocuk Dostu**: Büyük butonlar, renkli tasarım, emoji kullanımı
- **Sezgisel**: Basit navigasyon, açık talimatlar
- **Eğlenceli**: Animasyonlar, interaktif öğeler
- **Güvenli**: Yaşa uygun içerik filtreleme

## 🔧 Geliştirme

### Build Runner
Model dosyalarını güncelledikten sonra:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Linting
Kod kalitesini kontrol edin:
```bash
flutter analyze
```

### Testing
Testleri çalıştırın:
```bash
flutter test
```

## 📱 Platform Desteği

- ✅ Android
- ✅ iOS
- 🚧 Web (experimental)
- 🚧 Desktop (experimental)

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje özel bir projedir ve ticari kullanım için izin gerektirir.

## 👨‍💻 Geliştirici

HistoryBox - 2026

## 🙏 Teşekkürler

- OpenAI - ChatGPT API
- Firebase - Backend servisleri
- Flutter Community - Harika paketler

---

**Not:** Bu uygulama, çocukların yaratıcılığını desteklemek ve okuma alışkanlığı kazandırmak amacıyla geliştirilmiştir.
