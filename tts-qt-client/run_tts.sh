#!/bin/bash
pkill -f "tts_server" 2>/dev/null
pkill -f "tts_client" 2>/dev/null
sleep 2

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
CLIENT_PATH="$SCRIPT_DIR/client/build/tts_client"

REF_AUDIO="${1:-/Users/wenhongquan/Downloads/zh.wav}"

echo "=========================================="
echo "  TTS Server & Client Launcher"
echo "=========================================="
echo ""
echo "Project: $PROJECT_DIR"
echo "Reference Audio: $REF_AUDIO"
echo ""

echo "[1/4] Cleaning up existing processes..."
pkill -f "tts_server.server" 2>/dev/null
pkill -f "tts_client" 2>/dev/null
sleep 1

echo "[2/4] Starting TTS server..."
cd "$PROJECT_DIR"
export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
nohup /opt/homebrew/bin/python3.10 -m tts_server.server --ref-audio "$REF_AUDIO" > /tmp/tts_server.log 2>&1 &
SERVER_PID=$!
echo "Server PID: $SERVER_PID"

echo "[3/4] Waiting for server to initialize..."
for i in {1..30}; do
    if grep -q "TTS Engine ready" /tmp/tts_server.log 2>/dev/null; then
        echo "Server ready!"
        break
    fi
    sleep 1
    echo -n "."
done
echo ""

echo "[4/4] Starting TTS client..."
"$CLIENT_PATH" &
CLIENT_PID=$!
echo "Client PID: $CLIENT_PID"

echo ""
echo "=========================================="
echo "  Started Successfully!"
echo "=========================================="
echo ""
echo "Server log: tail -f /tmp/tts_server.log"
echo "Stop server: kill $SERVER_PID"
echo "Stop client: kill $CLIENT_PID"
echo ""

tail -f /tmp/tts_server.log
