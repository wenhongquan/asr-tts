#!/usr/bin/env python3
import asyncio
import base64
import json
import argparse
import signal
import sys
import os
import io
import wave
import hashlib
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache
from typing import Set, Optional, Tuple, List, Dict
import numpy as np
import websockets
from websockets.server import WebSocketServerProtocol

sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', buffering=1)


class AudioCache:
    def __init__(self, max_size: int = 200):
        self.cache: Dict[str, bytes] = {}
        self.access_order: List[str] = []
        self.max_size = max_size
        self.hits = 0
        self.misses = 0
    
    def _make_key(self, text: str, ref_hash: str) -> str:
        return hashlib.md5(f"{ref_hash}:{text}".encode()).hexdigest()
    
    def get(self, text: str, ref_hash: str) -> Optional[bytes]:
        key = self._make_key(text, ref_hash)
        if key in self.cache:
            self.access_order.remove(key)
            self.access_order.append(key)
            self.hits += 1
            return self.cache[key]
        self.misses += 1
        return None
    
    def put(self, text: str, ref_hash: str, audio_data: bytes):
        key = self._make_key(text, ref_hash)
        if key in self.cache:
            self.access_order.remove(key)
        elif len(self.cache) >= self.max_size:
            oldest = self.access_order.pop(0)
            del self.cache[oldest]
        self.cache[key] = audio_data
        self.access_order.append(key)
    
    def get_stats(self) -> dict:
        total = self.hits + self.misses
        hit_rate = (self.hits / total * 100) if total > 0 else 0
        return {
            'size': len(self.cache),
            'max_size': self.max_size,
            'hits': self.hits,
            'misses': self.misses,
            'hit_rate': f"{hit_rate:.1f}%"
        }


class TTSEngine:
    def __init__(self, model_id: str = "Qwen/Qwen3-TTS-12Hz-0.6B-Base", 
                 ref_audio_path: str = None):
        import soundfile as sf
        
        self.model_id = model_id
        self.sample_rate = 24000
        self.ref_audio_path = ref_audio_path
        self.ref_hash = None
        self.audio_cache = AudioCache(max_size=200)
        
        print(f"Loading Qwen3-TTS model: {model_id}")
        from qwen_tts import Qwen3TTSModel
        self.model = Qwen3TTSModel.from_pretrained(model_id, device_map='mps')
        print("Model loaded successfully")
        
        if self.ref_audio_path and os.path.exists(self.ref_audio_path):
            self.ref_audio, self.ref_sr = self._load_audio(self.ref_audio_path)
            self.ref_hash = hashlib.md5(open(self.ref_audio_path, 'rb').read()).hexdigest()
            self.prompt_items = self.model.create_voice_clone_prompt(
                ref_audio=(self.ref_audio, self.ref_sr),
                ref_text="",
                x_vector_only_mode=True
            )
            print(f"Reference audio loaded: {self.ref_audio_path}")
        else:
            self.ref_audio = None
            self.ref_sr = None
            self.prompt_items = None
            print("Warning: No reference audio provided")
    
    def _load_audio(self, path: str) -> Tuple[np.ndarray, int]:
        import soundfile as sf
        audio, sr = sf.read(path)
        if len(audio.shape) > 1:
            audio = audio[:, 0]
        return audio, sr
    
    def synthesize(self, text: str, ref_audio_path: str = None) -> bytes:
        if ref_audio_path:
            ref_audio, ref_sr = self._load_audio(ref_audio_path)
            ref_hash = hashlib.md5(open(ref_audio_path, 'rb').read()).hexdigest()
            prompt = self.model.create_voice_clone_prompt(
                ref_audio=(ref_audio, ref_sr),
                ref_text="",
                x_vector_only_mode=True
            )
        elif self.ref_hash:
            ref_hash = self.ref_hash
            prompt = self.prompt_items
        else:
            raise ValueError("Reference audio required for Base model")
        
        cached = self.audio_cache.get(text, ref_hash)
        if cached:
            return cached
        
        audio_chunks, sample_rate = self.model.generate_voice_clone(
            text=text,
            voice_clone_prompt=prompt,
            x_vector_only_mode=True,
        )
        
        wav_data = self._audio_to_wav(audio_chunks, sample_rate)
        self.audio_cache.put(text, ref_hash, wav_data)
        return wav_data
    
    def _audio_to_wav(self, audio_data, sample_rate: int = None) -> bytes:
        if sample_rate is None:
            sample_rate = self.sample_rate
        
        if isinstance(audio_data, list):
            audio_array = np.concatenate(audio_data) if len(audio_data) > 0 else np.array([])
        else:
            audio_array = audio_data
        
        if audio_array.dtype != np.int16:
            audio_array = (audio_array * 32767).astype(np.int16)
        
        wav_io = io.BytesIO()
        with wave.open(wav_io, 'wb') as wav_file:
            wav_file.setnchannels(1)
            wav_file.setsampwidth(2)
            wav_file.setframerate(sample_rate)
            wav_file.writeframes(audio_array.tobytes())
        
        return wav_io.getvalue()
    
    def get_model_info(self) -> dict:
        info = {
            'model_id': self.model_id,
            'sample_rate': self.sample_rate,
            'has_ref_audio': self.ref_audio is not None,
            'cache_stats': self.audio_cache.get_stats()
        }
        return info


