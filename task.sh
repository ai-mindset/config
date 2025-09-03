#!/bin/zsh
#
# Task Manager - A simple Markdown-based task management script
#
# This script allows you to manage tasks in a Markdown file with due dates,
# creation dates, and completion status. Tasks can be added, marked as complete,
# cancelled, and filtered by date.
#
# Usage: task.sh [command] [arguments]
#
# Author: Eirini w/ the help of Claude
# License: MIT


# Set task file location - default to $HOME/Documents/work_log.md
: ${TASK_FILE:="$HOME/Documents/work_log.md"}

# Original task() function - unchanged
task() {
  [[ -f "$TASK_FILE" ]] || touch "$TASK_FILE"
  echo "📝 SIMPLE TASK MANAGER 📝"
  echo "=========================="
  echo ""
  echo "Emoji Legend: 📅 = Due date   📋 = Creation date   ✅ = Completion date   ❌ = Cancellation date"
  echo ""

  case "$1" in
    add|a)
      shift
      # Check if next arg is a date
      local due_date=$(date -u +"%Y-%m-%d")
      if [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        due_date="$1"
        shift
      fi

      # Get task text
      local task_text="$*"
      if [[ -z "$task_text" ]]; then
        echo "Error: Task cannot be empty."
        return 1
      fi

      # Add task with labelled dates using emoji
      local timestamp=$(date -u +"%Y-%m-%d")
      echo "- [ ] 📅 $due_date 📋 $timestamp $task_text" >> "$TASK_FILE"
      echo "Added task due 📅 $due_date: $task_text"
      ;;

    today|t)
      local today=$(date -u +"%Y-%m-%d")
      echo "Tasks due today (📅 $today):"
      grep -F -- "- [ ] 📅 $today" "$TASK_FILE" | cat -n || echo "No tasks due today."
      ;;

    week|w)
      local today=$(date -u +"%Y-%m-%d")
      local week_later=$(date -u -v+7d +"%Y-%m-%d" 2>/dev/null || date -u -d "+7 days" +"%Y-%m-%d")
      echo "Tasks due in the next 7 days:"
      awk -v today="$today" -v week="$week_later" '$0 ~ /- \[ \]/ && $0 ~ /📅/ {
        split($0, a, "📅"); gsub(/^ */, "", a[2]); split(a[2], b, " ");
        if (b[1] >= today && b[1] <= week) print $0
      }' "$TASK_FILE" | cat -n || echo "No tasks due this week."
      ;;

    lastweek|lw)
      local weeks=${2:-1}
      local days=$((weeks * 7))
      local today=$(date -u +"%Y-%m-%d")
      local weeks_ago=$(date -u -v-${days}d +"%Y-%m-%d" 2>/dev/null || date -u -d "-${days} days" +"%Y-%m-%d")
      echo "Tasks completed in the last ${weeks} week(s):"
      awk -v start="$weeks_ago" -v end="$today" '$0 ~ /- \[x\]/ && $0 ~ /✅/ {
        split($0, a, "✅"); gsub(/^ */, "", a[2]); split(a[2], b, " ");
        if (b[1] >= start && b[1] <= end) print $0
      }' "$TASK_FILE" | cat -n || echo "No tasks completed in the last ${weeks} week(s)."
      ;;

    pending|p)
      echo "Pending tasks:"
      local pending_tasks=$(grep -n -F -- "- [ ]" "$TASK_FILE")

      if [[ -z "$pending_tasks" ]]; then
        echo "No pending tasks."
      else
        echo "$pending_tasks" | cat -n | sed 's/^\s*\([0-9]*\)\s*\([0-9]*\):/\1 -/'
      fi
      ;;

      # We don't remove the file here as it's needed by done/cancel commands
      # File will be automatically cleaned up on system reboot
      # A trap would be ideal but could interfere with user's existing traps

    done|d)
      if [[ "$2" =~ ^[0-9]+$ ]]; then
        local task_num=$2

        # Get the Nth pending task directly
        local line_info=$(grep -n -F -- "- [ ]" "$TASK_FILE" | sed -n "${task_num}p")

        if [[ -z "$line_info" ]]; then
          echo "Error: Task number out of range. Run 'task pending' to see available tasks."
          return 1
        fi

        # Extract the actual line number in the task file
        local file_line_num=$(echo "$line_info" | cut -d':' -f1)

        # Mark as completed with date
        local completion_date=$(date -u +"%Y-%m-%d")
        sed -i "${file_line_num}s/- \\[ \\]/- \\[x\\] ✅ $completion_date/" "$TASK_FILE"
        echo "Task $task_num marked as completed"
      else
        # List completed tasks
        echo "Completed tasks:"
        grep -F -- "- [x]" "$TASK_FILE" | cat -n || echo "No completed tasks."
      fi
      ;;

    cancel|c)
      if [[ "$2" =~ ^[0-9]+$ ]]; then
        local task_num=$2

        # Get the Nth pending task directly
        local line_info=$(grep -n -F -- "- [ ]" "$TASK_FILE" | sed -n "${task_num}p")

        if [[ -z "$line_info" ]]; then
          echo "Error: Task number out of range. Run 'task pending' to see available tasks."
          return 1
        fi

        # Extract the actual line number in the task file
        local file_line_num=$(echo "$line_info" | cut -d':' -f1)

        # Get the task line content
        local task_line=$(sed -n "${file_line_num}p" "$TASK_FILE")

        # Mark as cancelled with date and strikethrough
        local cancellation_date=$(date -u +"%Y-%m-%d")

        # Extract the parts of the line (date info and task text)
        local date_part=$(echo "$task_line" | grep -o "📅[^📋]*📋[^[:space:]]*")
        local task_text=$(echo "$task_line" | sed "s/- \\[ \\] $date_part //")

        # Create new line with cancellation format
        local new_line="- [-] ❌ $cancellation_date $date_part ~~$task_text~~"

        # Replace the line in the file
        sed -i "${file_line_num}s|.*|$new_line|" "$TASK_FILE"
        echo "Task $task_num marked as cancelled"
      else
        # List cancelled tasks
        echo "Cancelled tasks:"
        grep -F -- "- [-] ❌" "$TASK_FILE" | cat -n || echo "No cancelled tasks."
      fi
      ;;    all|list|l)
          # Only list all tasks when explicitly requested
          echo "All tasks:"
          cat -n "$TASK_FILE" || echo "No tasks found."
          ;;

    *)
      # Show help for no arguments or unknown commands
      [[ -z "$1" ]] || echo "Unknown command: $1"
      echo "Usage: task [command] [args]"
      echo "Commands:"
      echo "  add|a [date] <text>  Add a new task with optional due date (YYYY-MM-DD)"
      echo "  today|t              List tasks due today"
      echo "  week|w               List tasks due in the next 7 days"
      echo "  lastweek|lw [weeks]  List tasks completed in the last X weeks (default: 1)"
      echo "  pending|p            List all pending tasks"
      echo "  done|d [num]         Mark task as complete or list completed tasks"
      echo "  cancel|c [num]       Mark task as cancelled or list cancelled tasks"
      echo "  all|list|l           List all tasks"
      echo ""
      echo "Examples:"
      echo "  task add \"Buy groceries\"                 # Add task due today"
      echo "  task add 2025-09-15 \"Finish project\"     # Add task with due date"
      echo "  task pending                            # List pending tasks"
      echo "  task done 2                             # Mark task #2 as complete"
      ;;
  esac
}

# Execute task function with all passed arguments
# Add clean-up trap for temporary files
trap 'rm -f /tmp/task_pending_$$' EXIT INT TERM
task "$@"
