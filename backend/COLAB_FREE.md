# VoxCPM'i ÜCRETSİZ çalıştırma (Google Colab + tünel)

> Bu yöntem **TEST/geliştirme** içindir. Colab ücretsiz GPU verir ama oturum
> birkaç saatte kapanır, kalıcı/üretim değildir. Uygulamanın VoxCPM ile
> çalıştığını kanıtlamak ve denemek için mükemmeldir.

## Adımlar

1. https://colab.research.google.com → yeni notebook.
2. **Runtime → Change runtime type → GPU (T4)** seç.
3. Aşağıdaki hücreleri sırayla çalıştır.

### Hücre 1 — Kurulum
```python
!pip install -q voxcpm fastapi "uvicorn[standard]" soundfile numpy python-multipart nest-asyncio
!apt-get -qq install -y ffmpeg
# cloudflared (ücretsiz tünel, hesap gerektirmez)
!wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
!chmod +x /usr/local/bin/cloudflared
```

### Hücre 2 — Servis kodunu yaz
`backend/app.py` dosyasının içeriğini buraya yapıştır:
```python
%%writefile app.py
# ... (HistoryBox repo'daki backend/app.py içeriğinin tamamı) ...
```

### Hücre 3 — Servisi başlat (arka planda)
```python
import os, threading, uvicorn, nest_asyncio
os.environ["BACKEND_API_KEY"] = "test-anahtar-123"
os.environ["VOXCPM_MODEL"]    = "openbmb/VoxCPM2"   # README'den doğrula
os.environ["DATA_DIR"]        = "/content/data"
nest_asyncio.apply()
threading.Thread(
    target=lambda: uvicorn.run("app:app", host="0.0.0.0", port=8000),
    daemon=True,
).start()
print("Servis 8000'de başladı (model GPU'ya yükleniyor, ~1-2 dk)...")
```

### Hücre 4 — Public URL al (cloudflared)
```python
!cloudflared tunnel --url http://localhost:8000
```
Çıktıda şuna benzer bir adres görürsün:
```
https://rastgele-kelimeler.trycloudflare.com
```
**Bu adresi** uygulamanın `.env` dosyasındaki `VOXCPM_BASE_URL`'e yapıştır,
`VOXCPM_API_KEY=test-anahtar-123` yap ve `TTS_PROVIDER=voxcpm` seç.

### Test
Başka bir hücrede:
```python
import requests
r = requests.post("http://localhost:8000/tts",
    headers={"X-API-Key":"test-anahtar-123"},
    json={"text":"Bir varmış bir yokmuş, uzak bir diyarda küçük bir yıldız varmış.","calm":True})
open("test.mp3","wb").write(r.content); print(len(r.content), "bayt")
```

## Sınırlar (önemli)
- Colab oturumu **boşta ~90 dk**, en fazla **~12 saat** sonra kapanır → URL değişir.
- Aynı anda az kullanıcı; gerçek kullanıcılar için **değil**.
- Gerçek kullanım için aşağıdaki ucuz seçeneklere geç.

## Gerçek kullanım için ucuz/ücretsiz-kredili seçenekler
| Servis | Model | Not |
|---|---|---|
| **Modal** | Serverless GPU | Aylık ücretsiz kredi; sadece kullanınca öder |
| **HF Spaces (ZeroGPU)** | Time-shared GPU | Ücretsiz kotalı; Gradio/FastAPI Space |
| **RunPod Serverless** | Pay-per-second GPU | Boştayken ödeme yok; başlangıç kredisi |
| **Kaggle Notebook** | Ücretsiz T4 (30h/hafta) | Colab gibi, test amaçlı |

Önerilen üretim yolu: **Modal** veya **RunPod Serverless** (kullanım başına, çok ucuz).
