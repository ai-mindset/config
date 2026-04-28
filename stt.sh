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
#   ./transcribe.sh --batch  # Process all .mp3 files without .txt counterparts
#   
# Example:
#   ./transcribe.sh video.mp4
#   ./transcribe.sh /path/to/video.mp4
#   ./transcribe.sh --batch
#
# Requirements:
#   - whisper-faster-xxl must be installed and in your PATH
#   - Input file must be a valid audio/video file
#
# Note: 
#   - Output will be a txt file in the same directory as the input file
#   - Script will exit if no input file is provided in single-file mode
# ==================================

# Exit on error
set -e

# Function to process a single file
process_file() {
    local input_file="$1"
    
    # Check if file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' not found"
        return 1
    fi

    # Extract file path
    local file_path=$(dirname "$input_file")"/"

    # Run transcription
    whisper-faster-xxl "$input_file" \
        --model medium \
        --language en \
        --word_timestamps False \
        --task transcribe \
        --output_format txt \
        --output_dir "$file_path" \
        --vad_filter True \
        --compute_type auto

    echo "Transcription complete for: $input_file"
}

# Check if batch mode is requested
if [[ "$1" == "--batch" ]]; then
    echo "Running in batch mode - processing all .mp3 files without .txt counterparts"
    
    # Loop through all .mp3 files in the current directory
    for mp3_file in *.mp3; do
        # Check if the mp3 file exists (in case no .mp3 files in directory)
        [[ -f "$mp3_file" ]] || { echo "No .mp3 files found in directory"; exit 0; }
        
        # Extract the base filename without extension
        base_name="${mp3_file%.mp3}"
        
        # Check if a corresponding .txt file exists
        txt_file="${base_name}.txt"
        
        # If the .txt file doesn't exist, process the .mp3 file
        if [[ ! -f "$txt_file" ]]; then
            echo "Processing $mp3_file (no corresponding $txt_file found)"
            process_file "$mp3_file"
        else
            echo "Skipping $mp3_file (corresponding $txt_file exists)"
        fi
    done
    
    echo "Batch processing complete"
    exit 0
fi

# Single file mode
# Check if input file is provided
if [[ $# -eq 0 ]]; then
    echo "Error: No input file provided"
    echo "Usage: $0 <input_file>"
    echo "       $0 --batch"
    exit 1
fi

# Process the single input file
process_file "$1"
