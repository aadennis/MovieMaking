#!/bin/bash
# -----------------------------------------------------------------------------
# Audio/video  sync fixer for MP4 files
# Requires: ffmpeg
# Usage: Edit INPUT and OFFSET, then run
# Purpose: Using the Camo webcam recording software, I saw a visible lag between
# video and audio, say on a 3 minute video. This aims to fix that. 
# Caution: testing on a 15 second video, lag was minimal. It was more noticeable
# on a 3 minute video. So you need to approach this case by case, and not 
# assume that on a given platform, videos of all lengths require the same offset.
# BTW, Camo, 3 minutes, +0.5 seems to work... but not guaranteed.
# -----------------------------------------------------------------------------

# Load config file
CONFIG_FILE="./syncfix.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Source the config
source "$CONFIG_FILE"

echo "Using config: $CONFIG_FILE"
echo "Input:  $INPUT"
echo "Offset: $OFFSET"
echo "Path to Input file: $VIDEO_PATH"

# Audio offset in seconds (e.g. -2.5, e.g. +4.15):
# If you see that the video comes after / lags behind the matching audio, 
# then move the offset to the positive direction. Else to the negative direction.

PATH_INC_FILE="${VIDEO_PATH}/${INPUT}"

# Generate random-ish 4-digit suffix
SUFFIX=$(( RANDOM % 9000 + 1000 ))

# Join path and filename


# Sanitize OFFSET for filename
# Example output:
# MySong_p0d5_2148.mp4 - positive 0.5
# MySong_m3d5_6157.mp4 - negative 3.5

# Replace minus with 'm', plus with 'p', dot with 'd'
OFFSET_TAG=$(echo "$OFFSET" | sed 's/-/m/; s/+/p/; s/\./d/')

# 📝 Derive output filename
BASENAME="${INPUT%.*}"
EXT="${INPUT##*.}"
OUTPUT="${VIDEO_PATH}/${BASENAME}_${OFFSET_TAG}_${SUFFIX}.${EXT}"

# 🛠 Realign audio using ffmpeg
ffmpeg -i "$PATH_INC_FILE" -itsoffset "$OFFSET" -i "$INPUT" \
-map 0:v -map 1:a -c:v copy -c:a copy "$OUTPUT"
