#!/bin/bash
# Split a sound file of a given type, into n parts of the same type 
# For example, m4a, mp3, etc.
# Right now, the output extension is always m4a, regardless of what you specify as 
# file_type.
# Example usage (bash)
# ./split_m4a.sh /mnt/c/temp/Lesson_6/Lesson_6.m4a .m4a 4

# Input file
input_file="$1"
file_type="$2" # include the dot for now, e.g. .m4a
number_of_parts=$3


# Extract the base name (without extension) from the input file
base_name=$(basename "$input_file" "$file_type")

# Get the total duration of the file in seconds
duration=$(ffmpeg -i "$input_file" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d , | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')

# Calculate the duration of each part (divide by $number_of_parts)
part_duration=$(echo "$duration / $number_of_parts" | bc)

# Loop to create 4 parts
xx=$((number_of_parts-1))
echo $xx
for i in $(seq 0 $xx); do
  echo "Now we have $i"
  start_time=$(echo "$i * $part_duration" | bc)
  
  # Zero-padded index for the file name
  part_num=$(printf "%02d" $(($i + 1)))
  
  # Output file name
  output_file="${base_name}_${part_num}.m4a"
  
  ffmpeg -i "$input_file" -ss "$start_time" -t "$part_duration" -c copy "$output_file"
done

echo "Splitting complete!"