class TTSServer:
    def __init__(
        self,
        model_id: str = "Qwen/Qwen3-TTS-12Hz-0.6B-Base",
        port: int = 8766,
        host: str = "localhost",
        ref_audio_path: str = None,
        max_workers: int = 4
    ):
        self.port = port
        self.host = host
        self.ref_audio_path = ref_audio_path
        self.clients: Set[WebSocketServerProtocol] = set()
        self.is_running = True
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
        
        print(f"Initializing TTS engine...")
        self.engine = TTSEngine(model_id, ref_audio_path)
        print(f"TTS Engine ready (max_workers={max_workers})")
    
    async def register(self, websocket: WebSocketServerProtocol):
        self.clients.add(websocket)
        print(f"Client connected: {websocket.remote_address}")
        
        await self.send_message(websocket, {
            "type": "connected",
            "model": self.engine.get_model_info()
        })
    
    async def unregister(self, websocket: WebSocketServerProtocol):
        self.clients.discard(websocket)
        print(f"Client disconnected: {websocket.remote_address}")
    
    async def send_message(self, websocket: WebSocketServerProtocol, message: dict):
        if websocket in self.clients:
            try:
                await websocket.send(json.dumps(message, ensure_ascii=False))
            except websockets.exceptions.ConnectionClosed:
                await self.unregister(websocket)
    
    async def handle_synthesize(self, websocket: WebSocketServerProtocol, 
                               text: str, ref_audio: str = None, chunk_index: int = -1):
        loop = asyncio.get_event_loop()
        try:
            print(f"Starting synthesis for chunk {chunk_index}: {text[:30]}...")
            
            audio_data = await loop.run_in_executor(
                self.executor,
                self.engine.synthesize,
                text,
                ref_audio
            )
            
            audio_base64 = base64.b64encode(audio_data).decode('utf-8')
            await self.send_message(websocket, {
                "type": "audio",
                "data": audio_base64,
                "format": "wav",
                "sample_rate": self.engine.sample_rate,
                "chunk_index": chunk_index,
                "is_first": True,
                "is_last": True
            })
            print(f"Sent audio for chunk {chunk_index} ({len(audio_data)} bytes)")
            
        except Exception as e:
            print(f"Synthesis error for chunk {chunk_index}: {e}")
            await self.send_message(websocket, {
                "type": "error",
                "message": str(e),
                "chunk_index": chunk_index
            })
    
    async def handle_message(self, websocket: WebSocketServerProtocol, message: dict):
        msg_type = message.get("type")
        
        if msg_type == "synthesize":
            text = message.get("text", "")
            ref_audio = message.get("ref_audio")
            chunk_index = message.get("chunk_index", -1)
            
            if not text:
                await self.send_message(websocket, {
                    "type": "error",
                    "message": "No text provided"
                })
                return
            
            asyncio.create_task(self.handle_synthesize(websocket, text, ref_audio, chunk_index))
        
        elif msg_type == "voices":
            await self.send_message(websocket, {
                "type": "voices",
                "voices": ["default"]
            })
        
        elif msg_type == "cache_stats":
            stats = self.engine.audio_cache.get_stats()
            await self.send_message(websocket, {
                "type": "cache_stats",
                **stats
            })
    
    async def handler(self, websocket: WebSocketServerProtocol):
        await self.register(websocket)
        try:
            async for raw_message in websocket:
                try:
                    if isinstance(raw_message, str):
                        message = json.loads(raw_message)
                        await self.handle_message(websocket, message)
                except json.JSONDecodeError:
                    print(f"Invalid JSON from {websocket.remote_address}")
                except Exception as e:
                    print(f"Error handling message: {e}")
        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            await self.unregister(websocket)
    
    async def start(self):
        print(f"Starting TTS server on {self.host}:{self.port}")
        async with websockets.serve(self.handler, self.host, self.port):
            await asyncio.Future()
    
    def run(self):
        asyncio.run(self.start())


def main():
    parser = argparse.ArgumentParser(description="TTS WebSocket Server (Optimized with Cache)")
    parser.add_argument("--model", "-m", default="Qwen/Qwen3-TTS-12Hz-0.6B-Base")
    parser.add_argument("--port", "-p", type=int, default=8766)
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--ref-audio", "-r", default=None)
    parser.add_argument("--workers", "-w", type=int, default=4)
    
    args = parser.parse_args()
    
    server = TTSServer(
        model_id=args.model,
        port=args.port,
        host=args.host,
        ref_audio_path=args.ref_audio,
        max_workers=args.workers
    )
    
    def signal_handler(sig, frame):
        print("\nShutting down server...")
        server.is_running = False
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    server.run()


if __name__ == "__main__":
    main()
