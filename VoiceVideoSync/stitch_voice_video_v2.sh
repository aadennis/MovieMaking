#! /usr/bin/bash

# Exit immediately if a command exits with a non‑zero status,
# treat unset variables as an error and disable pathname expansion.
set -euo pipefail

# ------------------------------------------------------------------
# voice/video synchronisation helper
#
# This script takes a video file and a separate audio track and 
# synchronises them. It handles two cases:
#
# 1. Audio starts later than video: applies an `adelay` filter to 
#    delay the audio stream.
# 2. Audio starts before video: applies an `atrim` filter to trim 
#    audio from the beginning so it aligns with video start.
#
# In both cases, video and delayed/trimmed audio are remuxed into 
# a single output file. The video stream is copied; only the audio 
# is re-encoded to AAC.
#
# All configuration is done via shell variables below; you can modify
# them directly or parameterise the script further if needed.
# ------------------------------------------------------------------

# Base directory containing input/output files (change to suit your setup)
dir='/mnt/c/temp/demo/'

# paths to the individual media components
sound_file=${dir}/x.WAV    # audio track
video_file=${dir}/x.mp4          # original video-only file
output_file=${dir}/x_synced2s4.mp4  # resulting combined file

# offset between video and audio in milliseconds
# POSITIVE: audio starts AFTER video (audio lags behind)
#   e.g. OFFSET=16000 means audio starts 16 seconds after video
# NEGATIVE: audio starts BEFORE video (audio leads)
#   e.g. OFFSET=-2000 means audio starts 2 seconds before video
#        (and will be trimmed to remove the first 2 seconds)
OFFSET=-20000    # audio starts 1 millisecond after video

# Determine which filter to apply based on offset sign
if [ "$OFFSET" -gt 0 ]; then
  # Audio starts after video: apply delay (adelay)
  AUDIO_FILTER="[1:a]adelay=${OFFSET}|${OFFSET}[aud]"
elif [ "$OFFSET" -lt 0 ]; then
  # Audio starts before video: apply trim (atrim)
  # Convert milliseconds to seconds (negative offset means trim at start)
  TRIM_SECONDS=$(echo "${OFFSET}" | awk '{printf "%.3f", -$1 / 1000}')
  AUDIO_FILTER="[1:a]atrim=start=${TRIM_SECONDS}[aud]"
else
  # No offset: pass audio through unchanged
  AUDIO_FILTER="[1:a]aformat=sample_rates=44100[aud]"
fi

# run ffmpeg with the complex filter and map streams appropriately
ffmpeg -y \
  -i "${video_file}" \
  -i "${sound_file}" \
  -filter_complex "$AUDIO_FILTER" \
  -map 0:v -map -0:a -map "[aud]" \
  -c:v copy -c:a aac -b:a 192k "${output_file}"


