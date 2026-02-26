#! /usr/bin/bash

set -euo pipefail

dir='/mnt/c/temp/demo/'
sound_file=${dir}/x2_audio.mp4
video_file=${dir}/x2.mp4
output_file=${dir}/x_synced4.mp4
OFFSET=16000   # audio starts 16 seconds after video

# build the complex filter with the offset and quote it later
AUDIO_FILTER="[1:a]adelay=${OFFSET}|${OFFSET}[aud]"

ffmpeg -y \
  -i "${video_file}" \
  -i "${sound_file}" \
  -filter_complex "$AUDIO_FILTER" \
  -map 0:v -map -0:a -map "[aud]" \
  -c:v copy -c:a aac -b:a 192k \
  "${output_file}"


