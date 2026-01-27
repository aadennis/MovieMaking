#!/bin/bash
# Image files as input. Add metadata to viewer, and
# compile all into a single video.
# Given a folder containing a set of image files,
# create a copy of those files (same name but different
# folder), adding the filename and creation_date of each 
# file as an overlay on that new set of images.
# Finally write all the component images and text to a 
# single video file in mp4 format.

duration_per_image=3 # seconds
wild_card="s_*.png"
# NO EDITING BELOW HERE
frame_rate=1/$duration_per_image
input_folder="test_artifacts"

# Output folder - this is not created at runtime, so it must pre-exist the run
output_folder="test_output" 
mp4_out_file="woutfile.mp4" # 5.02mb for 1fps, 3.78mb for 30fps sic

for image in $input_folder/$wild_card; do
    echo "Processing [$image]"

    # Extract filename with extension
    filename=$(basename -- "$image")
    # (for no extension use...)
    # filename_no_ext="${filename%.*}"
    creation_date=$(stat -c %y "$image" | cut -d' ' -f1)
    echo "filename: $filename"
    echo "creation_date: $creation_date"

    # Overlay image with filename
    overlay_text="$filename / $creation_date"

    ffmpeg -i "$image" -vf "drawtext=text='$overlay_text':x=50:y=50:fontsize=30:fontcolor=black" "$output_folder/$filename"
    
    echo "Overlay added to $filename"
done

# input is now those jpg etc files with text, output is a single mp4 file
ffmpeg -framerate $frame_rate -pattern_type glob -i $output_folder/$wild_card -c:v libx264 -r 30 -pix_fmt yuv420p $mp4_out_file


