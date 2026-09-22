# Video Upscaler 🚀

**Push any video to its absolute quality peak** — upscale to Ultra 4K, interpolate to high frame rates, and apply real AI enhancement when you need it.

This tool **strains your device to the maximum** when running locally.  
If the job is too heavy, it tells you to rent a **virtual / cloud GPU computer** — or use a future hosted SaaS with fair compute pricing.

### Supported Platforms
| Platform | How to run |
|----------|------------|
| **Linux / Termux / a-shell** | `./cli/video_upscaler.sh` or Python |
| **Windows** | `.bat` / PowerShell / WSL |
| **Any browser** | Web App (`web/index.html`) |
| **Cloud GPU** | Same CLI (recommended for heavy AI modes) |

---

## Processing Modes

| Mode | Emoji | What it does | Billing idea |
|------|-------|--------------|--------------|
| **Fast** | ⚡ | FFmpeg + light enhancement | Free |
| **Ultra** | 🔥 | AI upscale + restoration (Real-ESRGAN …) | Free / limited credits |
| **Insane** | 💀 | Multiple AI models + high-res output | Paid (compute) |
| **Anime** | 🎨 | Anime-specific (Real-CUGAN + RIFE) | Free / paid |
| **Cinematic** | 🎬 | Full restoration + interpolation + colour/HDR | Paid (highest) |

Full design (pricing formula, free credits, live cost estimates):
**📄 [docs/MODES_AND_SAAS.md](docs/MODES_AND_SAAS.md)**

---

## AI Models

For real quality jumps beyond classic FFmpeg:

**📄 [docs/AI_MODELS.md](docs/AI_MODELS.md)**

| Model | Best for |
|-------|----------|
| **Real-ESRGAN** | General super-resolution (great starting point) |
| **Real-CUGAN** | Anime / illustration / compressed footage |
| **SwinIR** | Highest quality restoration (heavier) |
| **RIFE** | Frame interpolation (30 → 60/120 FPS) |
| **FILM** | Google Research large-motion interpolation |
| **BasicVSR++** | Video restoration with temporal consistency |
| Open-Sora / CogVideo | Generative (usually overkill) |

Includes **exact links** to official repos and where to get APIs (Replicate, Hugging Face).

---

## SaaS vision (compute-based, not button-based)

Charge by real work:

```
Cost ≈ source minutes × resolution multiplier × mode multiplier
```

Example UI estimate:
```
12 min · 1080p → 4K · Cinematic
Estimated processing: 18–35 min
Cost: ₦XXX
```

- Free credits on registration so users can try before paying
- Open-source core stays 100% free forever

Details + recommended multipliers: **[docs/MODES_AND_SAAS.md](docs/MODES_AND_SAAS.md)**

---

## Quick Start (open-source core)

```bash
git clone https://github.com/Paradoxdreamer/Video-Upscaler.git
cd Video-Upscaler
chmod +x cli/video_upscaler.sh
./cli/video_upscaler.sh input.mp4

# Absolute peak local settings
./cli/video_upscaler.sh input.mp4 --max
```

Windows: `cli\video_upscaler.bat`  
Python: `cli/video_upscaler.py`

---

## Web App
Open `web/index.html` (or host on GitHub Pages).  
Best for short clips. Heavy AI modes need a real GPU / the future SaaS.

---

## Docs

| File | Content |
|------|---------|
| [docs/AI_MODELS.md](docs/AI_MODELS.md) | Real-ESRGAN, RIFE, FILM… + API links |
| [docs/MODES_AND_SAAS.md](docs/MODES_AND_SAAS.md) | Modes, pricing model, free credits |
| [docs/CLOUD.md](docs/CLOUD.md) | How to rent a virtual GPU computer |

---

## License
MIT – free for personal and commercial use.

**Local = free forever. Cloud SaaS = pay only for the compute you use.**
