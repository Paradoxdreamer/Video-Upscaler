# Processing Modes & SaaS Vision

**Video Upscaler** has two layers:

1. **Open-source core** (this GitHub repo) — completely free, runs on your device or any cloud GPU you rent.
2. **Optional hosted SaaS** (future / separate service) — AI-powered modes with fair compute-based billing.

This document defines the modes, what they use, and how a paid cloud version should work.

---

## Processing Modes

| Mode | Emoji | What it does | Typical models / tools | Best for |
|------|-------|--------------|------------------------|----------|
| **Fast** | ⚡ | Minimal processing, maximum speed | FFmpeg Lanczos + light filters | Quick previews, weak devices |
| **Ultra** | 🔥 | Solid AI upscale + basic restoration | Real-ESRGAN (+ optional light RIFE) | Everyday high-quality upscaling |
| **Insane** | 💀 | Maximum quality, multiple models stacked | Real-ESRGAN / SwinIR + RIFE or FILM + BasicVSR++ style restoration | Final masters, highest fidelity |
| **Anime** | 🎨 | Anime / illustration optimised | Real-CUGAN + RIFE (anime-tuned) | Anime, cartoons, line art |
| **Cinematic** | 🎬 | Full restoration + upscale + interpolation + colour/HDR touch | Real-ESRGAN or BasicVSR++ + RIFE/FILM + colour grading / tone mapping | Films, old footage, cinematic look |

### Recommended mapping (open-source core)

| Mode | Current open-source path |
|------|--------------------------|
| Fast | `./cli/video_upscaler.sh` (default FFmpeg) |
| Ultra | Real-ESRGAN (see [AI_MODELS.md](AI_MODELS.md)) + optional RIFE |
| Insane | Real-ESRGAN / SwinIR + RIFE or FILM + stronger settings |
| Anime | Real-CUGAN + RIFE |
| Cinematic | Real-ESRGAN or BasicVSR++ + RIFE/FILM + colour pipeline |

Full model links and API sources: **[AI_MODELS.md](AI_MODELS.md)**

---

## SaaS Billing Design (fair compute pricing)

**Do not charge just for pressing a button.**  
Charge based on real compute cost:

```
Cost = (source minutes) × (resolution multiplier) × (mode multiplier) × base rate
```

### Example base rate (adjust to your costs)
- Base rate: **₦50 – ₦150 per source minute** at 1080p × Fast (example only)

### Resolution multipliers (example)
| Source / Target | Multiplier |
|-----------------|------------|
| 720p → 1080p | 0.7× |
| 1080p → 1080p | 1.0× |
| 1080p → 4K | 2.2× |
| 4K → 4K | 3.0× |
| 4K → 8K | 5.0×+ |

### Mode multipliers (example)
| Mode | Multiplier | Notes |
|------|------------|-------|
| ⚡ Fast | 1.0× | FFmpeg only |
| 🔥 Ultra | 3–5× | One strong AI model |
| 💀 Insane | 8–15× | Multiple models + high quality |
| 🎨 Anime | 3–6× | Real-CUGAN path |
| 🎬 Cinematic | 10–20× | Full pipeline + colour |

### Live estimate example (what the UI should show)

```
12 min · 1080p → 4K · Cinematic
Estimated processing: 18–35 min
Estimated cost: ₦2,400 – ₦4,800
```

The backend calculates this **before** the user confirms payment.

---

## Free credits on registration

Give every new user free credits so they can **see the difference** before paying:

| Action | Credits (example) |
|--------|-------------------|
| Sign up | ₦1,000 – ₦2,000 free |
| First video processed | Bonus small credit |
| Referral | Extra credits |

This lets users try Fast + one Ultra job and feel the quality jump.

---

## Billing / Mode summary table

| Mode | Processing | Billing |
|------|------------|---------|
| ⚡ Fast | FFmpeg + light enhancement | Free (open-source) / very cheap on SaaS |
| 🔥 Ultra | AI upscale + restoration | Free/limited credits or low paid |
| 💀 Insane | Multiple AI models + high-res output | Paid (compute-based) |
| 🎨 Anime | Anime-specific models | Free/limited or paid |
| 🎬 Cinematic | Full restoration + interpolation + colour/HDR | Paid (highest compute) |

---

## Implementation notes for a future SaaS

1. **Frontend** — Mode selector + live cost/time estimator before upload or after probe.
2. **Backend** — Queue jobs on GPU workers (RunPod, Vast.ai, Lambda, or your own).
3. **Payment** — Paystack / Flutterwave (Nigeria) or Stripe. Charge only after successful estimate confirmation.
4. **Credits** — Store balance per user; deduct after job completes (or reserve on start).
5. **Open-source core stays free** — This GitHub repo remains fully usable without any account or payment.

---

## Where to get the AI APIs / models

See the detailed guide:

**→ [AI_MODELS.md](AI_MODELS.md)**

Key starting points:
- Real-ESRGAN → https://github.com/xinntao/Real-ESRGAN + Replicate API
- Real-CUGAN → https://github.com/bilibili/ailab/tree/main/Real-CUGAN
- RIFE → https://github.com/hzwer/Practical-RIFE
- FILM → https://github.com/google-research/frame-interpolation
- SwinIR / BasicVSR++ → linked in AI_MODELS.md

Replicate and Hugging Face are the easiest places to get ready-made APIs for the SaaS backend.
