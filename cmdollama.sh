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
shift
user_input=$(echo "$*" | jq -R -s '.')

json_payload="{\"model\":\"granite3.1-dense:8b\",\"prompt\":$user_input,\"system\":\"You are a world class expert in Unix commands, particularly ${command_type}. Generate only the raw command without any explanation or backticks. The command must be a single line without breaks. Be precise\"}"

response=$(curl -s "http://localhost:11434/api/generate" \
   -H "Content-Type: application/json" \
   -d "$json_payload")

command=$(echo "$response" | while read -r line; do
   echo "$line" | jq -r '.response // empty' 2>/dev/null
done | tr -d '\n')

[[ -z "$command" ]] && { print -P "%F{red}Error: No valid command generated.%f"; exit 1; }

print -P "%F{green}Generated command:%f $command"
read "?Press Enter to run the command, or Ctrl+C to cancel..."
eval "$command"
