#!/usr/bin/env bash
set -euo pipefail

WPDIR="/home/sonata/Pictures/Wallpapers"

# cari file gambar
mapfile -d $'\0' -t files < <(find "$WPDIR" -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) -print0)

if [ "${#files[@]}" -eq 0 ]; then
  echo "No wallpapers found in: $WPDIR" >&2
  exit 1
fi

# pastikan daemon jalan
if ! swww query >/dev/null 2>&1; then
  swww-daemon >/dev/null 2>&1 &
  sleep 0.35
fi

# pilih gambar random
IMG="${files[RANDOM % ${#files[@]}]}"

# transisi selalu grow
type="grow"

# posisi random (0.0–1.0 float)
xi=$((RANDOM % 101))
yi=$((RANDOM % 101))
x=$(awk -v v="$xi" 'BEGIN{printf "%.2f", v/100}')
y=$(awk -v v="$yi" 'BEGIN{printf "%.2f", v/100}')

# parameter transisi untuk lingkaran halus
fps=60
step=60
duration=1.5
bezier="0.4,0.0,0.2,1.0"

# apply wallpaper
swww img "$IMG" \
  --transition-type "$type" \
  --transition-pos "$x,$y" \
  --transition-fps "$fps" \
  --transition-step "$step" \
  --transition-duration "$duration" \
  --transition-bezier "$bezier"

echo "$(date +'%F %T') set: $IMG type=$type pos=$x,$y"

