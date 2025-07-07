#!/bin/sh
#
# Convert video to GIF with smart width handling
# Usage: ./video-to-gif.sh -f input.mp4 [--fps 15] [--lossy 20] [--width 640]
#

# Default values
INPUT_FILE=""
FPS=15
LOSSY=0
WIDTH=""

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -f|--file)
      INPUT_FILE="$2"
      shift 2
      ;;
    --fps)
      FPS="$2"
      shift 2
      ;;
    -l|--lossy)
      LOSSY="$2"
      shift 2
      ;;
    -w|--width)
      WIDTH="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 -f input.mp4 [--fps 15] [--lossy 20] [--width 640]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate input
[ -z "$INPUT_FILE" ] && { echo "Error: No input file specified"; exit 1; }
[ ! -f "$INPUT_FILE" ] && { echo "Error: File not found: $INPUT_FILE"; exit 1; }

! [ "$FPS" -eq "$FPS" ] 2>/dev/null || [ "$FPS" -le 0 ] && { echo "Error: FPS must be positive"; exit 1; }
! [ "$LOSSY" -eq "$LOSSY" ] 2>/dev/null || [ "$LOSSY" -lt 0 ] || [ "$LOSSY" -gt 100 ] && { echo "Error: Lossy must be 0-100"; exit 1; }

# Get original width if --width specified
if [ -n "$WIDTH" ]; then
  ORIG_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$INPUT_FILE")
  if ! [ "$WIDTH" -eq "$WIDTH" ] 2>/dev/null || [ "$WIDTH" -le 0 ]; then
    echo "Error: Width must be positive"
    exit 1
  fi

  # Ignore if requested width > original width
  if [ "$WIDTH" -gt "$ORIG_WIDTH" ]; then
    echo "Note: Requested width ($WIDTH) > original width ($ORIG_WIDTH), using original"
    WIDTH=""
  fi
fi

# Prepare output
OUTPUT="${INPUT_FILE%.*}.gif"
PALETTE="$(mktemp --suffix=.png)"

# Build scale filter if width specified and valid
SCALE_FILTER=""
[ -n "$WIDTH" ] && SCALE_FILTER="scale=$WIDTH:-1:flags=lanczos,"

notify-send "Converting $INPUT_FILE to GIF (${FPS}FPS, lossy=$LOSSY%, width=${WIDTH:-original})" -t 3000
echo "Converting $INPUT_FILE to GIF (${FPS}FPS, lossy=$LOSSY%, width=${WIDTH:-original})"

# Generate palette
ffmpeg -v warning -i "$INPUT_FILE" -vf "${SCALE_FILTER}fps=$FPS,palettegen=stats_mode=diff" -y "$PALETTE"

# Create GIF
if [ "$LOSSY" -gt 0 ]; then
  ffmpeg -v warning -i "$INPUT_FILE" -i "$PALETTE" \
    -lavfi "${SCALE_FILTER}fps=$FPS [x]; [x][1:v] paletteuse=dither=floyd_steinberg:diff_mode=rectangle" \
    -compression_level "$LOSSY" -y "$OUTPUT"
else
  ffmpeg -v warning -i "$INPUT_FILE" -i "$PALETTE" \
    -lavfi "${SCALE_FILTER}fps=$FPS [x]; [x][1:v] paletteuse=dither=floyd_steinberg" -y "$OUTPUT"
fi

# Cleanup
rm -f "$PALETTE"

notify-send "Conversion complete: $OUTPUT" -t 3000
echo "Conversion complete: $OUTPUT"
