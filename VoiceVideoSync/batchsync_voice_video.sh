#!/bin/bash
# -----------------------------------------------------------------------------
# Batch audio/video sync fixer for MP4 files in current folder
# Requires: ffmpeg
# Usage: Set OFFSET, then run
# Purpose: Fix audio lag in Camo webcam recordings (case-by-case)
# -----------------------------------------------------------------------------

# Audio offset in seconds (e.g. -2.5, e.g. +4.15)
OFFSET=+0.5

# Sanitize OFFSET for filename tag
OFFSET_TAG=$(echo "$OFFSET" | sed 's/-/m/; s/+/p/; s/\./d/')

# 🌀 Loop through all .mp4 files in current directory
for INPUT in *.mp4; do
  # Skip if no .mp4 files found
  [ -e "$INPUT" ] || continue

  # Generate random-ish 4-digit suffix
  SUFFIX=$(( RANDOM % 9000 + 1000 ))

  # 📝 Derive output filename
  BASENAME="${INPUT%.*}"
  EXT="${INPUT##*.}"
  OUTPUT="${BASENAME}_${OFFSET_TAG}_${SUFFIX}.${EXT}"

  echo "🔧 Processing: $INPUT → $OUTPUT"

  # 🛠 Realign audio using ffmpeg
  ffmpeg -i "$INPUT" -itsoffset "$OFFSET" -i "$INPUT" \
    -map 0:v -map 1:a -c:v copy -c:a copy "$OUTPUT"
done