"""
Audio Processor - Handle audio capture and buffering
"""
import numpy as np
import queue
import threading
from typing import Optional, Callable
from dataclasses import dataclass


@dataclass
class AudioChunk:
    """Represents a chunk of audio data."""
    data: np.ndarray
    sample_rate: int
    timestamp: float
    
    
class AudioBuffer:
    """
    Rolling buffer for streaming audio.
    """
    
    def __init__(self, max_duration: float = 30.0, sample_rate: int = 16000):
        """
        Initialize audio buffer.
        
        Args:
            max_duration: Maximum buffer duration in seconds
            sample_rate: Audio sample rate
        """
        self.sample_rate = sample_rate
        self.max_samples = int(max_duration * sample_rate)
        self.buffer = np.zeros(0, dtype=np.float32)
        self.lock = threading.Lock()
    
    def append(self, data: np.ndarray):
        """Append audio data to buffer."""
        with self.lock:
            self.buffer = np.concatenate([self.buffer, data])
            
            # Trim if exceeds max duration
            if len(self.buffer) > self.max_samples:
                self.buffer = self.buffer[-self.max_samples:]
    
    def get_all(self) -> np.ndarray:
        """Get all buffered audio."""
        with self.lock:
            return self.buffer.copy()
    
    def get_last(self, duration: float) -> np.ndarray:
        """Get last N seconds of audio."""
        with self.lock:
            num_samples = int(duration * self.sample_rate)
            return self.buffer[-num_samples:].copy()
    
    def clear(self):
        """Clear the buffer."""
        with self.lock:
            self.buffer = np.zeros(0, dtype=np.float32)
    
    def __len__(self):
        with self.lock:
            return len(self.buffer)


class VADProcessor:
    """
    Voice Activity Detection using simple energy-based detection.
    """
    
    def __init__(
        self,
        threshold: float = 0.02,
        min_speech_duration: float = 0.3,
        min_silence_duration: float = 0.5,
        sample_rate: int = 16000
    ):
        """
        Initialize VAD processor.
        
        Args:
            threshold: Energy threshold for speech detection
            min_speech_duration: Minimum speech duration in seconds
            min_silence_duration: Minimum silence to end speech
            sample_rate: Audio sample rate
        """
        self.threshold = threshold
        self.min_speech_samples = int(min_speech_duration * sample_rate)
        self.min_silence_samples = int(min_silence_duration * sample_rate)
        self.sample_rate = sample_rate
        
        self.speech_buffer = []
        self.silence_counter = 0
        self.in_speech = False
    
    def process(self, audio: np.ndarray) -> list:
        """
        Process audio and return speech segments.
        
        Returns:
            List of (start_sample, end_sample) tuples
        """
        segments = []
        frame_size = 1024
        
        for i in range(0, len(audio), frame_size):
            frame = audio[i:i + frame_size]
            energy = np.sqrt(np.mean(frame ** 2))
            
            if energy > self.threshold:
                # Speech detected
                self.speech_buffer.append(frame)
                self.silence_counter = 0
                self.in_speech = True
            else:
                # Silence
                if self.in_speech:
                    self.silence_counter += len(frame)
                    
                    if self.silence_counter >= self.min_silence_samples:
                        # End of speech segment
                        speech_audio = np.concatenate(self.speech_buffer)
                        if len(speech_audio) >= self.min_speech_samples:
                            start_sample = i - len(speech_audio) - self.silence_counter + frame_size
                            end_sample = i
                            segments.append((start_sample, end_sample))
                        
                        self.speech_buffer = []
                        self.silence_counter = 0
                        self.in_speech = False
        
        return segments
    
    def reset(self):
        """Reset VAD state."""
        self.speech_buffer = []
        self.silence_counter = 0
        self.in_speech = False


class AudioProcessor:
    """
    Complete audio processor for streaming ASR.
    """
    
    def __init__(
        self,
        sample_rate: int = 16000,
        chunk_duration: float = 1.0,
        buffer_duration: float = 30.0,
        enable_vad: bool = True
    ):
        """
        Initialize audio processor.
        
        Args:
            sample_rate: Audio sample rate
            chunk_duration: Duration of each processing chunk
            buffer_duration: Maximum buffer duration
            enable_vad: Enable voice activity detection
        """
        self.sample_rate = sample_rate
        self.chunk_duration = chunk_duration
        self.chunk_samples = int(chunk_duration * sample_rate)
        
        self.buffer = AudioBuffer(buffer_duration, sample_rate)
        self.vad = VADProcessor() if enable_vad else None
        
        self.audio_queue = queue.Queue()
        self.is_running = False
    
    def process_chunk(self, audio_data: bytes):
        """
        Process incoming audio chunk.
        
        Args:
            audio_data: Raw PCM16 audio bytes
        """
        # Convert to numpy array
        int16_array = np.frombuffer(audio_data, dtype=np.int16)
        float_array = int16_array.astype(np.float32) / 32768.0
        
        # Add to buffer
        self.buffer.append(float_array)
        
        # Put in queue for ASR processing
        self.audio_queue.put(float_array.copy())
    
    def get_chunk(self, timeout: float = 1.0) -> Optional[np.ndarray]:
        """
        Get next audio chunk from queue.
        
        Args:
            timeout: Timeout in seconds
            
        Returns:
            Audio chunk as numpy array or None
        """
        try:
            return self.audio_queue.get(timeout=timeout)
        except queue.Empty:
            return None
    
    def get_buffer_audio(self, duration: float = None) -> np.ndarray:
        """
        Get buffered audio.
        
        Args:
            duration: Duration in seconds (None for all)
            
        Returns:
            Buffered audio as numpy array
        """
        if duration is None:
            return self.buffer.get_all()
        return self.buffer.get_last(duration)
    
    def clear(self):
        """Clear buffer and queue."""
        self.buffer.clear()
        while not self.audio_queue.empty():
            try:
                self.audio_queue.get_nowait()
            except queue.Empty:
                break
    
    def bytes_to_array(self, audio_bytes: bytes) -> np.ndarray:
        """Convert PCM16 bytes to float32 array."""
        int16_array = np.frombuffer(audio_bytes, dtype=np.int16)
        return int16_array.astype(np.float32) / 32768.0
