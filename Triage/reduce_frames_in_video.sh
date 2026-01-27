#!/bin/bash

# This script processes a video file to extract specific frames and their corresponding audio segments,
# then combines them into a new video file. The user can specify the interval of frames to extract
# and the duration of the audio segments. The script performs the following steps:
#
# 1. Parses input arguments to determine the source folder, source file, frame interval, and audio duration.
# 2. Sets up temporary directories and output file paths.
# 3. Detects the frame rate (FPS) and total frame count of the source video.
# 4. Iterates through the video, extracting frames and audio segments at the specified interval.
# 5. Combines each frame and audio segment into a short video segment.
# 6. Concatenates all the generated segments into a final output video.
# 7. Cleans up temporary files and directories.
#
# Dependencies:
# - ffmpeg: For video and audio processing.
# - ffprobe: For extracting video metadata.
# - awk, bc, sed: For calculations and string manipulations.
#
# Usage:
# ./reduce_frames_in_video.sh <source_folder> <source_file> [nth_frame] [frame_duration]
# Example:
# ./reduce_frames_in_video.sh "/mnt/c/Videos" "abc.avi" 60 2
#
# Arguments:
# - <source_folder>: Path to the folder containing the source video file.
# - <source_file>: Name of the source video file.
# - [nth_frame]: Optional. Extract every nth frame (default: 60).
# - [frame_duration]: Optional. Duration of audio segments in seconds (default: 2).
#
# Output:
# - A new video file is saved in the source folder with a randomized name to

# --- Argument parsing ---
SOURCE_FOLDER="$1"
SOURCE_FILE="$2"
NTH_FRAME="${3:-60}"         # Default: every 60th frame
FRAME_DURATION="${4:-2}"     # Default: 2 seconds per frame

# --- Path setup ---
BASENAME="${SOURCE_FILE%.*}"
EXT="${SOURCE_FILE##*.}"
RAND_INT=$((RANDOM % 9000 + 1000))
OUTPUT_FILE="${BASENAME}_${RAND_INT}.${EXT}"
TEMP_DIR="${SOURCE_FOLDER}/temp_${RAND_INT}"

mkdir -p "$TEMP_DIR"

# --- Detect FPS from source file ---
FPS_RAW=$(ffprobe -v error -select_streams v:0 \
  -show_entries stream=avg_frame_rate \
  -of default=noprint_wrappers=1:nokey=1 "${SOURCE_FOLDER}/${SOURCE_FILE}")
FPS_FLOAT=$(echo "$FPS_RAW" | awk -F/ '{print $1/$2}')
FPS_FLOAT=${FPS_FLOAT:-25}  # Fallback if detection fails

# --- Get total frame count ---
TOTAL_FRAMES=$(ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=nb_read_frames \
  -of default=noprint_wrappers=1:nokey=1 "${SOURCE_FOLDER}/${SOURCE_FILE}")
TOTAL_FRAMES=${TOTAL_FRAMES:-1000}  # Fallback if detection fails

# --- Generate segments ---
SEGMENT_LIST="${TEMP_DIR}/segments.txt"
> "$SEGMENT_LIST"

for ((i=0; i<TOTAL_FRAMES; i+=NTH_FRAME)); do
  TS=$(echo "$i / $FPS_FLOAT" | bc -l)
  TS_SAFE=$(printf "%06.2f" "$TS" | sed 's/\./_/g')
  if [[ -z "$TS" || "$TS" == "." ]]; then
    echo "⚠️ Skipping frame $i due to invalid timestamp"
    continue
  fi

  FRAME_OUT="${TEMP_DIR}/frame_${TS_SAFE}.png"
  AUDIO_OUT="${TEMP_DIR}/audio_${TS_SAFE}.aac"
  SEGMENT_OUT="${TEMP_DIR}/segment_${TS_SAFE}.mp4"

  # Extract frame
  ffmpeg -ss "$TS" -i "${SOURCE_FOLDER}/${SOURCE_FILE}" -frames:v 1 "$FRAME_OUT" -y

  # Extract audio slice
  ffmpeg -ss "$TS" -t "$FRAME_DURATION" -i "${SOURCE_FOLDER}/${SOURCE_FILE}" -vn -acodec aac "$AUDIO_OUT" -y

  # Combine frame + audio into segment
  ffmpeg -loop 1 -i "$FRAME_OUT" -i "$AUDIO_OUT" \
    -c:v libx264 -t "$FRAME_DURATION" -pix_fmt yuv420p \
    -c:a aac -shortest "$SEGMENT_OUT" -y

  echo "file '$(realpath "$SEGMENT_OUT")'" >> "$SEGMENT_LIST"
done

# --- Concatenate all segments ---
if [[ ! -f "$SEGMENT_LIST" ]]; then
  echo "❌ Segment list not found: $SEGMENT_LIST"
  exit 1
fi
ffmpeg -f concat -safe 0 -i "$SEGMENT_LIST" -c copy "${SOURCE_FOLDER}/${OUTPUT_FILE}" -y

# --- Cleanup ---
rm -rf "$TEMP_DIR"

echo "✅ Final video saved to: ${SOURCE_FOLDER}/${OUTPUT_FILE}"
