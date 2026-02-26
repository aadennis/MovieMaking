#! /usr/bin/bash

set -euo pipefail

dir='/mnt/c/temp/demo/'
sound_file=${dir}/x2_audio.mp4
video_file=${dir}/x2.mp4
output_file=${dir}/x_synced4.mp4
OFFSET=16000   # audio starts 16 seconds after video

ffmpeg -y \
  -i "${video_file}" \
  -i "${sound_file}" \
  -filter_complex "[1:a]adelay=${OFFSET}|${OFFSET}[aud]" \
  -map 0:v -map -0:a -map "[aud]" \
  -c:v copy -c:a aac -b:a 192k \
  "${output_file}"


