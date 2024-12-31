#!/usr/bin/env zsh

# Usage: ./ocr.sh full/path/to/image.jpg

# From https://github.com/bytefer/ollama-ocr/blob/main/src/config.ts#L6C43-L11C68
SYSTEM="Act as an OCR assistant. Analyze the provided image and:
    1. Recognize all visible text in the image as accurately as possible.
    2. Maintain the original structure and formatting of the text.
    3. If any words or phrases are unclear, indicate this with [unclear] in your transcription.

    Provide only the transcription without any additional comments." 

echo "Using llama3.2-vision for OCR..."
ollama run llama3.2-vision:latest $SYSTEM "$1" > ~/transcript_ocr.txt
