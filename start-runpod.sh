#!/bin/bash
# RunPod container startup script
# Replaces config.toml with runpod config (disables Redis queue)
set -e

if [ -f /MoneyPrinterTurbo/config-runpod.toml ]; then
    echo "[runpod-startup] Using config-runpod.toml"
    cp /MoneyPrinterTurbo/config-runpod.toml /MoneyPrinterTurbo/config.toml
else
    echo "[runpod-startup] config-runpod.toml not found, using existing config.toml"
fi

# Override API key if env var is set (secrets via RunPod dashboard)
if [ -n "$MPT_API_KEY" ]; then
    echo "[runpod-startup] Setting api_key from MPT_API_KEY env var"
    python3 -c "
import toml, sys
cfg = toml.load('/MoneyPrinterTurbo/config.toml')
cfg['app']['api_key'] = '$MPT_API_KEY'
with open('/MoneyPrinterTurbo/config.toml', 'w') as f:
    toml.dump(cfg, f)
print('[runpod-startup] api_key set')
"
fi

echo "[runpod-startup] Starting uvicorn on 0.0.0.0:8080..."
exec python -m uvicorn app.asgi:app --host 0.0.0.0 --port 8080 --workers 2
