# HistoryBox TTS Backend (VoxCPM)

Bu klasör, **VoxCPM** (OpenBMB) ses modelini bir API servisi olarak çalıştırır.
Flutter uygulaması ElevenLabs yerine bu servise istek atarak **Türkçe**
seslendirme ve **ses klonlama** yapar — karakter başına ücret YOK.

## Nasıl çalışır (akış)

```
Flutter App  ──HTTPS + X-API-Key──►  Backend (FastAPI)  ──►  VoxCPM (GPU)
   │  POST /tts {text, voice_id, calm}                         │ seslendirme
   │  POST /voices (ses kaydı)  ──► klon referansı saklanır    │ klonlama
   ◄──────────── audio/mpeg (mp3) ◄────────────────────────────┘
```

- **Model bir kez GPU'ya yüklenir** (sunucu açılışında), sonra her istek hızlı.
- **/tts**: metni seslendirir. `voice_id` verilirse o klon sesle okur.
- **/voices**: ebeveyn ses kaydını yükler, referansı saklar, `voice_id` döner.
- Ses **mp3** olarak döner (ffmpeg ile), uygulama dosyayı çalar/indirir.

## Gereksinimler
- **GPU** ~8GB VRAM (örn. RTX 4090 / A10 / L4), CUDA 12+, ffmpeg.
- Python 3.10–3.12.

## Yerelde çalıştırma (GPU'lu makinede)
```bash
cd backend
pip install -r requirements.txt
export BACKEND_API_KEY="uzun-gizli-bir-anahtar"
export VOXCPM_MODEL="openbmb/VoxCPM2"   # tam id'yi VoxCPM README'den doğrula
export DATA_DIR="./data"
uvicorn app:app --host 0.0.0.0 --port 8000
```

## Docker ile
```bash
docker build -t historybox-tts .
docker run --gpus all -p 8000:8000 \
  -e BACKEND_API_KEY="uzun-gizli-bir-anahtar" \
  -v $(pwd)/data:/data historybox-tts
```

## Nerede barındırılır (GPU host)
- **Serverless GPU** (saniyelik ödeme, ölçeklenir): RunPod Serverless, Replicate, Modal, Beam.
- **Dedicated GPU VM** (sabit aylık): RunPod, Vast.ai, Lambda, AWS g5, GCP L4.
- MVP için **serverless** önerilir (kullanım başına ödersin, boştayken ödeme yok).

## Hızlı test
```bash
curl -X POST http://localhost:8000/tts \
  -H "Content-Type: application/json" -H "X-API-Key: uzun-gizli-bir-anahtar" \
  -d '{"text":"Bir varmış bir yokmuş, uzak bir diyarda...","calm":true}' \
  --output test.mp3
```

## ⚠️ Doğrulanacaklar
- VoxCPM'in **tam model id'si** ve `model.generate(...)` parametreleri (sürüme göre
  değişebilir) — [VoxCPM README](https://github.com/OpenBMB/VoxCPM)'den teyit et.
- Çıkış **sample rate** (48kHz olabilir) — `getattr(model,'sample_rate',...)` ile alınıyor.
- Üretimde `X-API-Key` yerine **Firebase ID token** doğrulaması eklemen daha güvenli.
