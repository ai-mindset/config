#!/bin/bash

if [ -f "$CLAUDE_PROJECT_DIR/AGENTS.md" ]; then
    CONTENT=$(cat "$CLAUDE_PROJECT_DIR/AGENTS.md")
    jq -n --arg content "$CONTENT" '{
        hookSpecificOutput: {
            hookEventName: "SessionStart",
            additionalContext: $content
        }
    }'
else
    exit 0
fi
