#! /usr/bin/bash

# ------------------------------------------------------------------
# voice/video synchronisation helper
#
# RULE OF THUMB: Start video recording, then start audio recording.
# This simple script takes a video file and a separate audio track that
# starts later than the video.  It applies an `adelay` filter to the
# audio stream and then remuxes video and delayed audio into a single
# output file.  The video stream is copied; only the audio is re-encoded
# to AAC.
#
# All configuration is done via shell variables below
#
# Exit immediately if a command exits with a non‑zero status,
# treat unset variables as an error and disable pathname expansion.
set -euo pipefail

------------------------------------------------------------------

# Base directory containing input/output files 
dir='/mnt/c/temp/demo/'

# paths to the individual media components
sound_file=${dir}/R05_0007.WAV    # source audio track that lags behind video
video_file=${dir}/cur.mp4          # source video file (any audio gets stripped)
output_file=${dir}/x_synced929.mp4  # resulting combined file

# seconds, as float, of delay to apply to the audio stream
offset=8.0   # audio starts offset seconds after video
OFFSET_MS=$(echo "$offset * 1000" | bc)

# construct the ffmpeg filter graph string.  it's quoted later to
# prevent the shell from interpreting the pipe (|) character.
AUDIO_FILTER="[1:a]adelay=${OFFSET_MS}|${OFFSET_MS}[aud]"

# run ffmpeg with the complex filter and map streams appropriately
ffmpeg -y \
  -i "${video_file}" \
  -i "${sound_file}" \
  -filter_complex "$AUDIO_FILTER" \
  -map 0:v -map -0:a -map "[aud]" \
  -c:v copy -c:a aac -b:a 192k "${output_file}"

echo "$offset seconds delay was applied to the audio stream"

