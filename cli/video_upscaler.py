#!/usr/bin/env python3
"""Video Upscaler - Python. Security: ranges, preset whitelist, shell=False, path checks."""
import argparse, os, re, shutil, subprocess, sys, multiprocessing
from pathlib import Path
VERSION = "1.1.0"
ALLOWED_PRESETS = frozenset({"ultrafast","superfast","veryfast","faster","fast","medium","slow","slower","veryslow","placebo"})
SENSITIVE_PREFIXES = ("/etc/","/usr/","/bin/","/sbin/","/boot/","/dev/","/proc/","/sys/","/root/")
def print_banner():
    print("Video Upscaler v"+VERSION+" (Python) — peak quality, max device strain")
def warn_cloud():
    print("WARNING: heavy job. Prefer cloud GPU: runpod.io / vast.ai")
def check_ffmpeg():
    if not shutil.which("ffmpeg"):
        print("ERROR: ffmpeg not found"); sys.exit(1)
def safe_output_path(path):
    if not path or "\x00" in path: raise ValueError("Invalid output path")
    abs_path = os.path.abspath(path)
    for prefix in SENSITIVE_PREFIXES:
        if abs_path == prefix.rstrip("/") or abs_path.startswith(prefix):
            raise ValueError("Refusing sensitive system path: "+path)
    return path
def sanitize_stem(name):
    cleaned = re.sub(r"[^A-Za-z0-9._-]", "", name)
    return cleaned or "output"
def main():
    p = argparse.ArgumentParser(description="Peak video quality")
    p.add_argument("input"); p.add_argument("-o","--out"); p.add_argument("--fps",type=int,default=60)
    p.add_argument("--width",type=int,default=3840); p.add_argument("--height",type=int,default=2160)
    p.add_argument("--crf",type=int,default=15); p.add_argument("--preset",default="veryslow")
    p.add_argument("--max",action="store_true"); p.add_argument("--threads",type=int,default=multiprocessing.cpu_count())
    p.add_argument("-f","--force",action="store_true"); p.add_argument("--1080",action="store_true",dest="p1080")
    args = p.parse_args()
    if not os.path.isfile(args.input) or not os.access(args.input, os.R_OK):
        print("Cannot read input"); sys.exit(1)
    if not (1 <= args.fps <= 240): print("fps 1-240"); sys.exit(1)
    if not (0 <= args.crf <= 51): print("crf 0-51"); sys.exit(1)
    if not (1 <= args.threads <= 256): print("threads 1-256"); sys.exit(1)
    if not (16 <= args.width <= 7680 and 16 <= args.height <= 4320): print("bad resolution"); sys.exit(1)
    if args.preset not in ALLOWED_PRESETS: print("Invalid preset"); sys.exit(1)
    print_banner(); check_ffmpeg()
    if args.p1080: args.width, args.height = 1920, 1080
    if args.max: args.crf, args.preset, args.fps = 12, "veryslow", 120; print("Peak mode")
    if not args.out:
        args.out = f"{sanitize_stem(Path(args.input).stem)}_Upscaled_{args.width}x{args.height}_{args.fps}fps.mp4"
    try: args.out = safe_output_path(args.out)
    except ValueError as e: print("ERROR:", e); sys.exit(1)
    print(f"Target {args.width}x{args.height} @{args.fps} CRF{args.crf} {args.preset} -> {args.out}")
    if not args.force and (args.fps >= 120 or args.crf <= 14 or args.preset == "veryslow"):
        warn_cloud()
        if input("Continue? (y/N): ").strip().lower() != "y": sys.exit(0)
    vf = f"scale={args.width}:{args.height}:flags=lanczos"
    if args.fps > 30: vf += f",minterpolate=fps={args.fps}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"
    encoder = "libx264"
    try:
        out = subprocess.check_output(["ffmpeg","-hide_banner","-encoders"], stderr=subprocess.STDOUT, text=True, timeout=30)
        if "libx265" in out: encoder = "libx265"
    except Exception: pass
    cmd = ["ffmpeg","-y","-i",args.input,"-vf",vf,"-c:v",encoder,"-preset",args.preset,"-crf",str(args.crf),"-threads",str(args.threads),"-c:a","aac","-b:a","320k","-movflags","+faststart",args.out]
    print("Running:", " ".join(cmd))
    try:
        subprocess.run(cmd, check=True, shell=False)
        print("Done:", args.out)
    except subprocess.CalledProcessError as e:
        print("Encode failed", e.returncode); sys.exit(1)
if __name__ == "__main__": main()
