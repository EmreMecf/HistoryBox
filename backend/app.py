# backend/app.py
#
# 🎙️ HistoryBox TTS backend — VoxCPM (OpenBMB) sarmalayıcı.
# Flutter uygulaması bu servise istek atar; VoxCPM GPU'da seslendirme/klonlama
# yapar ve ses dosyası döner. ElevenLabs'ın yerini alır (Türkçe + ücretsiz).
#
# Çalıştırma:  uvicorn app:app --host 0.0.0.0 --port 8000
# Gerekli: GPU (~8GB VRAM), CUDA 12+, ffmpeg kurulu olmalı.
import io
import json
import os
import subprocess
import tempfile
import uuid
from pathlib import Path
from typing import Optional

import numpy as np
import soundfile as sf
from fastapi import FastAPI, File, Form, Header, HTTPException, UploadFile
from fastapi.responses import Response
from pydantic import BaseModel

from voxcpm import VoxCPM  # pip install voxcpm

# ---- Yapılandırma (ortam değişkenleri) ----
API_KEY = os.environ.get("BACKEND_API_KEY", "")          # app ile paylaşılan gizli anahtar
MODEL_ID = os.environ.get("VOXCPM_MODEL", "openbmb/VoxCPM2")  # README'den doğrula
DATA_DIR = Path(os.environ.get("DATA_DIR", "/data"))
VOICES_DIR = DATA_DIR / "voices"
VOICES_DIR.mkdir(parents=True, exist_ok=True)

app = FastAPI(title="HistoryBox TTS (VoxCPM)")
model: Optional[VoxCPM] = None


@app.on_event("startup")
def _load_model():
    global model
    # Model GPU'ya bir kez yüklenir (sunucu açılışında).
    model = VoxCPM.from_pretrained(MODEL_ID)


def _auth(x_api_key: str):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Unauthorized")


def _sample_rate() -> int:
    return int(getattr(model, "sample_rate", 16000))


def _wav_to_mp3(wav: np.ndarray, sr: int) -> bytes:
    """VoxCPM çıktısını (numpy wav) mp3'e çevirir (ffmpeg)."""
    with tempfile.TemporaryDirectory() as d:
        wpath, mpath = os.path.join(d, "a.wav"), os.path.join(d, "a.mp3")
        sf.write(wpath, wav, sr)
        subprocess.run(
            ["ffmpeg", "-y", "-i", wpath, "-b:a", "128k", mpath],
            check=True, capture_output=True,
        )
        return Path(mpath).read_bytes()


# ===================== ŞEMALAR =====================
class TtsRequest(BaseModel):
    text: str
    voice_id: Optional[str] = None  # klon ses (varsa)
    calm: bool = True               # uyku/sakin ton


# ===================== UÇLAR =====================
@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": model is not None}


@app.post("/tts")
def tts(req: TtsRequest, x_api_key: str = Header(default="")):
    """Metni seslendirir. voice_id verilirse o klon sesle okur."""
    _auth(x_api_key)
    if model is None:
        raise HTTPException(503, "Model yükleniyor")

    prompt_wav, prompt_text = None, None
    if req.voice_id:
        ref = VOICES_DIR / f"{req.voice_id}.wav"
        meta = VOICES_DIR / f"{req.voice_id}.json"
        if ref.exists():
            prompt_wav = str(ref)
            if meta.exists():
                prompt_text = json.loads(meta.read_text()).get("transcript") or None

    # Uyku modu: daha yavaş/sakin için cfg/timesteps ayarlanabilir.
    wav = model.generate(
        text=req.text,
        prompt_wav_path=prompt_wav,   # klonlama referansı (opsiyonel)
        prompt_text=prompt_text,      # referans transkripti (daha iyi klon)
        cfg_value=2.0,
        inference_timesteps=16 if req.calm else 10,
    )
    wav = np.asarray(wav, dtype=np.float32)
    sr = _sample_rate()

    try:
        return Response(content=_wav_to_mp3(wav, sr), media_type="audio/mpeg")
    except Exception:
        buf = io.BytesIO()
        sf.write(buf, wav, sr, format="WAV")
        return Response(content=buf.getvalue(), media_type="audio/wav")


@app.post("/voices")
async def create_voice(
    name: str = Form(...),
    transcript: str = Form(default=""),
    file: UploadFile = File(...),
    x_api_key: str = Header(default=""),
):
    """Ebeveyn ses kaydından klon ses oluşturur (referansı saklar)."""
    _auth(x_api_key)
    voice_id = uuid.uuid4().hex[:12]
    raw = await file.read()

    with tempfile.TemporaryDirectory() as d:
        inpath = os.path.join(d, "in")
        Path(inpath).write_bytes(raw)
        outpath = str(VOICES_DIR / f"{voice_id}.wav")
        # Referansı 16kHz mono wav'a normalize et
        subprocess.run(
            ["ffmpeg", "-y", "-i", inpath, "-ar", "16000", "-ac", "1", outpath],
            check=True, capture_output=True,
        )

    (VOICES_DIR / f"{voice_id}.json").write_text(
        json.dumps({"name": name, "transcript": transcript})
    )
    return {"voice_id": voice_id}


@app.delete("/voices/{voice_id}")
def delete_voice(voice_id: str, x_api_key: str = Header(default="")):
    _auth(x_api_key)
    for ext in ("wav", "json"):
        p = VOICES_DIR / f"{voice_id}.{ext}"
        if p.exists():
            p.unlink()
    return {"deleted": voice_id}
