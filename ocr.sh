#!/usr/bin/env zsh

# ocr.sh - OCR tool using Ollama vision models
# Usage: ./ocr.sh [--model MODEL_NAME] IMAGE_PATH

# Default configuration
DEFAULT_MODEL="llama3.2-vision:latest"
MODEL=${DEFAULT_MODEL}

# From https://github.com/bytefer/ollama-ocr/blob/main/src/config.ts#L6C43-L11C68
SYSTEM="Act as an OCR assistant. Analyze the provided image and:
    1. Recognize all visible text in the image as accurately as possible.
    2. Maintain the original structure and formatting of the text.
    3. If any words or phrases are unclear, indicate this with [unclear] in your transcription.

    Provide only the transcription without any additional comments."

# Function to display usage information
usage() {
  cat << EOF
Usage: $(basename $0) [options] IMAGE_PATH

Options:
  --model MODEL_NAME    Specify the vision model to use (default: ${DEFAULT_MODEL})
  -h, --help            Display this help message and exit

Example:
  $(basename $0) image.jpg                        # Use default model
  $(basename $0) --model llava:latest image.jpg   # Use llava model
EOF
  exit ${1:-0}
}

# Function to check if Ollama is installed and running
check_ollama() {
  if ! command -v ollama >/dev/null 2>&1; then
    echo "Error: Ollama is not installed or not in PATH" >&2
    echo "Please install Ollama from https://ollama.com/" >&2
    exit 1
  fi

  # Basic check if Ollama server is responding
  if ! ollama list >/dev/null 2>&1; then
    echo "Error: Ollama server is not running or not responding" >&2
    echo "Please start the Ollama server before running this script" >&2
    exit 1
  fi
}

# Function to check if the model exists
check_model() {
  local model_name=$1
  if ! ollama list | grep -q "${model_name%%:*}"; then
    echo "Warning: Model '$model_name' not found in local Ollama models" >&2
    echo "Ollama will attempt to pull this model if it exists remotely" >&2
  fi
}

# Function to process the image
process_image() {
  local image_path=$1
  local model_name=$2
  
  # Check if file exists
  if [[ ! -f "$image_path" ]]; then
    echo "Error: Image file '$image_path' does not exist" >&2
    exit 1
  fi
  
  # Check if file is readable
  if [[ ! -r "$image_path" ]]; then
    echo "Error: Cannot read image file '$image_path'" >&2
    exit 1
  fi
  
  # Get absolute path to image
  local abs_path="$(cd "$(dirname "$image_path")" && pwd)/$(basename "$image_path")"
  
  # Generate output filename: preserve original name and add .txt extension
  local image_name=$(basename -- "$image_path")
  local output_file="${image_name%.*}.txt"
  
  echo "Using ${model_name} for OCR..."
  echo "Processing ${image_path}..."
  
  # Run the OCR process
  ollama run "${model_name}" "$SYSTEM" "$abs_path" > "$output_file"
  
  local exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    echo "OCR completed successfully. Text saved to: $output_file"
    return 0
  else
    echo "Error: OCR process failed with exit code $exit_code" >&2
    return $exit_code
  fi
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --model)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: --model requires a value" >&2
        usage 1
      fi
      MODEL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      usage 1
      ;;
    *)
      # First non-option argument is the image path
      IMAGE_PATH="$1"
      shift
      break
      ;;
  esac
done

# Additional positional arguments should not exist
if [[ $# -gt 0 ]]; then
  echo "Error: Unexpected additional arguments: $@" >&2
  usage 1
fi

# Check if image path is provided
if [[ -z "$IMAGE_PATH" ]]; then
  echo "Error: No image file specified" >&2
  usage 1
fi

# Main execution flow
check_ollama
check_model "$MODEL"
process_image "$IMAGE_PATH" "$MODEL"
