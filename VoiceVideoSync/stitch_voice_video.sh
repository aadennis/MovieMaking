#! /usr/bin/bash

set -euo pipefail

dir='/mnt/c/temp/demo/'
sound_file=${dir}/x2_audio.mp4
video_file=${dir}/x2.mp4
output_file=${dir}/x_synced.mp4
SECONDS=16.0   # audio starts 16 seconds after video

ffmpeg -y \
  -i /mnt/c/temp/demo/x2.mp4 \
  -itsoffset 16.0 -i /mnt/c/temp/demo/x2_audio.mp4 \
  -map 0:v -map -0:a -map 1:a \
  -c:v copy -c:a aac -b:a 192k \
  /mnt/c/temp/demo/x_synced.mp4

  
