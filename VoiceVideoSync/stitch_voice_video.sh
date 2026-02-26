#! /usr/bin/bash

set -euo pipefail

dir='/mnt/c/temp/demo/'
sound_file=${dir}/x2_audio.mp4
video_file=${dir}/x2.mp4
output_file=${dir}/x_synced.mp4
SECONDS=10.00

ffmpeg -y -i "$video_file" -itsoffset "$SECONDS" -i "$sound_file" \
 -map 0:v -map -0:a -map 1:a \
  -c:v copy -c:a aac -b:a 192k \
  -shortest \
  "$output_file"
