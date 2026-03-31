# Whisper Qt Client

Real-time speech recognition client using Qwen3-ASR / Whisper and Qt.

## Requirements

### Python Dependencies
```bash
pip install -r requirements.txt
```

### Qt Requirements
- Qt 6.x
- CMake 3.16+
- C++17 compiler

## Quick Start

### 1. Start ASR Server (Default: Qwen3-ASR)
```bash
cd whisper-qt-client
source venv/bin/activate
python -m whisper_asr.server --model qwen --port 8765
```

### 2. Build Qt Client
```bash
cd client
mkdir build && cd build
cmake ..
make
```

### 3. Run
```bash
./whisper_client  # or whisper_client.exe on Windows
```

## Model Support

| Model | Type | Languages | Memory |
|-------|------|----------|--------|
| Qwen/Qwen3-ASR-1.7B | Qwen | 52+ languages | ~6GB |
| Whisper small | Faster-Whisper | Multilingual | ~2GB |

## Usage

### Qwen3-ASR (Default)
```bash
python -m whisper_asr.server --model qwen --port 8765
```

### Whisper
```bash
python -m whisper_asr.server --model whisper --size small --port 8765
```

## Architecture

```
┌──────────────┐     WebSocket      ┌──────────────┐
│  Qt Client   │ ◄───────────────► │ ASR Server   │
│              │                    │              │
│  - UI        │                    │ Qwen3-ASR    │
│  - Audio In  │                    │    or        │
└──────────────┘                    │ Faster-Whisper│
                                    └──────────────┘
```

## API

### WebSocket Endpoint
`ws://localhost:8765`

### Message Format (Client → Server)
```json
{
  "type": "audio",
  "data": "<base64 encoded PCM16 audio>"
}
```

### Message Format (Server → Client)
```json
{
  "type": "transcript",
  "text": "识别结果文本",
  "language": "zh",
  "segments": []
}
```

## License

MIT
