#!/usr/bin/env zsh

# ==================================
# cmdollama - Local AI-Powered Unix Command Assistant
# ==================================
#
# Usage: ./cmdollama.sh "<command_type>" "<natural language description>"
# Example: ./cmdollama.sh find "find all jpg files modified in last 24 hours"
#
# Requirements:
#   - ollama server running on localhost:11434
#   - granite3.1-dense:8b model pulled
#   - jq installed
#   - relevant command installed
# ==================================

if [[ $# -lt 2 ]]; then
   echo "Usage: $0 <command_type> \"<description>\""
   echo "Example: $0 find \"find all jpg files modified in last 24 hours\""
   exit 1
fi

command_type=$1
command_help=$(${command_type} --help 2>&1 || ${command_type} -help 2>&1)
command_help=$(echo "$command_help" | jq -R -s '.')
shift
user_input=$(echo "$*" | jq -R -s '.')

# Create JSON payload using jq
json_payload=$(jq -n \
  --arg model "granite3.1-dense:8b" \
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

print -P "%F{green}Generated command:%f $command"
read "?Press Enter to run the command, or Ctrl+C to cancel..."
eval "$command"
