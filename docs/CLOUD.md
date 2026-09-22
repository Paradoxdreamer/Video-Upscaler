# Renting a Virtual Computer for Ultra 4K / High-FPS Work

True Ultra 4K + 120–240 fps encoding is often too heavy for phones, tablets, and even many laptops.  
The honest solution is to rent a short-lived high-end GPU machine in the cloud.

## Recommended Providers (2026)

| Provider     | Best for                  | Starting price (approx) | Notes                          |
|--------------|---------------------------|--------------------------|--------------------------------|
| **RunPod**   | Fast spin-up, community   | ~$0.20–0.60 / hr        | Easy templates, SSH ready     |
| **Vast.ai**  | Cheapest GPU marketplace  | Often lowest             | Bid on spare capacity         |
| **Lambda**   | Reliable NVIDIA fleet     | Higher                   | Clean, good support           |
| **Paperspace**| Gradient notebooks       | Medium                   | Good for experiments          |
| **AWS / GCP / Azure** | Enterprise            | Higher                   | Use spot / preemptible        |

### Recommended GPUs
- RTX 3090 / 4090 (consumer, great price/performance)
- A10 / A100 / H100 (professional, faster encode + more VRAM)

## Quick Start (RunPod example)

1. Create account at https://runpod.io
2. Deploy a **GPU Pod** (choose RTX 4090 or similar)
3. Select a template that already has FFmpeg (or Ubuntu + install)
4. Connect via SSH or web terminal
5. Upload your video (`scp` or `wget`/`curl`)
6. Clone this repo and run:
   ```bash
   git clone https://github.com/Paradoxdreamer/Video-Upscaler.git
   cd Video-Upscaler
   chmod +x cli/video_upscaler.sh
   ./cli/video_upscaler.sh yourvideo.mp4 --max
   ```
7. Download the result and terminate the pod to stop billing.

## Termux / Mobile users
You can still run the CLI on your phone, but for anything longer than a few seconds of 4K source, expect multi-hour runs and high heat/battery drain. Cloud is strongly recommended.

## Cost tip
Most of these jobs finish in 10–60 minutes on a strong GPU.  
A $0.40/hr machine for 30 minutes costs about **$0.20**.  
That is usually cheaper (and far less painful) than waiting hours on a phone.
