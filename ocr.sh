#!/usr/bin/env zsh

# ==================================
# OCR Image Processing Script
# ==================================
#
# Description:
#   Performs Optical Character Recognition (OCR) on images using llama3.2-vision
#   model, maintaining original text structure and formatting
#
# Usage:
#   ./ocr.sh <image_file>
#   
# Example:
#   ./ocr.sh image.jpg
#   ./ocr.sh /path/to/image.jpg
#
# Requirements:
#   - ollama must be installed and in your PATH
#   - llama3.2-vision model must be pulled in ollama
#   - Input file must be a valid image file
#   - zsh shell environment
#
# Note: 
#   - Output will be a text file in the same directory as the input image
#   - Script will exit if no input file is provided
#   - Unclear text in the image will be marked with [unclear] in output
# ==================================

# Exit on error
set -e

# From https://github.com/bytefer/ollama-ocr/blob/main/src/config.ts#L6C43-L11C68
SYSTEM="Act as an OCR assistant. Analyze the provided image and:
    1. Recognize all visible text in the image as accurately as possible.
    2. Maintain the original structure and formatting of the text.
    3. If any words or phrases are unclear, indicate this with [unclear] in your transcription.

    Provide only the transcription without any additional comments." 

echo "Using llama3.2-vision for OCR..."
IMAGE_NAME=$(basename -- "$1") # Extract image name excluding the full path and extension
CWD=$(pwd)

ollama run llama3.2-vision:latest $SYSTEM "$CWD/$1" > "$CWD/$IMAGE_NAME.txt" 
