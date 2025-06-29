#!/usr/bin/env zsh
# ==================================
# cmdollama - Local AI-Powered Unix Command Assistant
# ==================================

if [[ $# -lt 2 ]]; then
   print -P "Usage: %F{green}$(basename $0) <command_type> \"<description>\" [--model <model_name>]%f"
   print -P "Example: %F{green}$(basename $0) tar compress the directory 'Documents' to a tar.gz file --model qwen3:8b%f"
   exit 1
fi

command_type=$1
shift # Shift past command type

# Get command help
command_help=$(${command_type} --help 2>&1 || ${command_type} -help 2>&1)
command_help=$(echo "$command_help" | jq -R -s '.')

# Parse remaining arguments
model="qwen3:4b" # Default model
description=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)
            if [[ $# -gt 1 ]]; then
                model="$2"
                shift 2 # Skip the flag and its value
            else
                print -P "%F{red}Error: Missing value for --model flag%f"
                exit 1
            fi
            ;;
        *)
            # Append to description with spaces
            if [[ -z "$description" ]]; then
                description="$1"
            else
                description="$description $1"
            fi
            shift
            ;;
    esac
done

print -P "Using model %F{green}$model%f..."

# Verify the model is pulled
check_model=$(curl -s "http://localhost:11434/api/tags" | jq -r '.models[] | select(.name=="'"$model"'") | .name')
if [[ -z "$check_model" ]]; then
    print -P "%F{yellow}Warning: Model '$model' doesn't appear to be pulled. Attempting to pull...%f"
    curl -s "http://localhost:11434/api/pull" -d "{\"name\":\"$model\"}" > /dev/null
    # Continue regardless as the generate endpoint will pull if needed
fi

# Create JSON payload using jq
json_payload=$(jq -n \
  --arg model "$model" \
  --arg description "$description" \
  --arg command_type "$command_type" \
  --arg help "$command_help" \
  '{
    model: $model,
    prompt: $description,
    system: ("You are a world class expert in Unix commands, particularly \($command_type). Here is \($command_type)'\''s help message that you should use as your reference: \($help). Generate a command that follows closely the description provided. Print _only_ the raw command without any explanation or backticks. The command must be a single line without breaks. The output file _should not_ contain any file paths. It should be a correct file name separating words with underscores (some_name.extension) or spaces if the user requests them. Be precise"),
    temperature: 0.3,
    max_tokens: 150
  }')

response=$(curl -s "http://localhost:11434/api/generate" \
   -H "Content-Type: application/json" \
   -d "$json_payload")

# Check for connection error
if [[ $? -ne 0 ]]; then
    print -P "%F{red}Error: Could not connect to Ollama server at localhost:11434%f"
    exit 1
fi

# Process response
command=$(echo "$response" | grep -o '"response":"[^"]*"' | cut -d'"' -f4 | tr -d '\n')

# Debug
print -P "Response status: %F{blue}$(echo "$response" | grep -o '"done_reason":"[^"]*"')%f"

[[ -z "$command" ]] && { print -P "%F{red}Error: No valid command generated. Make sure model '$model' is pulled and Ollama server is running.%f"; exit 1; }

print -P "Generated command: %F{green}$command%f"
read "?Press Enter to run the command, or Ctrl+C to cancel..."
eval "$command"
