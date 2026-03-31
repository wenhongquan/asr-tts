import numpy as np
from typing import Optional


class QwenASREngine:
    def __init__(
        self,
        # model_id: str = "Qwen/Qwen3-ASR-1.7B",
        model_id: str="Qwen/Qwen3-ASR-0.6B",
        device: str = "auto",
        language: Optional[str] = None
    ):
        import torch
        from qwen_asr import Qwen3ASRModel
        
        self.model_id = model_id
        self.language = language
        self.sample_rate = 16000
        
        if device == "auto":
            device = "cuda" if torch.cuda.is_available() else "cpu"
        
        self.device = device
        dtype = torch.float16 if device == "cuda" else torch.float32
        
        print(f"Loading Qwen3-ASR model: {model_id} on {device}")
        
        self.model = Qwen3ASRModel.from_pretrained(
            model_id,
            dtype=dtype,
            device_map=device
        )
        print("Model loaded successfully")

    def transcribe_audio(
        self,
        audio_data: bytes,
        sample_rate: int = 16000
    ) -> dict:
        audio_array = self._bytes_to_array(audio_data)
        return self.transcribe_array(audio_array, sample_rate)

    def transcribe_array(
        self,
        audio_array: np.ndarray,
        sample_rate: int = 16000
    ) -> dict:
        if sample_rate != self.sample_rate:
            audio_array = self._resample(audio_array, sample_rate, self.sample_rate)
        
        result = self.model.transcribe(
            audio=(audio_array, self.sample_rate),
            language=self.language
        )
        
        return {
            'text': result[0].text,
            'segments': [{'text': result[0].text}],
            'language': result[0].language
        }

    def _bytes_to_array(self, audio_bytes: bytes) -> np.ndarray:
        int16_array = np.frombuffer(audio_bytes, dtype=np.int16)
        return int16_array.astype(np.float32) / 32768.0

    def _resample(self, audio: np.ndarray, orig_sr: int, target_sr: int) -> np.ndarray:
        if orig_sr == target_sr:
            return audio
        duration = len(audio) / orig_sr
        new_length = int(duration * target_sr)
        indices = np.linspace(0, len(audio) - 1, new_length)
        return np.interp(indices, np.arange(len(audio)), audio)

    def get_model_info(self) -> dict:
        return {
            'model_id': self.model_id,
            'device': self.device,
            'language': self.language
        }
