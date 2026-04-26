# !/bin/bash
# Reduce the frame rate of a video while preserving audio using ffmpeg,
# This is to reduce the overall size of the video file, while not losing audio quality.
# It defaults to 10 fps and uses the libx264 codec for video compression.
# usage:
# ./reduce_fps_preserve_audio.sh input_video.mp4 [output_video.mp4] 
# Conclusion:
# A 220mb .mov file, duration 2.5 minutes, of me playing guitar and singing,
# is reduced to 92mb using the current settings, so about 45% of the original.
# The penalty is to lose a precise sync of e.g seeing the finger touch the
# guitar fretboard at the same time as hearing the audio. 


reduce_fps_preserve_audio() {
  local input="$1"
  local output="${2:-reduced_${input##*/}}"

  ffmpeg -i "$input" \
    -r 10 \
    -c:v libx264 \
    -preset slow \
    -crf 18 \
    -c:a copy \
    "$output"
}

a='/mnt/c/temp/downloads/Sunny01.mov'
reduce_fps_preserve_audio "$a" "$2"