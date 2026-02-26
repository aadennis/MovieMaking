#! /usr/bin/bash

# Exit immediately if a command exits with a non‑zero status,
# treat unset variables as an error and disable pathname expansion.
set -euo pipefail

# ------------------------------------------------------------------
# voice/video synchronisation helper
#
# This simple script takes a video file and a separate audio track that
# starts later than the video.  It applies an `adelay` filter to the
# audio stream and then remuxes video and delayed audio into a single
# output file.  The video stream is copied; only the audio is re-encoded
# to AAC.
#
# All configuration is done via shell variables below; you can modify
# them directly or parameterise the script further if needed.
# ------------------------------------------------------------------

# Base directory containing input/output files (change to suit your setup)
dir='/mnt/c/temp/demo/'

# paths to the individual media components
sound_file=${dir}/x2_audio.mp4    # audio track that lags behind video
video_file=${dir}/x2.mp4          # original video-only file
output_file=${dir}/x_synced4.mp4  # resulting combined file

# amount of delay to apply to the audio stream, in milliseconds
# (e.g. 16 seconds = 16000 ms)
OFFSET=16000   # audio starts 16 seconds after video

# construct the ffmpeg filter graph string.  it's quoted later to
# prevent the shell from interpreting the pipe (|) character.
AUDIO_FILTER="[1:a]adelay=${OFFSET}|${OFFSET}[aud]"

# run ffmpeg with the complex filter and map streams appropriately
ffmpeg -y \
  -i "${video_file}" \
  -i "${sound_file}" \
  -filter_complex "$AUDIO_FILTER" \
  -map 0:v -map -0:a -map "[aud]" \
  -c:v copy -c:a aac -b:a 192k "${output_file}"


