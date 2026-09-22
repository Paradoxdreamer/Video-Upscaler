#!/usr/bin/env bash
# Simple installer helper for Video Upscaler

set -e

echo "Video Upscaler installer helper"
echo "==============================="

# Detect package manager
if command -v pkg >/dev/null 2>&1; then
  # Termux
  echo "Detected Termux"
  pkg update -y
  pkg install -y ffmpeg git python
elif command -v apt >/dev/null 2>&1; then
  echo "Detected apt (Debian/Ubuntu)"
  sudo apt update
  sudo apt install -y ffmpeg git python3
elif command -v dnf >/dev/null 2>&1; then
  echo "Detected dnf"
  sudo dnf install -y ffmpeg git python3
elif command -v pacman >/dev/null 2>&1; then
  echo "Detected pacman"
  sudo pacman -Sy --noconfirm ffmpeg git python
elif command -v brew >/dev/null 2>&1; then
  echo "Detected Homebrew"
  brew install ffmpeg git python
else
  echo "Could not detect package manager."
  echo "Please install ffmpeg and git manually."
  exit 1
fi

echo
echo "Done. Now clone the repo if you haven't:"
echo "  git clone https://github.com/Paradoxdreamer/Video-Upscaler.git"
echo "  cd Video-Upscaler"
echo "  chmod +x cli/video_upscaler.sh"
echo "  ./cli/video_upscaler.sh yourvideo.mp4"
