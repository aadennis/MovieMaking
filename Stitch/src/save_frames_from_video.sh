#!/bin/bash
# Extract frames from a video every 0.1 seconds and save as JPG.
# Typically, the source will be a timelapse video with a maximum 
# recording time of 30 seconds. Else your drive may fill up with 
# output frames.

# usage example:
# ./save_frames_from_video.sh /mnt/c/temp/downloads/IMG_8791.MOV

# Check if video file was provided
if [ $# -eq 0 ]; then
    echo "No video file provided. Usage: ./save_frames_timelapse.sh <video_file.mov>"
    exit 1
fi

input_video="$1"
output_folder="./output"
output_pattern="frame_%04d.jpg"

mkdir -p "$output_folder"

# Use ffmpeg to extract frames at 10 fps (every 0.1 seconds)
# -q:v 2 requests high JPEG quality (lower value = better quality)
ffmpeg -i "$input_video" -vf fps=10 -q:v 2 "$output_folder/$output_pattern"

echo "Frames extracted from $input_video to $output_folder/frame_0001.jpg, frame_0002.jpg, etc."