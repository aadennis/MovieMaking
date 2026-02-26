#! /usr/bin/bash

set -euo pipefail

dir='/mnt/c/temp/demo/'
sound_file=${dir}/x.WAV
video_file=${dir}/x.mp4
SECONDS=0.45

ffmpeg -i $video_file -itsoffset $SECONDS -i $sound_file \
  -map 0:v map 1:a \
  -c:v copy -c:a aac -b:a 192k \
  x_synced.mp4


