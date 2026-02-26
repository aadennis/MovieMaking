#!/usr/bin/env bash
# Typically using mp4s from the wildlife camera, prep by dumping them all
# in $SRC.
# The script then cats them all into a single mp4, typically for uploading 
# to Youtube.
# https://copilot.microsoft.com/conversations/join/CZn5fSZFpjKUYoNWJ7VpB
#!/usr/bin/env bash

set -euo pipefail

SRC="/mnt/c/temp/wildlifecam"
DEST="/mnt/c/tempx/output.mp4"
TITLE="Foxes in Garden - January 2026"

cd "$SRC"

echo "Normalising source videos…"
for f in *.avi *.mp4; do
    [ -e "$f" ] || continue
    base="${f%.*}"
    ffmpeg -y -i "$f" -c:v libx264 -preset medium -crf 18 -c:a aac "${base}_temp.mp4"
done

echo "Generating title card…"
ffmpeg -y -f lavfi -i "color=black:size=1920x1080:duration=3" \
       -vf "drawtext=text='$TITLE':fontcolor=white:fontsize=96:x=(w-text_w)/2:y=(h-text_h)/2" \
       -c:v libx264 -crf 18 -preset medium title_intro.mp4

echo "Building concat list…"
{
    echo "file 'title_intro.mp4'"
    ls *_temp.mp4 | sort | sed "s/^/file '/; s/$/'/"
} > concat_list.txt

echo "Concatenating…"
ffmpeg -y -f concat -safe 0 -i concat_list.txt -c copy "$DEST"

echo "Cleaning up…"
rm -f *_temp.mp4 concat_list.txt

echo "Done. Output written to: $DEST"

