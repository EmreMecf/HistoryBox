# 📚 HistoryBox — Çocuklar İçin AI Masal Uygulaması

HistoryBox, çocukların hayal gücünü besleyen, yapay zeka destekli premium bir
Flutter uygulamasıdır. Çocuklar kişiselleştirilmiş masallar oluşturur, sakin bir
sesle dinler, videoya dönüştürür, toplulukta paylaşır ve uyku rutinine eşlik
eden ninni/meditasyonlarla huzurlu bir uykuya dalar.

> 🌙 **Tema:** "Aurora Dream" — premium gece kimliği (indigo/mor gradyan + altın
> vurgu, glassmorphism, yıldız dokusu).

---

## ✨ Özellikler

### 🤖 AI Masal Üretimi (Google Gemini)
- 6 kategori (Masal, Bilim, Komedi, Şiir, Macera, Hikaye) + 4 yaş grubu
- **Kişiselleştirme:** çocuğun adı kahraman olur + ilgi alanları masala katılır
- **Çok dilli üretim** (Türkçe, English, Deutsch, Français, Español, العربية, Italiano)
- **Çizimden masal:** çocuğun çizimini fotoğrafla → Gemini vision'la masal

### 🎙️ Sesli Anlatım (ElevenLabs)
- Stüdyo kalitesinde Türkçe seslendirme, **uyku modu** (sakin/yavaş ton)
- **Ses klonlama** (premium): ebeveynin sesiyle masal okuma
- Seslendirmeyi **MP3 olarak indirme**
- Cihaz TTS yedeği (anahtar yoksa)

### 🎬 Otomatik Masal Videosu
- Masal → sahnelere bölünür → temalı kart / **AI illüstrasyon** (premium, Imagen)
- **Geçiş efektleri + arka plan müziği** (ffmpeg), MP4 olarak paylaşılır
- Ücretsizde filigran, premiumda filigransız

### 🌐 Topluluk (Sosyal)
- Masalları yayınla; başkalarının masallarını **beğen, yorumla, kaydet**
- Premium kullanıcılar feed'de 👑 rozetiyle görünür
- Yayınlamadan önce **Gemini ile içerik moderasyonu**

### 🌙 Ninni & Meditasyon & Doğa Sesleri
- Ninniler + doğa sesleri (yağmur/orman/okyanus/şömine) — döngü + **arka planda çalma**
- ElevenLabs ile rehberli meditasyonlar
- **Uyku zamanlayıcısı** (15/30/60 dk → otomatik durur)

### 💎 Premium (Abonelik)
- Sınırsız masal, ses klonlama, filigransız + AI illüstrasyon, reklamsız
- Aylık & yıllık plan + 7 gün ücretsiz deneme + "Geri Yükle"
- **Premium temalar:** 5 vurgu rengi (Aurora ücretsiz; Okyanus/Gün Batımı/Orman/Galaksi premium)

### 🛡️ Ebeveyn Kontrolleri
- PIN ile topluluk erişimini koru, içerik moderasyonu

### 🪙 Diğer
- Token ekonomisi (ücretsiz kullanım), ödüllü reklam, IAP token paketleri
- Google/Misafir girişi, Aydınlık/Gece teması, TR/EN arayüz

---

## 🚀 Teknolojiler
- **Flutter** (Provider, GetIt, GoRouter, Freezed, Dio)
- **Firebase** (Auth, Firestore, Storage)
- **Google Gemini** (metin + vision) & **Imagen** (illüstrasyon)
- **ElevenLabs** (seslendirme + ses klonlama)
- `just_audio` / `just_audio_background`, `ffmpeg_kit_flutter_new`, `video_player`,
  `record`, `image_picker`, `google_mobile_ads`, `in_app_purchase`

---

## 📦 Kurulum

1. **Bağımlılıklar:**
   ```bash
   flutter pub get
   ```
2. **Ortam dosyası:** `.env.example`'ı `.env` olarak kopyala ve anahtarları doldur:
   ```
   GEMINI_API_KEY=...        # Google AI Studio
   ELEVENLABS_API_KEY=...    # (seslendirme/klonlama için)
   ```
   > `.env` git'e dahil DEĞİLDİR (gizli). Her geliştirici kendi anahtarını koyar.
3. **Firebase:** `flutterfire configure` ile yapılandır (google-services.json / GoogleService-Info.plist).
4. **Ses dosyaları (opsiyonel):** Telifsiz ninni/doğa sesi mp3'lerini
   `lib/assets/audio/lullabies/` ve `lib/assets/audio/nature/` klasörlerine ekle
   (README'lerdeki isimlerle).
5. **Çalıştır:**
   ```bash
   flutter run
   ```

### Firestore (yayın öncesi)
- `stories` için `isPublic + publishedAt` ve `isPublic + likeCount` composite index'leri
- Güvenlik kuralları (public okuma, auth'lu beğeni/yorum/kaydet)
- Mağazada `premium_monthly` ve `premium_yearly` abonelik ürünleri

---

## 🏗️ Mimari
```
lib/
├── core/            # tema (Aurora Dream), widget'lar, sabitler, çeviriler
├── features/        # auth, home, story (create/detail/list/video/drawing),
│                    # community, premium, parental, voice, relax, print, token
├── services/        # apis (gemini, elevenlabs, imagen, moderation, image, voice),
│                    # firebase, repositories, navigation, models, injector (GetIt)
├── shared/          # services (community, story, child_profile, parental...) + widgets
└── viewmodel/       # provider view-model'ler
```

## 🔮 Yol haritası
- **VoxCPM** (açık kaynak, Türkçe TTS + ses klonlama) — `backend/` klasöründe hazır
  FastAPI scaffold. Uygulama gelir kazanmaya başlayınca ElevenLabs yerine kendi
  GPU sunucusunda çalıştırılacak (karakter başına ücretsiz).

---

## 📄 Lisans
Özel/ticari proje. İzinsiz kullanılamaz.

**HistoryBox — 2026** · Çocukların yaratıcılığını ve okuma sevgisini desteklemek için. 🌙
