#!/usr/bin/env python3
"""
Video Upscaler - Python cross-platform version
Works on Linux, Windows, macOS, Termux (with python + ffmpeg)
"""

import argparse
import os
import shutil
import subprocess
import sys
import multiprocessing
from pathlib import Path

VERSION = "1.0.0"

def print_banner():
    print("╔══════════════════════════════════════════════════════╗")
    print(f"║           Video Upscaler v{VERSION} (Python)                ║")
    print("║   Absolute peak quality • Max device strain          ║")
    print("╚══════════════════════════════════════════════════════╝")
    print()

def warn_cloud():
    print()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  ⚠️  THIS JOB IS EXTREMELY HEAVY FOR MOST DEVICES           ║")
    print("║                                                            ║")
    print("║  Recommended: Rent a virtual / cloud GPU computer          ║")
    print("║                                                            ║")
    print("║  • RunPod     https://runpod.io                            ║")
    print("║  • Vast.ai    https://vast.ai                              ║")
    print("║  • Lambda     https://lambdalabs.com                       ║")
    print("║  • Paperspace https://www.paperspace.com                   ║")
    print("║                                                            ║")
    print("║  Look for RTX 3090 / 4090 / A100 instances.                ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

def check_ffmpeg():
    if not shutil.which("ffmpeg"):
        print("ERROR: ffmpeg not found in PATH.")
        print("Install instructions:")
        print("  Termux:   pkg install ffmpeg")
        print("  Ubuntu:   sudo apt install ffmpeg")
        print("  Windows:  winget install ffmpeg")
        print("  macOS:    brew install ffmpeg")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Push video to absolute peak quality (4K + high FPS)"
    )
    parser.add_argument("input", help="Input video file")
    parser.add_argument("-o", "--out", help="Output file")
    parser.add_argument("--fps", type=int, default=60, help="Target FPS (default 60)")
    parser.add_argument("--width", type=int, default=3840)
    parser.add_argument("--height", type=int, default=2160)
    parser.add_argument("--crf", type=int, default=15)
    parser.add_argument("--preset", default="veryslow")
    parser.add_argument("--max", action="store_true", help="Absolute peak mode")
    parser.add_argument("--threads", type=int, default=multiprocessing.cpu_count())
    parser.add_argument("-f", "--force", action="store_true")
    parser.add_argument("--1080", action="store_true", dest="p1080")

    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print(f"File not found: {args.input}")
        sys.exit(1)

    print_banner()
    check_ffmpeg()

    if args.p1080:
        args.width = 1920
        args.height = 1080

    if args.max:
        args.crf = 12
        args.preset = "veryslow"
        args.fps = 120
        print("★ Absolute Peak Upscale Mode enabled")

    if not args.out:
        stem = Path(args.input).stem
        args.out = f"{stem}_Upscaled_{args.width}x{args.height}_{args.fps}fps.mp4"

    print(f"Device threads : {args.threads}")
    print(f"Target         : {args.width}x{args.height} @ {args.fps} fps")
    print(f"Quality        : CRF {args.crf} / {args.preset}")
    print(f"Output         : {args.out}")
    print()

    if not args.force and (args.fps >= 120 or args.crf <= 14 or args.preset == "veryslow"):
        warn_cloud()
        ans = input("Continue on this device? (y/N): ").strip().lower()
        if ans != "y":
            print("Aborted. Use a cloud GPU instance.")
            sys.exit(0)

    vf = f"scale={args.width}:{args.height}:flags=lanczos"
    if args.fps > 30:
        vf += f",minterpolate=fps={args.fps}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"

    encoder = "libx264"
    try:
        out = subprocess.check_output(
            ["ffmpeg", "-hide_banner", "-encoders"], stderr=subprocess.STDOUT, text=True
        )
        if "libx265" in out:
            encoder = "libx265"
    except Exception:
        pass

    cmd = [
        "ffmpeg", "-y",
        "-i", args.input,
        "-vf", vf,
        "-c:v", encoder,
        "-preset", args.preset,
        "-crf", str(args.crf),
        "-threads", str(args.threads),
        "-c:a", "aac", "-b:a", "320k",
        "-movflags", "+faststart",
        args.out,
    ]

    print("Running:", " ".join(cmd))
    print()
    try:
        subprocess.run(cmd, check=True)
        print()
        print(f"✓ Done! Saved to: {args.out}")
        print("If it was too slow, rent a virtual computer next time.")
    except subprocess.CalledProcessError as e:
        print("Encode failed with code", e.returncode)
        sys.exit(1)

if __name__ == "__main__":
    main()
