#!/usr/bin/env zsh

# Based on https://bashscript.net/bash-script-as-a-simple-to-do-list/

# Generate completions
if [[ "$1" == "--generate-completions" ]]; then
    completion_dir="${HOME}/.zsh"
    
    # Create directories if they don't exist
    [[ -d "$completion_dir" ]] || mkdir -p "$completion_dir"
    
    cat > "${completion_dir}/_todo" <<EOF
#compdef todo.sh

_todo() {
    local -a commands
    commands=(
$(grep -A1 "case.*in" "$0" | grep -o '"[^"]*")' | sed 's/)//' | while read cmd; do
    [[ "$cmd" != "*" ]] && echo "        '$cmd:$(grep -A1 "^    $cmd)" "$0" | tail -n1 | cut -d'"' -f2)'"
done)
    )
    _describe 'command' commands
}

_todo "\$@"
EOF
    echo "Completion file generated at ${completion_dir}/_todo"
    
    # If fpath line isn't in .zshrc, add it
    if ! grep -q "^fpath=(~/.zsh .zshrc"; then
        echo -e "\nfpath=(~/.zsh \$fpath)\nautoload -U compinit && compinit" >> "${HOME}/.zshrc"
        echo "Added completion configuration to .zshrc. Please restart your shell or run 'source ~/.zshrc'"
    fi
    
    exit 0
fi

TODO_FILE="$HOME/todo.md"

function show_help {
    echo "Usage: todo.sh [command] [task]"
    echo "Commands:"
    echo "  add [task]     Add a task"
    echo "  list           List all tasks"
    echo "  remove [task]  Remove a task"
    echo "  pending        List unfinished tasks"
    echo "  complete       List completed tasks"
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
        grep -v "✅" "$TODO_FILE" || echo "No pending tasks."
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
    sed -i "/^${escaped_task}$/d" "$TODO_FILE"
    echo "Removed task: $1"
}

case "$1" in
    add)
        add_task "$2"
        ;;
    list)
        list_tasks
        ;;
    remove)
        remove_task "$2"
        ;;
    pending)
        pending_tasks
        ;;
    complete)
        complete_tasks
        ;;
    *)
        show_help
        ;;
esac
