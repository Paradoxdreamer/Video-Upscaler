#!/usr/bin/env bash
# Video Upscaler - Push video quality to absolute peak
# Works on: Linux, Termux, a-shell, WSL, Git Bash, macOS

set -euo pipefail

VERSION="1.0.0"
SCRIPT_NAME=$(basename "$0")

# Defaults
TARGET_WIDTH=3840
TARGET_HEIGHT=2160
TARGET_FPS=60
CRF=15
PRESET="veryslow"
SCALE_FLAGS="lanczos"
OUTPUT=""
MAX_MODE=0
FORCE=0
THREADS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║           Video Upscaler v${VERSION}                      ║"
  echo "║   Absolute peak quality • Max device strain          ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <input_video> [options]

Options:
  -o, --out FILE       Output file (default: input_Upscaled.mp4)
  --fps N              Target frame rate (30/60/120/240)  [default: 60]
  --4k                 Force 3840x2160 (default)
  --1080               Target 1920x1080 instead
  --crf N              Quality (0=lossless-ish, 18=visually lossless) [default: 15]
  --preset NAME        x264/x265 preset (ultrafast..veryslow) [default: veryslow]
  --max                Absolute peak mode (CRF 12 + veryslow + 120fps)
  --threads N          Force thread count
  -f, --force          Skip safety warnings
  -h, --help           Show this help

Examples:
  $SCRIPT_NAME video.mp4
  $SCRIPT_NAME video.mp4 --fps 120 --crf 14
  $SCRIPT_NAME video.mp4 --max -o ultra.mp4
EOF
  exit 0
}

warn_cloud() {
  echo -e "${YELLOW}"
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  ⚠️  THIS JOB IS EXTREMELY HEAVY FOR MOST DEVICES           ║"
  echo "║                                                            ║"
  echo "║  Recommended: Rent a virtual / cloud GPU computer          ║"
  echo "║                                                            ║"
  echo "║  • RunPod     https://runpod.io                            ║"
  echo "║  • Vast.ai    https://vast.ai                              ║"
  echo "║  • Lambda     https://lambdalabs.com                       ║"
  echo "║  • Paperspace https://www.paperspace.com                   ║"
  echo "║                                                            ║"
  echo "║  Look for RTX 3090 / 4090 / A100 instances.                ║"
  echo "║  Then run the same command on the remote machine.          ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

check_ffmpeg() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo -e "${RED}ERROR: ffmpeg not found.${NC}"
    echo "Install it first:"
    echo "  Termux:    pkg install ffmpeg"
    echo "  Ubuntu:    sudo apt install ffmpeg"
    echo "  Windows:   winget install ffmpeg  or download from ffmpeg.org"
    exit 1
  fi
}

# Parse arguments
INPUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -o|--out) OUTPUT="$2"; shift 2 ;;
    --fps) TARGET_FPS="$2"; shift 2 ;;
    --4k) TARGET_WIDTH=3840; TARGET_HEIGHT=2160; shift ;;
    --1080) TARGET_WIDTH=1920; TARGET_HEIGHT=1080; shift ;;
    --crf) CRF="$2"; shift 2 ;;
    --preset) PRESET="$2"; shift 2 ;;
    --max) MAX_MODE=1; shift ;;
    --threads) THREADS="$2"; shift 2 ;;
    -f|--force) FORCE=1; shift ;;
    -*) echo "Unknown option $1"; usage ;;
    *) 
      if [[ -z "$INPUT" ]]; then
        INPUT="$1"
      else
        echo "Unexpected argument: $1"; usage
      fi
      shift
      ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo -e "${RED}Error: No input video provided.${NC}"
  usage
fi

if [[ ! -f "$INPUT" ]]; then
  echo -e "${RED}Error: File not found: $INPUT${NC}"
  exit 1
fi

print_banner
check_ffmpeg

if [[ $MAX_MODE -eq 1 ]]; then
  CRF=12
  PRESET="veryslow"
  TARGET_FPS=120
  echo -e "${GREEN}★ Absolute Peak Upscale Mode enabled (CRF $CRF, $PRESET, ${TARGET_FPS}fps)${NC}"
fi

if [[ -z "$OUTPUT" ]]; then
  BASE=$(basename "$INPUT")
  NAME="${BASE%.*}"
  OUTPUT="${NAME}_Upscaled_${TARGET_WIDTH}x${TARGET_HEIGHT}_${TARGET_FPS}fps.mp4"
fi

# Hardware info
echo -e "${CYAN}Device info:${NC}"
echo "  CPU threads available : $THREADS"
echo "  Target resolution     : ${TARGET_WIDTH}x${TARGET_HEIGHT}"
echo "  Target FPS            : $TARGET_FPS"
echo "  CRF / Preset          : $CRF / $PRESET"
echo "  Scale algorithm       : $SCALE_FLAGS"
echo "  Output                : $OUTPUT"
echo

# Safety check for high settings
if [[ $FORCE -eq 0 ]]; then
  if [[ $TARGET_FPS -ge 120 || $CRF -le 14 || "$PRESET" == "veryslow" ]]; then
    warn_cloud
    echo -e "${YELLOW}Continue on this device? (y/N)${NC}"
    read -r ans
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      echo "Aborted. Rent a cloud GPU and run the same command there."
      exit 0
    fi
  fi
fi

echo -e "${GREEN}Starting peak quality encode... This will strain the device.${NC}"
echo

# Build filter
VF="scale=${TARGET_WIDTH}:${TARGET_HEIGHT}:flags=${SCALE_FLAGS}"

if [[ $TARGET_FPS -gt 30 ]]; then
  VF="${VF},minterpolate=fps=${TARGET_FPS}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"
fi

ENCODER="libx264"
if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libx265; then
  ENCODER="libx265"
fi

CMD=(
  ffmpeg -y
  -i "$INPUT"
  -vf "$VF"
  -c:v "$ENCODER"
  -preset "$PRESET"
  -crf "$CRF"
  -threads "$THREADS"
  -c:a aac -b:a 320k
  -movflags +faststart
  "$OUTPUT"
)

echo -e "${CYAN}Command:${NC}"
printf ' %q' "${CMD[@]}"
echo
echo

"${CMD[@]}"

echo
echo -e "${GREEN}✓ Done! Peak quality video saved to:${NC}"
echo "  $OUTPUT"
echo
echo "If this took too long or the device struggled, next time use a cloud GPU instance."
echo "See docs/CLOUD.md for quick start guides."
