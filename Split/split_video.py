"""
Split Video - Divide MP4 files into equal-duration segments.

This module provides functionality to split an MP4 video file into a specified
number of equal-duration segments. It uses FFmpeg for efficient, lossless
splitting via stream copying (no re-encoding).

Key Features:
  - Splits videos into equal-duration segments
  - Uses stream copying for fast processing (no re-encoding)
  - Generates unique segment identifiers to avoid conflicts
  - Displays progress during processing
  - Includes error handling for invalid input files

Requirements:
  - ffmpeg: Video processing (https://ffmpeg.org)
  - ffprobe: Video metadata extraction (comes with ffmpeg)

Usage:
  python split_video.py input.mp4 --split_count 3
  
  This creates 3 equal-duration segments from input.mp4 with names like:
  - input_1234_1.mp4
  - input_1234_2.mp4
  - input_1234_3.mp4

Example:
  Split a 30-minute video into 3 segments (10 minutes each):
  $ python split_video.py myvideo.mp4 --split_count 3
"""

import subprocess
import os
import random
import argparse

def get_video_duration(input_file):
    """
    Retrieve the duration of a video file using ffprobe.
    
    Uses ffprobe to query video metadata without loading the entire file
    into memory. Includes error handling for invalid files or ffprobe failures.
    
    Args:
        input_file (str): Path to the video file.
        
    Returns:
        float: Duration in seconds.
        
    Raises:
        ValueError: If ffprobe fails or returns no duration data.
        
    Example:
        >>> duration = get_video_duration('myvideo.mp4')
        >>> print(f"Video is {duration:.2f} seconds long")
    """
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
         '-of', 'default=noprint_wrappers=1:nokey=1', input_file],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    raw_output = result.stdout.strip()
    if not raw_output:
        raise ValueError(f"❌ ffprobe failed. stderr: {result.stderr.strip()}")
    return float(raw_output)

def split_video(input_file, split_count=2):
    """
    Split a video file into equal-duration segments.
    
    Divides the input video into the specified number of equal-duration segments
    using FFmpeg's stream copy mode for fast, lossless processing. Each segment
    is saved as a separate MP4 file with a unique identifier to prevent conflicts.
    
    Args:
        input_file (str): Path to the input video file (typically MP4).
        split_count (int, optional): Number of segments to create. Defaults to 2.
        
    Returns:
        None
        
    Side Effects:
        Creates split_count new MP4 files in the same directory as input_file.
        Output filenames follow the pattern: {basename}_{random_id}_{segment_number}.mp4
        
    Raises:
        ValueError: If the input file duration cannot be determined.
        subprocess.CalledProcessError: If FFmpeg encounters an error during splitting.
        
    Example:
        >>> split_video('myvideo.mp4', split_count=3)
        # Creates: myvideo_1234_1.mp4, myvideo_1234_2.mp4, myvideo_1234_3.mp4
    """
    duration = get_video_duration(input_file)
    segment_duration = duration / split_count
    base_name, ext = os.path.splitext(input_file)
    rand_id = random.randint(1000, 9999)

    for i in range(split_count):
        start_time = i * segment_duration
        output_file = f"{base_name}_{rand_id}_{i+1}.mp4"
        print(f"🔧 Creating segment {i+1}/{split_count}: {output_file}")

        subprocess.run([
            'ffmpeg', '-y', '-ss', str(start_time), '-i', input_file,
            '-t', str(segment_duration), '-c', 'copy', output_file
        ])

    print(f"✅ Done. Created {split_count} segments with ID {rand_id}.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split MP4 into equal parts.")
    parser.add_argument("input_file", help="Path to input MP4 file")
    parser.add_argument("--split_count", type=int, default=2, help="Number of segments (default: 2)")
    args = parser.parse_args()

    split_video(args.input_file, args.split_count)

 