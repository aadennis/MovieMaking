#! /usr/bin/bash

set -euo pipefail

dir='/mnt/c/temp/demo/'
sound_file=${dir}/x2_audio.mp4
video_file=${dir}/x2.mp4
output_file=${dir}/x_synced.mp4
SECONDS=+18.00

ffmpeg -y \
  -i "$sound_file" \
  -itsoffset "$SECONDS" -i "$video_file" \
  -map 0:a -map -0:v -map -1:a -map 1:v \
  -c:v copy -c:a aac -b:a 192k \
  "$output_file"

