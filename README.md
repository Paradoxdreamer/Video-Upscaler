# Video Upscaler 🚀

**Push any video to its absolute quality peak** — upscale to Ultra 4K (3840×2160), interpolate to high frame rates (60 / 120 / 240 fps where hardware allows), and use the most aggressive FFmpeg quality settings possible.

This tool **strains your device to the maximum** (all CPU cores, highest quality presets, Lanczos scaling, motion interpolation).  
If the job is too heavy for the current device, it clearly tells you to rent a **virtual / cloud GPU computer**.

### Supported Platforms
| Platform          | How to run                          |
|-------------------|-------------------------------------|
| **Linux**         | `./video_upscaler.sh` or Python     |
| **Termux** (Android) | Same bash + Termux FFmpeg        |
| **a-shell** (iOS) | Bash script (limited by device)     |
| **Windows**       | `.bat` / PowerShell / WSL / Git Bash |
| **Any browser**   | Web App (ffmpeg.wasm – limited size)|
| **Cloud / VPS**   | Same CLI (recommended for 4K@120+)  |

---

## ⚠️ Reality Check
- **True 4K @ 240 fps** is extremely demanding. Most phones, tablets and even mid-range PCs will struggle or take hours.
- FFmpeg’s `minterpolate` can target 240 fps, but quality and speed depend heavily on your CPU/GPU.
- Browser (Web App) version is limited by RAM (~100-200 MB videos recommended). For long or 4K source videos → use CLI on a powerful machine or cloud.

**Recommended for heavy jobs:**
- [RunPod](https://runpod.io)
- [Vast.ai](https://vast.ai)
- [Lambda Labs](https://lambdalabs.com)
- [Paperspace](https://www.paperspace.com)
- Any NVIDIA GPU cloud instance (RTX 3090 / 4090 / A100 etc.)

---

## AI Models (much better quality)

The built-in FFmpeg path is fast and works everywhere, but for **real AI upscaling and interpolation** see:

**📄 [docs/AI_MODELS.md](docs/AI_MODELS.md)** — full guide with links for:

| Model | Best for |
|-------|----------|
| **Real-ESRGAN** | General super-resolution (recommended start) |
| **Real-CUGAN** | Anime / illustration / compressed footage |
| **SwinIR** | Highest quality image restoration (heavier) |
| **RIFE** | Frame interpolation (30	o60/120 FPS) |
| **FILM** | Google Research large-motion interpolation |
| **BasicVSR++** | Video restoration with temporal consistency |

The guide also tells you **exactly where to get APIs** (Replicate, Hugging Face) and how to run the models locally or on a cloud GPU.

---

## Quick Start

### 1. Install FFmpeg
```bash
# Linux / Termux
pkg install ffmpeg          # Termux
sudo apt install ffmpeg     # Ubuntu/Debian
# Windows: download from https://ffmpeg.org or use winget/choco
# a-shell: usually has ffmpeg or install via pkg
```

### 2. Clone & Run
```bash
git clone https://github.com/Paradoxdreamer/Video-Upscaler.git
cd Video-Upscaler
chmod +x cli/video_upscaler.sh
./cli/video_upscaler.sh input.mp4
```

### Common options
```bash
./cli/video_upscaler.sh input.mp4 --fps 120 --crf 14 --preset veryslow
./cli/video_upscaler.sh input.mp4 --4k --fps 60 --out upscaled_output.mp4
./cli/video_upscaler.sh input.mp4 --max   # absolute peak (very slow)
```

---

## Web App
Open `web/index.html` in any modern browser (or host it on GitHub Pages).

- Drag & drop video
- Choose target FPS & quality
- Process in-browser (privacy-friendly, no upload)
- Large files → tool will warn and recommend cloud

Live demo (after you enable GitHub Pages):  
`https://paradoxdreamer.github.io/Video-Upscaler/`

---

## Project Structure
```
Video-Upscaler/
├── cli/
│   ├── video_upscaler.sh      # Main cross-platform bash tool
│   ├── video_upscaler.bat     # Windows helper
│   └── video_upscaler.py      # Python version (better detection)
├── web/
│   ├── index.html
│   ├── app.js
│   └── style.css
├── scripts/
│   └── install.sh
├── docs/
│   ├── CLOUD.md               # How to rent a virtual computer
│   └── AI_MODELS.md           # Real-ESRGAN, RIFE, FILM, etc. + API links
└── README.md
```

---

## License
MIT – free for personal and commercial use.

---

**Made for users who want the absolute maximum quality the hardware can deliver.**  
If your device can’t handle it → rent a virtual supercomputer. That’s the honest path to Ultra 4K @ 240 fps.
