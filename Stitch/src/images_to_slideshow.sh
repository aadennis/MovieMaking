#!/bin/bash
set -euo pipefail

# Build a video from all still image files in the output folder.
# Default: use ./output, show each image for 3 seconds, and write the MP4 back to the same folder.

input_folder="${1:-.}/output"
duration_per_image="${2:-3}"

# Convert to absolute path if needed
if [[ "$input_folder" != /* ]]; then
  input_folder="$(cd "$(dirname "$input_folder")" && pwd)/$(basename "$input_folder")"
fi

output_video="${3:-$input_folder/frames_video.mp4}"
image_pattern="${4:-*.jpg}"

if [ ! -d "$input_folder" ]; then
  echo "Input folder does not exist: $input_folder"
  echo "Usage: $0 [input_folder] [duration_seconds] [output_video] [image_pattern]"
  exit 1
fi

shopt -s nullglob
images=("$input_folder"/$image_pattern)
shopt -u nullglob

if [ ${#images[@]} -eq 0 ]; then
  echo "No image files found in $input_folder matching pattern $image_pattern"
  exit 1
fi

# Create temp file in the output folder to ensure it's accessible
list_file="$input_folder/.ffmpeg_concat_list"
trap 'rm -f "$list_file"' EXIT

for img in "${images[@]}"; do
  printf "file '%s'\n" "$img" >> "$list_file"
  printf "duration %s\n" "$duration_per_image" >> "$list_file"
done

# Repeat the last image line so the final frame duration is respected.
printf "file '%s'\n" "${images[-1]}" >> "$list_file"

ffmpeg -f concat -safe 0 -i "$list_file" -vsync vfr -pix_fmt yuv420p -c:v libx264 -crf 18 -preset slow "$output_video"

echo "Created video: $output_video"
