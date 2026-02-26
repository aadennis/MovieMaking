#! /bin/sh
# Typically using mp4s from the wildlife camera, prep by dumping them all
# in $SRC.
# The script then cats them all into a single mp4, typically for uploading 
# to Youtube.
# https://copilot.microsoft.com/conversations/join/CZn5fSZFpjKUYoNWJ7VpB
SRC="/mnt/c/temp/wildlifecam"
mkdir -p /mnt/c/tempx

for f in "$SRC"/*.MP4; do
    base="${f%.mp4}"
    ffmpeg -i "$f" -c:v libx264 -preset medium -crf 18 -c:a aac "${base}_temp.mp4"
done

cd "$SRC"
ls *_temp.mp4 | sort | sed "s/^/file '/; s/$/'/" > concat_list.txt

ffmpeg -f concat -safe 0 -i concat_list.txt -c copy /mnt/c/tempx/output.mp4

rm *_temp.mp4 concat_list.txt