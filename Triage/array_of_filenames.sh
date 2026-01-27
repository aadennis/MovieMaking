#!/bin/zsh
# Iterate through an array of filenames

workdir="/Users/den/git/BashScripts/ffmpeg/dump"

# arrange
for i in {1..4}; do
    echo "file$i content" > $workdir/file$i.txt
done

# act
file_list=($(find $workdir -iname "*.txt" | sort))
#echo "${file_list[@]}"
for file in "${file_list[@]}"; do
    if [ -f "$file" ]; then
        cat "$file"
    else
        echo "File not found: $file"
    fi
done

