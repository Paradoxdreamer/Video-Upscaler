#!/usr/bin/env bash
# Video Upscaler - Push video quality to absolute peak
# Works on: Linux, Termux, a-shell, WSL, Git Bash, macOS
# Security: input validation, preset whitelist, safe paths

set -euo pipefail

VERSION="1.1.0"
SCRIPT_NAME=$(basename "$0")

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

ALLOWED_PRESETS="ultrafast superfast veryfast faster fast medium slow slower veryslow placebo"

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
  -o, --out FILE       Output file (default: <name>_Upscaled_....mp4)
  --fps N              Target frame rate 1-240  [default: 60]
  --4k                 Force 3840x2160 (default)
  --1080               Target 1920x1080 instead
  --crf N              Quality 0-51  [default: 15]
  --preset NAME        x264/x265 preset (whitelist) [default: veryslow]
  --max                Absolute peak mode (CRF 12 + veryslow + 120fps)
  --threads N          Thread count 1-256
  -f, --force          Skip safety warnings
  -h, --help           Show this help
EOF
  exit 0
}

warn_cloud() {
  echo -e "${YELLOW}"
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  ⚠️  THIS JOB IS EXTREMELY HEAVY FOR MOST DEVICES           ║"
  echo "║  Recommended: Rent a virtual / cloud GPU computer          ║"
  echo "║  • RunPod https://runpod.io  • Vast.ai https://vast.ai     ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

die() { echo -e "${RED}ERROR: $1${NC}" >&2; exit 1; }
is_int() { [[ "$1" =~ ^[0-9]+$ ]]; }

validate_int_range() {
  local name="$1" val="$2" min="$3" max="$4"
  is_int "$val" || die "$name must be an integer (got: $val)"
  (( val >= min && val <= max )) || die "$name must be between $min and $max (got: $val)"
}

is_allowed_preset() {
  local p="$1"
  for a in $ALLOWED_PRESETS; do
    [[ "$p" == "$a" ]] && return 0
  done
  return 1
}

safe_path_check() {
  local p="$1" label="$2"
  [[ -n "$p" ]] || die "$label path is empty"
  [[ "$p" != *$'\0'* ]] || die "$label path contains invalid characters"
  if [[ "$p" == /* ]]; then
    case "$p" in
      /etc/*|/usr/*|/bin/*|/sbin/*|/boot/*|/dev/*|/proc/*|/sys/*|/root/*)
        die "Refusing to write output to sensitive system path: $p"
        ;;
    esac
  fi
}

check_ffmpeg() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    die "ffmpeg not found. Install: pkg install ffmpeg | apt install ffmpeg | winget install ffmpeg"
  fi
}

INPUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -o|--out)
      [[ $# -ge 2 ]] || die "--out requires a value"
      OUTPUT="$2"; shift 2 ;;
    --fps)
      [[ $# -ge 2 ]] || die "--fps requires a value"
      TARGET_FPS="$2"; shift 2 ;;
    --4k) TARGET_WIDTH=3840; TARGET_HEIGHT=2160; shift ;;
    --1080) TARGET_WIDTH=1920; TARGET_HEIGHT=1080; shift ;;
    --crf)
      [[ $# -ge 2 ]] || die "--crf requires a value"
      CRF="$2"; shift 2 ;;
    --preset)
      [[ $# -ge 2 ]] || die "--preset requires a value"
      PRESET="$2"; shift 2 ;;
    --max) MAX_MODE=1; shift ;;
    --threads)
      [[ $# -ge 2 ]] || die "--threads requires a value"
      THREADS="$2"; shift 2 ;;
    -f|--force) FORCE=1; shift ;;
    -*) die "Unknown option: $1 (use --help)" ;;
    *)
      if [[ -z "$INPUT" ]]; then INPUT="$1"; else die "Unexpected argument: $1"; fi
      shift ;;
  esac
done

[[ -n "$INPUT" ]] || { echo -e "${RED}Error: No input video provided.${NC}"; usage; }
[[ -f "$INPUT" ]] || die "File not found: $INPUT"
[[ -r "$INPUT" ]] || die "Cannot read input file: $INPUT"

validate_int_range "fps" "$TARGET_FPS" 1 240
validate_int_range "crf" "$CRF" 0 51
validate_int_range "threads" "$THREADS" 1 256
validate_int_range "width" "$TARGET_WIDTH" 16 7680
validate_int_range "height" "$TARGET_HEIGHT" 16 4320
is_allowed_preset "$PRESET" || die "Invalid preset '$PRESET'. Allowed: $ALLOWED_PRESETS"

print_banner
check_ffmpeg

if [[ $MAX_MODE -eq 1 ]]; then
  CRF=12; PRESET="veryslow"; TARGET_FPS=120
  echo -e "${GREEN}★ Absolute Peak Upscale Mode enabled (CRF $CRF, $PRESET, ${TARGET_FPS}fps)${NC}"
fi

if [[ -z "$OUTPUT" ]]; then
  BASE=$(basename -- "$INPUT")
  NAME="${BASE%.*}"
  NAME=$(echo "$NAME" | tr -cd 'A-Za-z0-9._-')
  [[ -n "$NAME" ]] || NAME="output"
  OUTPUT="${NAME}_Upscaled_${TARGET_WIDTH}x${TARGET_HEIGHT}_${TARGET_FPS}fps.mp4"
fi

safe_path_check "$OUTPUT" "Output"
safe_path_check "$INPUT" "Input"

echo -e "${CYAN}Device info:${NC}"
echo "  CPU threads available : $THREADS"
echo "  Target resolution     : ${TARGET_WIDTH}x${TARGET_HEIGHT}"
echo "  Target FPS            : $TARGET_FPS"
echo "  CRF / Preset          : $CRF / $PRESET"
echo "  Output                : $OUTPUT"
echo

if [[ $FORCE -eq 0 ]]; then
  if [[ $TARGET_FPS -ge 120 || $CRF -le 14 || "$PRESET" == "veryslow" ]]; then
    warn_cloud
    echo -e "${YELLOW}Continue on this device? (y/N)${NC}"
    read -r ans || true
    if [[ ! "${ans:-}" =~ ^[Yy]$ ]]; then
      echo "Aborted. Rent a cloud GPU and run the same command there."
      exit 0
    fi
  fi
fi

echo -e "${GREEN}Starting peak quality encode... This will strain the device.${NC}"
echo

VF="scale=${TARGET_WIDTH}:${TARGET_HEIGHT}:flags=${SCALE_FLAGS}"
if [[ $TARGET_FPS -gt 30 ]]; then
  VF="${VF},minterpolate=fps=${TARGET_FPS}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"
fi

ENCODER="libx264"
if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libx265; then
  ENCODER="libx265"
fi

CMD=(
  ffmpeg -y -i "$INPUT" -vf "$VF" -c:v "$ENCODER" -preset "$PRESET"
  -crf "$CRF" -threads "$THREADS" -c:a aac -b:a 320k -movflags +faststart "$OUTPUT"
)

echo -e "${CYAN}Command:${NC}"
printf ' %q' "${CMD[@]}"
echo; echo
"${CMD[@]}"

echo
echo -e "${GREEN}✓ Done! Peak quality video saved to:${NC}"
echo "  $OUTPUT"
echo "If this took too long, use a cloud GPU next time. See docs/CLOUD.md"
