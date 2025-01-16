#!/usr/bin/env zsh

# Source: https://bashscript.net/bash-script-as-a-simple-to-do-list/

TODO_FILE="$HOME/todo.txt"

function show_help {
    echo "Usage: todo.sh [command] [task]"
    echo "Commands:"
    echo "  add [task]     Add a task"
    echo "  list           List all tasks"
    echo "  remove [task]  Remove a task"
}

function add_task {
    if [[ -z "$1" ]]; then
        echo "Error: Task cannot be empty."
        exit 1
    fi
    echo "$1" >> "$TODO_FILE"
    echo "Added task: $1"
}

function list_tasks {
    if [[ -s "$TODO_FILE" ]]; then
        echo "Your To-Do List:"
        cat "$TODO_FILE"
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

    # Escape task for `sed` to handle spaces and special characters.
    escaped_task=$(printf '%s\n' "$1" | sed 's/[]\/$*.^|[]/\\&/g')

    # Use `sed` to remove the exact matching line.
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
    *)
        show_help
        ;;
esac
