#!/bin/bash

INPUT="YourSong.mp4"

# ⏱ Audio offset in seconds (negative = move video to a later start, positive - audio starts later)
OFFSET=+0.1

# 🧮 Generate random-ish 4-digit suffix
SUFFIX=$(( RANDOM % 9000 + 1000 ))

# 📝 Derive output filename from input
BASENAME="${INPUT%.*}"
EXT="${INPUT##*.}"
OUTPUT="${BASENAME}_out_${SUFFIX}.${EXT}"

# 🛠 Realign audio using ffmpeg
ffmpeg -i "$INPUT" -itsoffset "$OFFSET" -i "$INPUT" \
-map 0:v -map 1:a -c:v copy -c:a copy "$OUTPUT"

