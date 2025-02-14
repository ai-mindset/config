#!/usr/bin/env zsh
# ==================================
# cmdollama - Local AI-Powered Unix Command Assistant
# ==================================
#
# Usage: ./cmdollama.sh "<command_type>" "<natural language description>" [--model <model_name>]
# Example: ./cmdollama.sh tar compress the directory 'Documents' to a tar.gz file --model qwq
# Default model is qwen2.5-coder:latest, can be overridden by --model flag.
#
# Requirements:
#   - ollama server running on localhost:11434
#   - qwen2.5-coder:14b-instruct-q4_K_M model pulled (can be replaced with another model)
#   - jq installed
#   - relevant command installed
# ==================================

if [[ $# -lt 2 ]]; then
   print -P "Usage: %F{green}$(basename $0) <command_type> \"<description>\" [--model <model_name>]%f"
   print -P "Example: %F{green}$(basename $0) tar compress the directory 'Documents' to a tar.gz file --model qwq%f"
   exit 1
fi

command_type=$1
command_help=$(${command_type} --help 2>&1 || ${command_type} -help 2>&1)
command_help=$(echo "$command_help" | jq -R -s '.')
shift 2 # Skip command type and model flag arguments
user_input=$(echo "$*" | jq -R -s '.')

# Check if model is provided
if [[ $1 == "--model" ]]; then
    model=$2
    shift 2 # Skip the model flag and value
else
    model="qwen2.5-coder:14b-instruct-q4_K_M" # Default model
fi
print -P "Using model %F{green}$model%f..."

# Create JSON payload using jq
json_payload=$(jq -n \
  --arg model "$model" \
  --arg prompt "$*" \
  --arg command_type "$command_type" \
  --arg help "$command_help" \
  '{
    model: $model,
    prompt: $prompt,
    system: ("You are a world class expert in Unix commands, particularly \($command_type). Here is \($command_type)'\''s help message that you should use as your reference: \($help). Generate a command based on the description provided. Print only the raw command without any explanation or backticks. The command must be a single line without breaks. Be precise")
  }')

response=$(curl -s "http://localhost:11434/api/generate" \
   -H "Content-Type: application/json" \
   -d "$json_payload")


command=$(echo "$response" | jq -r 'select(.response != null) | .response' | tr -d '\n')

[[ -z "$command" ]] && { print -P "%F{red}Error: No valid command generated.%f"; exit 1; }

print -P "Generated command: %F{green}$command%f"
read "?Press Enter to run the command, or Ctrl+C to cancel..."
eval "$command"
