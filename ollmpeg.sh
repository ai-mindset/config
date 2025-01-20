#!/usr/bin/env zsh

# ==================================
# oollmpeg - Local AI-Powered FFmpeg Assistant
# ==================================
#
# Description:
#   Uses LLM to generate and execute FFmpeg commands from natural language 
#   descriptions using the granite3.1-dense model
#
# Usage:
#   ./ollmpeg.sh "<natural language description>"
#   
# Example:
#   ./ollmpeg.sh "remove audio from video.mp4"
#   ./ollmpeg.sh "compress my_video.mov to 720p"
#
# Requirements:
#   - ollama server running on localhost:11434
#   - granite3.1-dense:8b model pulled in ollama
#   - ffmpeg installed and in your PATH
#   - jq command line tool installed
#   - zsh shell environment
#
# Note: 
#   - Displays generated ffmpeg command before execution
#   - Requires user confirmation before running command
#   - Preserves exact filenames from input
#   - Adds quiet mode (-v quiet -stats) to ffmpeg output
#   - Script will exit if no input prompt is provided
# ==================================

# Check if user input is provided
if [[ -z "$*" ]]; then
    echo "Requires a prompt of what you want to do, i.e."
    echo "\"ollmpeg.sh remove audio from example.mov\""
    exit 1
fi

# Properly escape the input for JSON while preserving the exact filename
user_input=$(echo "$*" | jq -R -s '.')

# Create properly formatted JSON payload
json_payload="{\"model\":\"granite3.1-dense:8b\",\"prompt\":$user_input,\"system\":\"You are a world class expert in ffmpeg. Your job is to write correct and valid ffmpeg commands that do exactly what the user description asks for. You should only respond with a command line command for ffmpeg, never any additional text. All responses should be a single line without any line breaks. Do not modify filenames.\"}"

# Get Ollama response
response=$(curl -s "http://localhost:11434/api/generate" \
    -H "Content-Type: application/json" \
    -d "$json_payload")

# Extract and clean command - remove backticks and preserve exact filename
command=$(echo "$response" | while read -r line; do
    echo "$line" | jq -r '.response // empty' 2>/dev/null
done | tr -d '\n' | sed "s/\`//g")

# Check if command is empty
if [[ -z "$command" ]]; then
    print -P "%F{red}Error: No valid command was generated.%f"
    exit 1
fi

print -P "%F{green}Generated command:%f $command"

read "?Press Enter to run the command, or Ctrl+C to cancel..."

modified_command=${command/ffmpeg/ffmpeg -v quiet -stats}
eval "$modified_command"
