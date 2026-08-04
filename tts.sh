#!/usr/bin/env zsh

# ==================================
# Text-to-Speech Script using Piper
# ==================================
#
# Description:
#   Converts text to speech using Piper TTS engine with support for
#   multiple voice models and customizable output settings
#
# Usage:
#   ./tts.sh [-m model] [-o output] [-s silence] "Your text here"
#   echo "Your text" | ./tts.sh [-m model] [-o output] [-s silence]
#   
# Options:
#   -m: Path to voice model (default: /usr/share/piper-voices/en_GB-alba-medium.onnx)
#   -o: Output WAV file (default: output.wav)
#   -s: Silence between sentences in seconds (default: 0.2)
#   -h: Show this help message
#
# Example:
#   ./tts.sh "Hello, world!"
#   ./tts.sh -m custom_model.onnx -o hello.wav "Hello, world!"
#   echo "Hello, world!" | ./tts.sh -o hello.wav
#
# Requirements:
#   - Piper TTS must be installed and in your PATH
#   - Voice model and config files must be present
#   - zsh shell environment
#
# Note: 
#   - Script will use default voice model if none specified
#   - Accepts input from both arguments and stdin
#   - Creates output directory if it doesn't exist
# ==================================

# Exit on error
set -e

# Default values
MODEL="/usr/share/piper-voices/en_GB-alba-medium.onnx"
OUTPUT="output.wav"
SILENCE=0.2

# Help function
show_help() {
    grep '^#' "$0" | grep -v '!/usr/bin/env' | sed 's/^#//'
    exit 0
}

# Process options
while getopts ":m:o:s:h" opt; do
    case ${opt} in
        m ) MODEL=$OPTARG ;;
        o ) OUTPUT=$OPTARG ;;
        s ) SILENCE=$OPTARG ;;
        h ) show_help ;;
        \? ) echo "Invalid option: -$OPTARG" 1>&2; exit 1 ;;
        : ) echo "Option -$OPTARG requires an argument" 1>&2; exit 1 ;;
    esac
done
shift $((OPTIND -1))

# Check if Piper or piperTTS is installed
PIPER_CMD=""
if command -v piper &> /dev/null; then
    PIPER_CMD="piper"
elif command -v piperTTS &> /dev/null; then
    PIPER_CMD="piperTTS"
else
    echo "Error: piper TTS is not installed or in PATH" 1>&2
    exit 1
fi

# Check if model exists
if [[ ! -f "$MODEL" ]]; then
    echo "Error: Model file not found: $MODEL" 1>&2
    exit 1
fi

# Create output directory if needed
OUTPUT_DIR=${OUTPUT:h}
if [[ ! -d "$OUTPUT_DIR" && "$OUTPUT_DIR" != "." ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Process input
if [[ $# -gt 0 ]]; then
    # Input from arguments
    echo "$*" | $PIPER_CMD \
        --model "$MODEL" \
        --output_file "$OUTPUT" \
        --sentence_silence "$SILENCE"
else
    # Input from stdin
    $PIPER_CMD \
        --model "$MODEL" \
        --output_file "$OUTPUT" \
        --sentence_silence "$SILENCE"
fi

# Check if ffmpeg is installed and convert to MP3 if possible
MP3_OUTPUT="${OUTPUT:r}.mp3"
if command -v ffmpeg &> /dev/null; then
    echo "Converting WAV to MP3..."
    ffmpeg -i "$OUTPUT" -codec:a libmp3lame -qscale:a 2 "$MP3_OUTPUT" -loglevel error && \
    rm "$OUTPUT" && \
    echo "Audio generated successfully: $MP3_OUTPUT"
else
    echo "Audio generated successfully: $OUTPUT"
    echo "Note: Install ffmpeg to automatically convert output to MP3 format"
    echo "      You can install it using your package manager:"
    echo "      - Ubuntu/Debian: sudo apt install ffmpeg"
    echo "      - macOS: brew install ffmpeg"
    echo "      - Arch Linux: sudo pacman -S ffmpeg"
    echo "      - Fedora: sudo dnf install ffmpeg"
fi
