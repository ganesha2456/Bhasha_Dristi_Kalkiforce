from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from transformers import AutoModelForImageTextToText, AutoProcessor
from PIL import Image
import torch
import io
import collections
from pydantic import BaseModel
from pydub import AudioSegment
import speech_recognition as sr

from transLit import transliterate_text

# -------------------- APP SETUP --------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------- MODEL SETUP (GPU SAFE) --------------------
MODEL_NAME = "Qwen/Qwen2.5-VL-3B-Instruct"
device = "cuda" if torch.cuda.is_available() else "cpu"

if device != "cuda":
    raise RuntimeError("CUDA GPU is required")

model = AutoModelForImageTextToText.from_pretrained(
    MODEL_NAME,
    torch_dtype=torch.float32
).to(device)

model.eval()
processor = AutoProcessor.from_pretrained(MODEL_NAME)

# -------------------- ROBUST PER-LINE LANGUAGE DETECTION --------------------
def detect_language_by_unicode(text: str):
    if not text.strip():
        return "English"

    counts = collections.Counter()
    for ch in text:
        if not ch.strip():
            continue
        code = ord(ch)

        if 0x0B00 <= code <= 0x0B7F: counts["Odia"] += 1
        elif 0x0980 <= code <= 0x09FF: counts["Bengali"] += 1
        elif 0x0900 <= code <= 0x097F: counts["Hindi/Devanagari"] += 1
        elif 0x0A00 <= code <= 0x0A7F: counts["Punjabi"] += 1
        elif 0x0A80 <= code <= 0x0AFF: counts["Gujarati"] += 1
        elif 0x0B80 <= code <= 0x0BFF: counts["Tamil"] += 1
        elif 0x0C00 <= code <= 0x0C7F: counts["Telugu"] += 1
        elif 0x0C80 <= code <= 0x0CFF: counts["Kannada"] += 1
        elif 0x0D00 <= code <= 0x0D7F: counts["Malayalam"] += 1
        elif code < 128: counts["English"] += 1

    return counts.most_common(1)[0][0] if counts else "English"

# -------------------- OCR ENDPOINT (HIGH-ACCURACY VLM MODE) --------------------
@app.post("/ocr")
async def ocr(
    file: UploadFile = File(...),
    target_script: str = Form("Latin")
):
    try:
        img_bytes = await file.read()
        image = Image.open(io.BytesIO(img_bytes)).convert("RGB")

        # 🔒 STRONG OCR-ONLY PROMPT
        messages = [
            {
                "role": "user",
                "content": [
                    {"type": "image", "image": image},
                    {
                        "type": "text",
                        "text":
                        "You are an OCR engine. "
                        "Extract ALL text EXACTLY as it appears in the image. "
                        "Preserve spelling, capitalization, punctuation, line breaks, and symbols. "
                        "Do NOT translate. Do NOT paraphrase. "
                        "Return text line by line in reading order."
                    }
                ]
            }
        ]

        inputs = processor.apply_chat_template(
            messages,
            tokenize=True,
            add_generation_prompt=True,
            return_dict=True,
            return_tensors="pt"
        ).to(device)

        with torch.inference_mode():
            generated = model.generate(
                **inputs,
                max_new_tokens=1024,
                do_sample=False
            )

        prompt_len = inputs["input_ids"].shape[-1]
        raw_text = processor.decode(
            generated[0, prompt_len:],
            skip_special_tokens=True
        ).strip()

        # -------------------- LINE-WISE POST PROCESSING --------------------
        lines = [ln.strip() for ln in raw_text.splitlines() if ln.strip()]

        processed_lines = []
        for line in lines:
            lang = detect_language_by_unicode(line)

            # 🚫 DO NOT TRANSLITERATE ENGLISH NAMES
            if lang == "English":
                processed_lines.append(line)
            else:
                processed_lines.append(
                    transliterate_text(line, lang, target_script)
                )

        return {
            "extracted_text": "\n".join(lines),
            "language_per_line": [
                detect_language_by_unicode(l) for l in lines
            ],
            "target_script": target_script,
            "transliterated": "\n".join(processed_lines)
        }

    except Exception as e:
        return JSONResponse({"error": str(e)}, status_code=500)

# -------------------- TEXT TRANSLITERATION --------------------
class TextRequest(BaseModel):
    text: str
    target_script: str

@app.post("/text_transliterate")
async def text_transliterate(req: TextRequest):
    lang = detect_language_by_unicode(req.text)

    if lang == "English":
        return {
            "language": lang,
            "transliterated": req.text
        }

    return {
        "language": lang,
        "transliterated": transliterate_text(
            req.text, lang, req.target_script
        )
    }

# -------------------- VOICE TRANSLITERATION --------------------
class ResponseModel(BaseModel):
    transliterated_text: str
    target_language: str

@app.post("/voice-transliterate", response_model=ResponseModel)
async def voice_to_transliteration(
    file: UploadFile = File(...),
    target_lang: str = Form(...)
):
    recognizer = sr.Recognizer()

    audio_bytes = await file.read()
    audio = AudioSegment.from_file(io.BytesIO(audio_bytes))
    wav_io = io.BytesIO()
    audio.export(wav_io, format="wav")
    wav_io.seek(0)

    with sr.AudioFile(wav_io) as source:
        audio_data = recognizer.record(source)
        try:
            text = recognizer.recognize_google(audio_data)
        except:
            text = ""

    transliterated = transliterate_text(text, "English", target_lang)

    return ResponseModel(
        transliterated_text=transliterated,
        target_language=target_lang
    )

# -------------------- HEALTH CHECK --------------------
@app.get("/")
def root():
    return {
        "status": "High-accuracy VLM OCR + Transliteration API running"
    }
 