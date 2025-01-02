#!/usr/bin/env zsh

# ==================================
# Speech To Transcript Script
# ==================================
#
# Description:
#   Transcribes video/audio files using whisper-faster-xxl with optimised settings
#
# Usage:
#   ./transcribe.sh <input_file>
#   
# Example:
#   ./transcribe.sh video.mp4
#   ./transcribe.sh /path/to/video.mp4
#
# Requirements:
#   - whisper-faster-xxl must be installed and in your PATH
#   - Input file must be a valid audio/video file
#
# Note: 
#   - Output will be a txt file in the same directory as the input file
#   - Script will exit if no input file is provided
# ==================================

# Exit on error
set -e

# Check if input file is provided
if [[ $# -eq 0 ]]; then
    echo "Error: No input file provided"
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Check if file exists
if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found"
    exit 1
fi

# Extract file path
file_path=$(dirname "$1")"/"

# Run transcription
whisper-faster-xxl "$1" \
    --model medium \
    --language en \
    --word_timestamps False \
    --task transcribe \
    --output_format txt \
    --output_dir "$file_path" \
    --vad_filter True \
    --compute_type auto

echo "Transcription complete for: $1"
