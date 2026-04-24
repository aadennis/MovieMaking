#!/bin/bash
# Extract frames from a video at the default or supplied fps,
# and save these as a set of JPG files.
# Typically, the source will be a timelapse video with a maximum 
# recording time of 30 seconds. Else your drive may fill up with 
# output frames, at this quality level (-q:v 2)

# usage examples:
# ./save_frames_from_video.sh /mnt/c/temp/downloads/IMG_8791.MOV
# fps=20
# ./save_frames_from_video.sh /mnt/c/temp/downloads/IMG_8791.MOV $fps


# Check if video file was provided
if [ $# -eq 0 ]; then
    echo "No video file provided. Usage: ./save_frames_from_video.sh <video_file.mov> [fps]"
    exit 1
fi

input_video="$1"
fps="${2:-10}"  # Default to 10 fps if not specified
output_folder="./output"
output_pattern="frame_%04d.jpg"

mkdir -p "$output_folder"

# Use ffmpeg to extract frames at specified fps and overlay a large orange frame number
ffmpeg -i "$input_video" -vf "fps=$fps,drawtext=fontsize=72:fontcolor=orange:font='Sans':x=30:y=h-text_h-30:text='frame_%{eif\\:n+1\\:d\\:04}':shadowcolor=black:shadowx=2:shadowy=2" -q:v 2 "$output_folder/$output_pattern"

echo "Frames extracted from $input_video to $output_folder/frame_0001.jpg, frame_0002.jpg, etc."