"""
Whisper ASR Engine - Wrapper for faster-whisper
"""
import io
import numpy as np
from typing import Optional, List, Callable
from faster_whisper import WhisperModel


class WhisperEngine:
    """
    Faster-Whisper based ASR engine with streaming support.
    """
    
    def __init__(
        self,
        model_size: str = "base",
        device: str = "auto",
        compute_type: str = "auto",
        download_root: Optional[str] = None,
        language: Optional[str] = "zh"
    ):
        """
        Initialize Whisper engine.
        
        Args:
            model_size: Model size (tiny, base, small, medium, large)
            device: Device to use (cpu, cuda, auto)
            compute_type: Compute type (float16, int8, auto)
            download_root: Model download directory
            language: Target language code (zh, en, etc.)
        """
        self.model_size = model_size
        self.language = language
        
        # Auto-detect device
        if device == "auto":
            device = "cuda" if self._check_cuda() else "cpu"
        
        # Auto-detect compute type
        if compute_type == "auto":
            compute_type = "float16" if device == "cuda" else "int8"
        
        self.device = device
        self.compute_type = compute_type
        
        print(f"Loading Whisper model: {model_size} on {device} ({compute_type})")
        self.model = WhisperModel(
            model_size,
            device=device,
            compute_type=compute_type,
            download_root=download_root
        )
        print(f"Model loaded successfully")
    
    def _check_cuda(self) -> bool:
        """Check if CUDA is available."""
        try:
            import torch
            return torch.cuda.is_available()
        except ImportError:
            return False
    
    def transcribe_audio(
        self,
        audio_data: bytes,
        sample_rate: int = 16000,
        callback: Optional[Callable] = None
    ) -> dict:
        """
        Transcribe audio data.
        
        Args:
            audio_data: Raw PCM audio bytes (16-bit, mono)
            sample_rate: Audio sample rate
            callback: Optional callback for streaming results
            
        Returns:
            Dictionary with transcription result
        """
        # Convert bytes to numpy array
        audio_array = self._bytes_to_array(audio_data)
        
        # Resample if needed
        if sample_rate != 16000:
            audio_array = self._resample(audio_array, sample_rate, 16000)
        
        # Run inference
        segments, info = self.model.transcribe(
            audio_array,
            language=self.language,
            beam_size=5,
            vad_filter=True,
            vad_parameters=dict(min_silence_duration_ms=500)
        )
        
        # Collect results
        full_text = ""
        segment_list = []
        
        for segment in segments:
            text = segment.text.strip()
            segment_list.append({
                'start': segment.start,
                'end': segment.end,
                'text': text
            })
            full_text += text + " "
            
            if callback:
                callback({
                    'text': text,
                    'start': segment.start,
                    'end': segment.end,
                    'is_final': False
                })
        
        return {
            'text': full_text.strip(),
            'segments': segment_list,
            'language': info.language,
            'language_probability': info.language_probability
        }
    
    def transcribe_array(
        self,
        audio_array: np.ndarray,
        sample_rate: int = 16000
    ) -> dict:
        """
        Transcribe from numpy array.
        
        Args:
            audio_array: Audio as numpy array (float32, range [-1, 1])
            sample_rate: Audio sample rate
            
        Returns:
            Dictionary with transcription result
        """
        # Resample if needed
        if sample_rate != 16000:
            audio_array = self._resample(audio_array, sample_rate, 16000)
        
        segments, info = self.model.transcribe(
            audio_array,
            language=self.language,
            beam_size=5,
            vad_filter=True
        )
        
        full_text = ""
        segment_list = []
        
        for segment in segments:
            text = segment.text.strip()
            segment_list.append({
                'start': segment.start,
                'end': segment.end,
                'text': text
            })
            full_text += text + " "
        
        return {
            'text': full_text.strip(),
            'segments': segment_list,
            'language': info.language,
            'language_probability': info.language_probability
        }
    
    def _bytes_to_array(self, audio_bytes: bytes) -> np.ndarray:
        """Convert PCM16 bytes to float32 numpy array."""
        # Convert bytes to int16
        int16_array = np.frombuffer(audio_bytes, dtype=np.int16)
        # Convert to float32 in range [-1, 1]
        return int16_array.astype(np.float32) / 32768.0
    
    def _resample(self, audio: np.ndarray, orig_sr: int, target_sr: int) -> np.ndarray:
        """Simple linear resampling."""
        if orig_sr == target_sr:
            return audio
        
        duration = len(audio) / orig_sr
        new_length = int(duration * target_sr)
        indices = np.linspace(0, len(audio) - 1, new_length)
        return np.interp(indices, np.arange(len(audio)), audio)
    
    def get_model_info(self) -> dict:
        """Get model information."""
        return {
            'model_size': self.model_size,
            'device': self.device,
            'compute_type': self.compute_type,
            'language': self.language
        }
