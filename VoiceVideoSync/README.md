# Voice/Video Sync Script

This directory contains a small helper script (`stitch_voice_video.sh`) that
uses **ffmpeg** to synchronise an audio track with a video when the audio
starts some time after the beginning of the video.

## Purpose

When you record voice or separate audio for a video, the audio may not be
aligned with the footage. Instead of editing in a DAW or video editor, this
script delays the audio stream by a specified offset (in milliseconds) and
remuxes it with the original video file.

The video stream is copied unchanged; the audio stream is encoded to AAC.
Use it as a quick command‑line tool for batch processing or simple demos.

## Usage

1. Adjust the variables at the top of `stitch_voice_video.sh`:
   - `dir` &ndash; base directory containing your files.
   - `video_file` &ndash; path to the video-only file.
   - `sound_file` &ndash; path to the audio that needs to be delayed.
   - `output_file` &ndash; path for the final combined file.
   - `OFFSET` &ndash; delay, in **milliseconds** (e.g. `16000` for 16 seconds).

2. Make the script executable (if not already) and run it:

   ```bash
   chmod +x stitch_voice_video.sh
   ./stitch_voice_video.sh
   ```

3. The resulting file will appear at the location specified by
   `output_file`.

## Example

Given a video `clip.mp4` and a separate track `voice.mp4` that starts
5 seconds late:

```bash
# inside the script (or export as environment variables)
OFFSET=5000            # delay in milliseconds
video_file=/path/to/clip.mp4
sound_file=/path/to/voice.mp4
output_file=/path/to/clip_synced.mp4

# inside the script the filter uses the `all=1` option so one value
# works regardless of channel count:
# AUDIO_FILTER="[1:a]adelay=${OFFSET}:all=1[aud]"

./stitch_voice_video.sh
```

This will produce `clip_synced.mp4` with the audio delayed by 5 seconds.

## Notes

- The script assumes the audio delay is the same on both channels; for
  different delays per channel you can modify the `adelay` filter accordingly.
- If the video already contains an audio stream, it's discarded and replaced
  with the delayed track.
- You need a recent version of **ffmpeg** installed and available on your
  `PATH`.

Feel free to adapt the script or wrap it in a more general tool if you
regularly sync many files.