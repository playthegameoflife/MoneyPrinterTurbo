# RunPod Deployment Guide — MoneyPrinterTurbo

## What this does
Containers MPT's FastAPI server for RunPod Serverless.
- FastAPI on port 8080 (not Streamlit UI)
- InMemoryTaskManager (Redis disabled — no Redis in containers)
- Auto-scales from 0 to N concurrent workers
- Per-second billing — $0 when idle

## Files
- `Dockerfile.runpod` — the container definition
- `start-runpod.sh` — startup script (injects secrets, starts uvicorn)
- `config-runpod.toml` — config with Redis disabled

## Setup (5 steps on RunPod)

### Step 1: Push to GitHub
```bash
cd MoneyPrinterTurbo
git add Dockerfile.runpod start-runpod.sh config-runpod.toml
git commit -m "feat: add RunPod serverless container"
git push origin main
```

### Step 2: Create RunPod account
- Go to **runpod.io** → sign up
- Connect GitHub account (so it can pull your repo)

### Step 3: Create a new Serverless Endpoint
1. Dashboard → **Serverless** → **New Endpoint**
2. Configure:
   - **GitHub**: select `playthegameoflife/MoneyPrinterTurbo`
   - **Dockerfile**: `Dockerfile.runpod`
   - **Docker start command**: leave blank (Dockerfile has CMD)
   - **Port**: `8080`
   - **Hardware**: `CPU 4 vCPU, 16GB RAM` (STANDARD tier)
   - **Minimum workers**: `0` (scale to zero when idle = $0 at night)
   - **Maximum workers**: `10`
   - **Timeout**: `900 seconds` (15 min — video generation takes 2-5 min)

### Step 4: Add Secrets (Environment Variables)
In RunPod endpoint settings → **Secrets**, add:
```
MPT_API_KEY=ddc7f8092c344c4fb65ef6d07d264b9a937566f07d0d6a013bdc6d56bfe57861
GEMINI_API_KEY=your_gemini_key_here
PEXELS_API_KEYS=your_pexels_key_here
```
(Use the same keys from your current config.toml)

### Step 5: Deploy + Test
1. Click **Deploy** — RunPod builds the container (5-10 min first time)
2. Once live, you'll get a URL like: `https://xyzxyzxyz-8080.proxy.runpod.net`
3. Test it:
```bash
curl -X POST "https://xyzxyzxyz-8080.proxy.runpod.net/api/v1/videos" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_mpt_api_key" \
  -d '{"video_subject": "test video", "video_aspect": "9:16"}'
```
Should return a `task_id` immediately.

## Update your app
Point `mpt-server.ts` at RunPod instead of the VM:
```typescript
const MPT_BASE_URL = 'https://xyzxyzxyz-8080.proxy.runpod.net';
```

## Cost estimate
- Idle (0 workers): **$0**
- 1 video generating: ~4 min × $0.0002/sec (CPU) = **$0.05/video**
- 100 videos/day: ~$2-3/day = **~$60-90/mo**
- vs $6/mo VM running 24/7 but only 1 video at a time
