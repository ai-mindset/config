#!/usr/bin/env zsh

# Based on https://bashscript.net/bash-script-as-a-simple-to-do-list/

# ==================================
# Emoji To-Do List Manager
# ==================================
#
# Description:
#   Manages a markdown-based todo list with emoji indicators, timestamps,
#   and autocompletion support for zsh
#
# Usage:
#   ./todo.sh <command> [task]
#   
# Commands:
#   add [task]     Add a task (supports [TASK] and [IDEA] prefixes)
#   list           List all tasks
#   remove [task]  Remove a specific task
#   pending        List unfinished tasks (without ✅)
#   complete       List completed tasks (with ✅)
#
# Examples:
#   ./todo.sh add "Buy groceries"
#   ./todo.sh add "[TASK] Call dentist"
#   ./todo.sh add "[IDEA] Learn Python"
#
# Requirements:
#   - zsh shell environment
#   - write permissions in $HOME directory
#   - grep with regex support
#   - sed for text manipulation
#
# Special Features:
#   - Automatic tag conversion: [TASK] → ☐, [IDEA] → 💡
#   - UTC timestamps for all tasks (🗓️)
#   - zsh autocompletion support (--generate-completions)
#   - Tasks stored in ~/todo.md
#
# Note: 
#   - Run with --generate-completions to set up zsh autocompletion
#   - Task timestamps use UTC timezone
#   - Empty tasks are not allowed
# ==================================

# Generate autocompletions
if [[ "$1" == "--generate-completions" ]]; then
    completion_dir="${HOME}/.zsh"
    [[ -d "$completion_dir" ]] || mkdir -p "$completion_dir"
    
    cat > "${completion_dir}/_todo" <<EOF
#compdef todo.sh

function _todo {
    local commands
    commands=(
        'add:Add a task'
        'a:Add a task'
        'list:List all tasks'
        'l:List all tasks'
        'remove:Remove a task'
        'rm:Remove a task'
        'pending:List unfinished tasks'
        'p:List unfinished tasks'
        'complete:List completed tasks'
        'c:List completed tasks'
    )
    
    if (( CURRENT == 2 )); then
        _describe -t commands 'todo.sh commands' commands
    fi
}

_todo "\$@"
EOF
    echo "Completion file generated at ${completion_dir}/_todo"
    
    if ! grep -q "^fpath=(~/.zsh" "${HOME}/.zshrc"; then
        echo 'fpath=(~/.zsh $fpath)\nautoload -U compinit && compinit' >> "${HOME}/.zshrc"
    fi
    exit 0
fi

TODO_FILE="$HOME/todo.md"

function show_help {
    echo "Usage: todo.sh [command] [task]"
    echo "Commands:"
    echo "  add, a [task]      Add a task"
    echo "  list, l            List all tasks"
    echo "  remove, rm [task]  Remove a task"
    echo "  pending, p         List unfinished tasks"
    echo "  complete, c        List completed tasks"
}

function add_task {
    if [[ -z "$1" ]]; then
        echo "Error: Task cannot be empty."
        exit 1
    fi
    local task="$1"
    local timestamp=$(date -u +"%Y-%m-%d")
    
    # Replace tags with emojis
    case "$task" in
        "[TASK]"*)
            task="☐ ${task#[TASK]}"
            ;;
        "[IDEA]"*)
            task="💡 ${task#[IDEA]}"
            ;;
    esac
    
    echo "$task 🗓️ $timestamp" >> "$TODO_FILE"
    echo "Added task: $task"
}

function list_tasks {
    if [[ -s "$TODO_FILE" ]]; then
        echo "Your To-Do List:"
        cat "$TODO_FILE"
    else
        echo "No tasks found."
    fi
}

function pending_tasks {
    if [[ -s "$TODO_FILE" ]]; then
        echo "Pending Tasks:"
        grep -vE "✅|❌" "$TODO_FILE" || echo "No pending tasks."
    else
        echo "No tasks found."
    fi
}

function complete_tasks {
    if [[ -s "$TODO_FILE" ]]; then
        echo "Completed Tasks:"
        grep "✅" "$TODO_FILE" || echo "No completed tasks."
    else
        echo "No tasks found."
    fi
}

function remove_task {
    if [[ -z "$1" ]]; then
        echo "Error: Task to remove cannot be empty."
        exit 1
    fi

    if [[ ! -f "$TODO_FILE" ]]; then
        echo "No tasks found to remove."
        exit 1
    fi

    escaped_task=$(printf '%s\n' "$1" | sed 's/[]\/$*.^|[]/\\&/g')
   sed -i "s/^${escaped_task}$/❌ ~~${escaped_task}~~/" "$TODO_FILE"
    echo "Strike through task: $1"
}

case "$1" in
    add|a)
        add_task "$2"
        ;;
    list|l)
        list_tasks
        ;;
    remove|rm)
        remove_task "$2"
        ;;
    pending|p)
        pending_tasks
        ;;
    complete|c)
        complete_tasks
        ;;
    *)
        show_help
        ;;
esac
