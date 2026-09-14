#!/bin/bash
# RunPod container startup script
# Copies config-runpod.toml to config.toml, then injects secrets from env vars
set -e

echo "[runpod-startup] Copying config-runpod.toml → config.toml"
cp /MoneyPrinterTurbo/config-runpod.toml /MoneyPrinterTurbo/config.toml

# Inject all required API keys from environment variables
# These are set as Secrets in the RunPod dashboard
echo "[runpod-startup] Injecting API keys from environment variables..."

python3 -c "
import toml, os

cfg = toml.load('/MoneyPrinterTurbo/config.toml')
app = cfg['app']

if os.environ.get('MPT_API_KEY'):
    app['api_key'] = os.environ['MPT_API_KEY']
    print('[runpod-startup] ✓ api_key set')

if os.environ.get('GEMINI_API_KEY'):
    app['gemini_api_key'] = os.environ['GEMINI_API_KEY']
    print('[runpod-startup] ✓ gemini_api_key set')

if os.environ.get('PEXELS_API_KEY'):
    app['pexels_api_keys'] = [os.environ['PEXELS_API_KEY']]
    print('[runpod-startup] ✓ pexels_api_keys set')

if os.environ.get('OPENAI_API_KEY'):
    app['openai_api_key'] = os.environ['OPENAI_API_KEY']
    print('[runpod-startup] ✓ openai_api_key set')

if os.environ.get('LLM_PROVIDER'):
    app['llm_provider'] = os.environ['LLM_PROVIDER']
    print(f'[runpod-startup] ✓ llm_provider set to {app[\"llm_provider\"]}')

with open('/MoneyPrinterTurbo/config.toml', 'w') as f:
    toml.dump(cfg, f)

print('[runpod-startup] Config written, starting uvicorn...')
"

exec python -m uvicorn app.asgi:app --host 0.0.0.0 --port 8080 --workers 2
