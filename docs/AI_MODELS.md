# AI Models for Video Upscaling & Frame Interpolation

This page lists the best open-source AI models you can use with (or instead of) the basic FFmpeg path in **Video Upscaler**.

Most of these need a **GPU** (NVIDIA recommended). On weak devices they are extremely slow — use a cloud GPU (see [CLOUD.md](CLOUD.md)) or the hosted APIs listed below.

---

## 1. Super-Resolution / Upscaling

### Real-ESRGAN ★ Recommended starting point
**Best for:** General photos, real-world video, practical quality  
**Official repo:** https://github.com/xinntao/Real-ESRGAN  
**Paper:** Real-ESRGAN: Training Real-World Blind Super-Resolution with Pure Synthetic Data

**Easy ways to run it:**
| Method | Link | Notes |
|--------|------|-------|
| **Replicate API** | https://replicate.com/nightmareai/real-esrgan | Pay-per-use API, very easy |
| **Replicate (lucataco)** | https://replicate.com/lucataco/real-esrgan | Face enhance + scale options |
| **Hugging Face Space** | https://huggingface.co/spaces/akhaliq/Real-ESRGAN | Free demo |
| **Local (official)** | Clone the GitHub repo above | Needs PyTorch + GPU |
| **Portable (ncnn)** | https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan | No Python needed |

**Get an API key:** Create a free account on [Replicate](https://replicate.com) → Account → API tokens.

---

### Real-CUGAN ★ Great for anime / illustration / compressed footage
**Best for:** Anime, cartoons, line art, heavily compressed video  
**Official repo:** https://github.com/bilibili/ailab/tree/main/Real-CUGAN  
**NCNN portable:** https://github.com/nihui/realcugan-ncnn-vulkan

**Easy ways:**
- Windows GUI / executable packages on the official GitHub releases
- NCNN Vulkan version (runs on almost any GPU, including AMD & Apple Silicon)
- Hugging Face demo: search “Real-CUGAN” on https://huggingface.co/spaces

---

### SwinIR
**Best for:** Highest quality single-image restoration / upscaling (heavier)  
**Official repo:** https://github.com/JingyunLiang/SwinIR  
Also available inside [BasicSR](https://github.com/XPixelGroup/BasicSR)

More compute-heavy than Real-ESRGAN. Best when you care more about quality than speed.

---

### BasicVSR++
**Best for:** Video restoration where **temporal consistency** matters  
**Official repo:** https://github.com/ckkelvinchan/BasicVSR_PlusPlus  
Also in [MMagic / open-mmlab](https://github.com/open-mmlab/mmagic)

Excellent for old / compressed video that needs both upscaling and cleaning while keeping frames coherent.

---

## 2. Frame Interpolation (30 → 60 / 120 FPS)

### RIFE ★ Most practical choice
**Best for:** Fast, high-quality frame interpolation  
**Official / Practical:**  
- https://github.com/hzwer/ECCV2022-RIFE  
- https://github.com/hzwer/Practical-RIFE (more user-friendly models)

**Portable (no Python):** https://github.com/nihui/rife-ncnn-vulkan  

**APIs / demos:**
- Search “RIFE” on Replicate and Hugging Face Spaces
- Combined upscale + RIFE examples exist on Replicate (e.g. video-super-resolution-rife models)

---

### FILM (Google Research)
**Best for:** Large motion, high-quality slow-motion from near-duplicate frames  
**Official repo:** https://github.com/google-research/frame-interpolation  
**TensorFlow Hub:** https://tfhub.dev/google/film/1  
**Hugging Face / Replicate demos** are available (search “FILM frame interpolation”)

Excellent quality, especially for large movements, but heavier than RIFE.

---

## 3. Generative / Heavy models (usually overkill)

| Model | Link | When to use |
|-------|------|-------------|
| **Open-Sora** | Search GitHub / Hugging Face | Full generative video (text-to-video, image-to-video). Far beyond simple upscaling. |
| **CogVideo / CogVideoX** | Official Tsinghua / Hugging Face pages | Same category — generative, very heavy VRAM and cost. |

These are **not** recommended for normal upscaling or FPS conversion. Use Real-ESRGAN + RIFE / FILM instead.

---

## How to get API access (summary)

1. **Replicate** (easiest paid API)  
   - Sign up: https://replicate.com  
   - Get token: Account → API tokens  
   - Models: Real-ESRGAN, various RIFE-based video models, etc.

2. **Hugging Face**  
   - Free Spaces (browser demos) + paid Inference Endpoints  
   - Token: https://huggingface.co/settings/tokens  
   - Many Real-ESRGAN, RIFE, FILM Gradio Spaces can be called via the Gradio Client.

3. **Local / Self-hosted**  
   - Clone the official repos above  
   - Run on your own GPU or a rented cloud GPU (RunPod, Vast.ai, etc. — see [CLOUD.md](CLOUD.md))

---

## Recommended combinations for Video Upscaler users

| Goal | Suggested stack |
|------|-----------------|
| General video → 4K | Real-ESRGAN (x4) + optional RIFE |
| Anime / cartoon | Real-CUGAN + RIFE |
| Highest quality stills | SwinIR |
| Old / compressed video | BasicVSR++ or Real-ESRGAN + RIFE |
| Smooth high FPS | RIFE or FILM |
| Maximum quality on cloud | Real-ESRGAN + RIFE on a rented RTX 4090 / A100 |

---

**Note:** The core `video_upscaler.sh` / `.py` / web app currently uses classic FFmpeg (Lanczos + minterpolate).  
AI models above give far better results but require extra setup or API credits.  
Future versions of this project may add optional wrappers for the most popular ones (Real-ESRGAN + RIFE).
