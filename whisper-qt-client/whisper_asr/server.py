import asyncio
import base64
import json
import argparse
import signal
import sys
import os
from typing import Set
import numpy as np
import websockets
from websockets.server import WebSocketServerProtocol

# Force unbuffered output
sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', buffering=1)

from .audio_processor import AudioBuffer

try:
    from .qwen_engine import QwenASREngine
    QWEN_AVAILABLE = True
except ImportError:
    QWEN_AVAILABLE = False

try:
    from .engine import WhisperEngine
    WHISPER_AVAILABLE = True
except ImportError:
    WHISPER_AVAILABLE = False


class ASRServer:
    def __init__(
        self,
        model_type: str = "qwen",
        model_size: str = "small",
        port: int = 8765,
        host: str = "localhost",
        language: str = None,
        buffer_duration: float = 5.0
    ):
        self.port = port
        self.host = host
        self.buffer_duration = buffer_duration
        self.model_type = model_type
        self.clients: Set[WebSocketServerProtocol] = set()
        self.client_buffers: dict = {}
        self.is_running = True
        
        print(f"Initializing {model_type.upper()} ASR engine...")
        
        if model_type == "qwen" and QWEN_AVAILABLE:
            self.engine = QwenASREngine(
                # model_id="Qwen/Qwen3-ASR-1.7B",
                model_id="Qwen/Qwen3-ASR-0.6B",
                language=language
            )
        elif model_type == "whisper" and WHISPER_AVAILABLE:
            self.engine = WhisperEngine(
                model_size=model_size,
                language=language or "zh"
            )
        else:
            raise RuntimeError(f"Model type '{model_type}' not available. "
                             f"Qwen: {QWEN_AVAILABLE}, Whisper: {WHISPER_AVAILABLE}")
        
        print("Engine loaded successfully")
        
    async def register(self, websocket: WebSocketServerProtocol):
        self.clients.add(websocket)
        self.client_buffers[id(websocket)] = AudioBuffer(
            max_duration=self.buffer_duration,
            sample_rate=16000
        )
        print(f"Client connected: {websocket.remote_address}")
        
        await self.send_message(websocket, {
            "type": "connected",
            "model": self.engine.get_model_info()
        })
    
    async def unregister(self, websocket: WebSocketServerProtocol):
        self.clients.remove(websocket)
        self.client_buffers.pop(id(websocket), None)
        print(f"Client disconnected: {websocket.remote_address}")
    
    async def send_message(self, websocket: WebSocketServerProtocol, message: dict):
        if websocket in self.clients:
            try:
                await websocket.send(json.dumps(message, ensure_ascii=False))
            except websockets.exceptions.ConnectionClosed:
                await self.unregister(websocket)
    
    async def handle_audio(self, websocket: WebSocketServerProtocol, data: bytes):
        ws_id = id(websocket)
        print(f"DEBUG: websocket id={ws_id}, type={type(ws_id)}")
        print(f"DEBUG: buffers keys={list(self.client_buffers.keys())}, types={[type(k) for k in self.client_buffers.keys()]}")
        client_buffer = self.client_buffers.get(ws_id)
        if not client_buffer:
            # Try direct access
            try:
                client_buffer = self.client_buffers[ws_id]
                print(f"Direct access worked!")
            except KeyError:
                print(f"ERROR: No buffer for client, websocket id={ws_id}")
                return
        
        print(f"Received audio data: {len(data)} bytes, buffer samples: {len(client_buffer.buffer)}")
        
        int16_array = np.frombuffer(data, dtype=np.int16)
        float_array = int16_array.astype(np.float32) / 32768.0
        client_buffer.append(float_array)
        
        print(f"Buffer now has {len(client_buffer.buffer)} samples")
    
    async def handle_message(self, websocket: WebSocketServerProtocol, message: dict):
        msg_type = message.get("type")
        print(f"Received message type: {msg_type}")
        
        if msg_type == "audio":
            audio_data = message.get("data")
            if audio_data:
                try:
                    print(f"Decoding audio data, length: {len(audio_data)}")
                    audio_bytes = base64.b64decode(audio_data)
                    print(f"Audio decoded, bytes: {len(audio_bytes)}")
                    await self.handle_audio(websocket, audio_bytes)
                except Exception as e:
                    print(f"Error processing audio: {e}")
                    import traceback
                    traceback.print_exc()
                    
        elif msg_type == "transcribe":
            client_buffer = self.client_buffers.get(id(websocket))
            if client_buffer:
                audio = client_buffer.get_last(self.buffer_duration)
                print(f"Transcribe request: {len(audio)} samples in buffer")
                if len(audio) > 1600:
                    try:
                        print("Starting transcription...")
                        result = self.engine.transcribe_array(audio)
                        print(f"Transcription result: {result['text']}")
                        await self.send_message(websocket, {
                            "type": "transcript",
                            "text": result["text"],
                            "language": result["language"],
                            "segments": result.get("segments", [])
                        })
                    except Exception as e:
                        print(f"Transcription error: {e}")
                        import traceback
                        traceback.print_exc()
                        await self.send_message(websocket, {
                            "type": "error",
                            "message": str(e)
                        })
                        
        elif msg_type == "clear":
            client_buffer = self.client_buffers.get(id(websocket))
            if client_buffer:
                client_buffer.clear()
            await self.send_message(websocket, {"type": "cleared"})
    
    async def handler(self, websocket: WebSocketServerProtocol):
        await self.register(websocket)
        try:
            async for raw_message in websocket:
                try:
                    if isinstance(raw_message, str):
                        message = json.loads(raw_message)
                        await self.handle_message(websocket, message)
                    elif isinstance(raw_message, bytes):
                        await self.handle_audio(websocket, raw_message)
                except json.JSONDecodeError:
                    print(f"Invalid JSON from {websocket.remote_address}")
                except Exception as e:
                    print(f"Error handling message: {e}")
                    await self.send_message(websocket, {
                        "type": "error",
                        "message": str(e)
                    })
        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            await self.unregister(websocket)
    
    async def start(self):
        print(f"Starting ASR server on {self.host}:{self.port}")
        async with websockets.serve(self.handler, self.host, self.port):
            await asyncio.Future()
    
    def run(self):
        asyncio.run(self.start())


def main():
    parser = argparse.ArgumentParser(description="ASR WebSocket Server")
    parser.add_argument("--model", "-m", default="qwen",
                        choices=["qwen", "whisper"],
                        help="ASR model type")
    parser.add_argument("--size", "-s", default="small",
                        choices=["tiny", "base", "small", "medium", "large"],
                        help="Whisper model size (for whisper mode)")
    parser.add_argument("--port", "-p", type=int, default=8765,
                        help="Server port")
    parser.add_argument("--host", default="localhost",
                        help="Server host")
    parser.add_argument("--language", "-l", default=None,
                        help="Target language code (None for auto)")
    parser.add_argument("--buffer", "-b", type=float, default=5.0,
                        help="Audio buffer duration in seconds")
    
    args = parser.parse_args()
    
    server = ASRServer(
        model_type=args.model,
        model_size=args.size,
        port=args.port,
        host=args.host,
        language=args.language,
        buffer_duration=args.buffer
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
