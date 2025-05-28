# app/asr.py
import whisper

# load once at import time
model = whisper.load_model("small")

def transcribe_audio(path: str) -> str:
    """
    Given a path to an audio file (.wav, .mp3), returns the plain-text transcript.
    """
    result = model.transcribe(path)
    return result["text"].strip()
