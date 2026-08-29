# If you come from bash you might have to change your $PATH.
# export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Zsh speedup
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="simple" #"minimal"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate $HOME/.zshrc"
# alias ohmyzsh="mate $HOME/.oh-my-zsh"


# Load library path
LD_LIBRARY_PATH=/usr/local/lib

# AppImages
export PATH="$HOME/AppImages:$PATH"

# DuckDB
export PATH="$HOME/.duckdb/cli/latest:$PATH"

# Neovim
alias nvim="$HOME/AppImages/nvim-linux-x86_64/bin/nvim"

# System-wide editor
export EDITOR="nvim"

# Tmux
[[ -d "$HOME/.tmux" ]] || mkdir "$HOME/.tmux"
alias tmux='tmux -S "$HOME/.tmux/dev"'

## Show git status on ls
function ls {
  # If we’re inside a Git repository, show the short status first
  git rev-parse --is-inside-work-tree &>/dev/null && git status --short --branch
  # Run the real ls with whatever arguments were passed
  command ls "$@"
}
## /Show git status on ls

## log tasks - https://bsky.app/profile/chrisalbon.com/post/3ld24aoq4ik2p
# Define path to your log file
function log_task() {
    local TASK_FILE="$HOME/Documents/work_log.md"
    # Get current ISO 8601 timestamp
    local timestamp=$(date -u +"%Y-%m-%d")

    # Append timestamp and message to log file
    echo "$timestamp $*" >> "$TASK_FILE"

    # Confirm that task was added
    echo "Logged: $timestamp $*"
}
## /log tasks

## task 
task p
## /task

## poke
poke-sync() {
  local token
  if ! token="$(secret-tool lookup application poke host github.com)"; then
    print -u2 "Could not read the Poke GitHub PAT from Secret Service."
    return 1
  fi
  if [[ -z "$token" ]]; then
    print -u2 "No Poke GitHub PAT was found in Secret Service."
    return 1
  fi
  GITHUB_TOKEN="$token" command poke sync "$@"
}
## /poke

rm -f "$HOME/.zsh_history"
# $ crontab -e
# @daily name_of_script.sh

## List big packages
function list_big_packages() {
  if command -v dpkg-query >/dev/null 2>&1; then
    # Debian-based systems: size is in kilobytes, converting to MiB
    dpkg-query -Wf '${Installed-Size}\t${Package}\n' | \
      sort -n -r | \
      awk '{size_mib = $1/1024; printf (size_mib==int(size_mib) ? "%.0f MiB\t%s\n" : "%.1f MiB\t%s\n"), size_mib, $2}' | \
      head -n 20
  elif command -v rpm >/dev/null 2>&1; then
    # Fedora-based systems using rpm:
    # rpm returns package size in kilobytes (without decimal)
    rpm -qa --qf '%{size}\t%{name}\n' | \
      sort -n -r | \
      awk '{size_mib = $1/1024; printf (size_mib==int(size_mib) ? "%.0f MiB\t%s\n" : "%.1f MiB\t%s\n"), size_mib, $2}' | \
      head -n 20
  else
    echo "Neither dpkg-query nor rpm found. Unsupported system."
    return 1
  fi
}
## /List big packages

## Find and replace
function replace() {
  if [ "$#" -ne 2 ]; then
    printf "Usage: replace <search> <replace>\n"
    return 1
  fi
  local search=$1
  local replace=$2

  # GNU sed:
  find . -type f \
    -exec sed -i "s/${search}/${replace}/g" {} +

  # If you’re on macOS/BSD, use:
  # find . -type f \
  #   -exec sed -i '' "s/${search}/${replace}/g" {} +
}
## /Find and replace

## General aliases
alias font_recache="sudo fc-cache -f -v"
alias pip_rm_all="pip freeze | xargs pip uninstall -y"
alias url_IP="dig +trace"
alias my_IP="curl https://checkip.amazonaws.com"
alias gpg_verify="gpg --keyserver-options auto-key-retrieve --verify"
# https://unix.stackexchange.com/questions/144391/encrypting-and-compressing
alias 7z_withpasswd="7z a -p -mhe=on" #file.7z /dir/to/compress
#   		         ^  ^     ^      ^        ^
#  	                 |  |     |      |        `--- Files/directories to compress & encrypt.
#                    |  |     |      `--- Output filename
#                    |  |     `--- Encrypt filenames
#      		         |  `---- Use a password
alias cpu_freq="cpupower frequency-info | grep 'current CPU frequency:' "
alias grep="grep --after-context=1 --before-context=1"
alias dos_unix_convert="sed -i -e 's/\r$//' "
alias weather="curl https://wttr.in/"
alias apt_upd="sudo apt update && sudo apt upgrade && sudo apt autoremove --purge && sudo apt autoclean" # Update OS packages
vid_total_dur_hrs() {
    find . -maxdepth 1 -exec ffprobe -v quiet -of csv=p=0 -show_entries format=duration {} \; |
        awk '{s+=$0} END {print s/3600}'
}
alias c="xclip -selection clipboard"
alias rm_docker_installation="sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine"
alias docker="podman"
alias podman_stop_all='for id in $(podman ps -q); do echo "Stopping container: $id"; podman stop $id; done; echo "All containers have been stopped."'
alias podman_rmc="podman rm -f $(podman ps -aq)"
alias podman_rmi="podman rmi $(podman images -aq)"
alias podman_prune="podman system prune -af --volumes"
alias podman_build_run="podman_prune && podman build -t my-container . && podman run -it my-container"
alias grep="grep --color=auto"
alias dropcache='sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"' # Free up memory by dropping caches. Use with caution, as it can impact performance temporarily.
## /General aliases

## yt-dlp
_ytdlp() {
  local deno_bin="${commands[deno]:-$HOME/.deno/bin/deno}"

  if [[ ! -x "$deno_bin" ]]; then
    print -u2 "yt-dlp: Deno was not found"
    return 1
  fi

  command yt-dlp --js-runtimes "deno:$deno_bin" "$@"
}

yt-dlp_mp3() {
  _ytdlp -x --audio-format mp3 "$@"
}

# This is approximately yt-dlp's default format selection.
yt-dlp_best_format() {
  _ytdlp -f 'bv*+ba/b' "$@"
}

yt-dlp_subs() {
  _ytdlp \
    --skip-download \
    --write-subs \
    --write-auto-subs \
    --sub-langs 'en.*' \
    --sub-format 'srt/best' \
    --convert-subs srt \
    "$@"
}

yt-dlp_multi_subs() {
  local file stem youtube_id

  while IFS= read -r -d '' file; do
    stem="${file:t:r}"
    youtube_id="$(
      print -r -- "$stem" |
        sed -nE 's/.*\[([A-Za-z0-9_-]{11})\]$/\1/p'
    )"

    if [[ -n "$youtube_id" ]]; then
      yt-dlp_subs "https://youtu.be/$youtube_id"
    else
      print -u2 "yt-dlp_multi_subs: no trailing YouTube ID: $file"
    fi
  done < <(find . -type f -iname '*.mp4' -print0)
}

yt-dlp_mp4() {
  if (( $# == 0 )); then
    print -u2 "Usage: yt-dlp_mp4 [yt-dlp options] <URL>"
    return 2
  fi

  _ytdlp -t mp4 "$@"
}

srt-to-text() {
  if (( $# == 0 )); then
    print -u2 "Usage: srt-to-text FILE.srt [...]"
    return 2
  fi

  local input output

  for input in "$@"; do
    output="${input:r}.txt"

    sed -E \
      -e '/^[0-9]+$/d' \
      -e '/^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> /d' \
      -e 's/<[^>]*>//g' \
      -e '/^[[:space:]]*$/d' \
      -- "$input" > "$output"

    print -r -- "$output"
  done
}
## /yt-dlp

## PiperTTS
export PATH="$HOME/AppImages/piper:$PATH"
alias piper="piper-tts --model /usr/share/piper-voices/en_GB-alba-medium.onnx"
## /PiperTTS

## Convert .epub to .md
function epub2md() {
  local input="$1"
  local output="${2:-${input%.*}.md}"
  pandoc -f epub -t html "$input" | lynx -dump -stdin -nomargins -width=1000 > "$output"
}
# Add completion definition
function _epub2md() {
  _arguments '1:epub file:_files -g "*.epub"' '2:output file:_files'
}
compdef _epub2md epub2md
## /Convert .epub to .md

## Python
# uv uvx
export PATH="$HOME/.local/bin:$PATH"
# Fix completions for uv run https://github.com/astral-sh/uv/issues/8432#issuecomment-2867318195
function _uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

# Clear __pycache__
function clear_pycache() {
  local target_dir="${1:-.}"
  find "$target_dir" -type d -name "__pycache__" -print -exec rm -rf {} \; 2>/dev/null
  echo "Cleaned __pycache__ directories from $target_dir"
}

# Source .venv to prevent installing packages globally
source "$HOME/.venv/bin/activate"
# Maintain PATH after venv activation
function activate-venv() {
  local _OLD_PATH="$PATH"
  # first argument = path to your venv folder
  source "$1/bin/activate"
  # now force-restore the rest of the PATH
  export PATH="$VIRTUAL_ENV/bin:$_OLD_PATH"
}

# Autoload .venv when it exists in dir. Deactivate when navigating out of dir
function python_venv() {
    local MYVENV="./.venv"

    # If .venv exists in this directory
    if [[ -d $MYVENV ]]; then
        # Get absolute path to this directory's .venv
        local THIS_VENV="$(cd "$MYVENV" && pwd)"

        # If no venv is active or a different one is active
        if [[ -z "$VIRTUAL_ENV" || "$VIRTUAL_ENV" != "$THIS_VENV" ]]; then
            # Deactivate any existing venv
            [[ -n "$VIRTUAL_ENV" ]] && deactivate > /dev/null 2>&1
            # Activate this one
            source $MYVENV/bin/activate > /dev/null 2>&1
        fi
    # If no .venv exists and a venv is active, deactivate it
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate > /dev/null 2>&1
    fi
}

# Add to the chpwd hook to run whenever directory changes
autoload -Uz add-zsh-hook
add-zsh-hook chpwd python_venv

# Run once at shell startup to handle the initial directory
python_venv
## /Python

## Deno 
export PATH="$HOME/.deno/bin:$PATH"
export DENO_NO_TELEMETRY=1
## /Deno

## asdf version manager
export ASDF_DIR="$HOME/.asdf"
export PATH="$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH"
## /asdf version manager

## Elixir 
alias burrito='mix deps.get && MIX_ENV=prod mix release $1 --overwrite'
## /Elixir

## SBCL
alias sbcl="rlwrap -r sbcl"
## /SBCL

## OpenCode
# --- server management ---
tunnel_up()   { ssh -fN server && echo "tunnel up"; }
tunnel_down() { pkill -f 'ssh -fN server' && echo "tunnel down" || echo "no tunnel"; }
opencode_ollama() { tunnel_up && opencode }
hermes() { podman run -it --rm --network=host --userns=keep-id:uid=10000,gid=10000 -v "$HOME/.hermes:/opt/data:z" nousresearch/hermes-agent "$@" } # Pass through any arguments so you can do hermes setup model et
server_sleep() { systemctl suspend && echo "server suspended"; }
ollama_self_update() { # Update the Ollama binary itself (Linux & macOS)
  if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl is not installed – cannot download the updater"
    return 1
  fi
  echo "⬇️  Downloading and installing the latest Ollama release…"
  curl -fsSL https://ollama.com/install.sh | sh
}
ollama_clean() { sudo find /usr/share/ollama/.ollama/models/blobs -name "*-partial" -delete -print }
# Ollama model list with descriptions
ollama_list() {
    if ! command -v ollama &>/dev/null; then
        echo "ollama is not installed."
        return 1
    fi

    local cache_file="$HOME/.ollama_descriptions.cache"
    local cache_max_age=$((7 * 24 * 60 * 60))

    # Refresh if cache missing or stale
    local needs_refresh=0
    if [[ ! -f "$cache_file" ]]; then
        needs_refresh=1
    else
        local now=$(date +%s)
        local mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file")
        (( now - mtime > cache_max_age )) && needs_refresh=1
    fi

    if (( needs_refresh )); then
        echo "Refreshing model descriptions..."
        local tmpfile=$(mktemp)
        ollama list | tail -n +2 | awk '{print $1}' | while read -r model; do
            local base="${model%%:*}"
            local desc=$(curl -s "https://ollama.com/library/$base" \
                | grep -oP '(?<=<meta name="description" content=")[^"]+' \
                | head -1)
            [[ -z "$desc" ]] && desc="No description available"
            echo "${model}|${desc}" >> "$tmpfile"
        done
        mv "$tmpfile" "$cache_file"
    fi

    printf "%-40s %s\n" "MODEL" "DESCRIPTION"
    printf "%-40s %s\n" "-----" "-----------"
    while IFS='|' read -r model desc; do
        printf "%-40s %s\n" "$model" "$desc"
    done < "$cache_file"
}
# --- /server management ---

export PATH="$HOME/.opencode/bin:$PATH"
# If opencode is not installed
if ! command -v opencode &>/dev/null; then
    echo 'OpenCode is not installed. Please install it by running `curl -fsSL https://opencode.ai/install | bash`'
fi

clear_opencode_cache() {
    rm -rf "$HOME/.cache/opencode/"*
    echo "OpenCode cache cleared."
}
clear_opencode_history() {
    rm -rf "$HOME/.local/share/opencode/"{storage,tool-output,log,snapshot}/*
    rm -rf "$HOME/.local/share/opencode/opencode.db"*
    rm -rf "$HOME/.local/state/opencode/"*
    echo "OpenCode history cleared."
}
clear_opencode() {
    clear_opencode_cache
    clear_opencode_history
}
## /OpenCode

## Claude Code
# # If Claude Code is not installed
# if ! command -v claude &>/dev/null; then
#     echo 'Claude Code is not installed. Please install it by running `curl -fsSL https://claude.ai/install.sh | bash`'
# fi

# https://support.anthropic.com/en/articles/11940350-claude-code-model-configuration
# export SONNET_5="claude-sonnet-5"
# export OPUS_4_8=claude-opus-4-8
# alias claude5="claude --model $SONNET_5"
# https://code.claude.com/docs/en/settings#environment-variables
export DISABLE_AUTOUPDATER=1
export DISABLE_BUG_COMMAND=1 
export DISABLE_ERROR_REPORTING=1  
export DISABLE_TELEMETRY=1
## /Claude Code

## Codex
 # If Codex is not installed
 if ! command -v codex &>/dev/null; then
     echo 'Codex is not installed. Please install it by running `curl -fsSL https://chatgpt.com/codex/install.sh | sh`'
 fi
## /Codex

## Node Version Manager
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
## /Node Version Manager

## Azure products
# https://github.com/Azure/azure-functions-core-tools?tab=readme-ov-file#telemetry
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
# https://github.com/Azure/azure-cli?tab=readme-ov-file#telemetry-configuration
az config set core.collect_telemetry=no --only-show-errors

# --- Azure Function App helpers ---

# Show Function App details
azfn-show() {
  local app=$1 rg=$2
  az functionapp show --name "$app" --resource-group "$rg"
}

# List Function Apps in a resource group
azfn-list() {
  local rg=$1
  az functionapp list --resource-group "$rg" --query "[].name" -o tsv
}

# List functions in an app
azfn-funcs() {
  local app=$1 rg=$2
  az functionapp function list --name "$app" --resource-group "$rg" --query "[].name" -o tsv
}

# Get function key (default)
azfn-key() {
  local app=$1 rg=$2 func=$3
  az functionapp function keys list --name "$app" --resource-group "$rg" --function-name "$func" --query default -o tsv
}

# Set app settings from env var pairs
azfn-settings() {
  local app=$1 rg=$2; shift 2
  az functionapp config appsettings set --name "$app" --resource-group "$rg" --settings "$@"
}

# Restart app
azfn-restart() {
  local app=$1 rg=$2
  az webapp restart --name "$app" --resource-group "$rg"
}

# Enable SCM basic auth
azfn-enable-scm() {
  local app=$1 rg=$2
  local id=$(az functionapp show --name "$app" --resource-group "$rg" --query id -o tsv)
  az resource update --ids "${id}/basicPublishingCredentialsPolicies/scm" --set properties.allow=true
  az resource update --ids "${id}/basicPublishingCredentialsPolicies/ftp" --set properties.allow=true
}

# Deploy zip to Function App (Flex Consumption)
azfn-deploy() {
  local app=$1 rg=$2 zip=$3
  az functionapp deploy --resource-group "$rg" --name "$app" --src-path "$zip" --type zip
}

# Show my role assignments
az-roles() {
  local role_filter="" email_filter=""
  local restricted=false
  local -a restricted_roles=(
    "Reader"
    "Monitoring Reader"
    "Security Reader"
    "Cost Management Reader"
    "Storage Blob Data Reader"
    "Azure Kubernetes Service Cluster User Role"
  )

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -r|--role)
        role_filter="$2"
        shift 2
        ;;
      -e|--email)
        email_filter="$2"
        shift 2
        ;;
      --restricted)
        restricted=true
        shift
        ;;
      -h|--help)
        cat <<'HELP'
Usage: az-roles [-r ROLE] [-e EMAIL] [--restricted]

Options:
  -r, --role ROLE       Filter by role definition name (e.g. Owner, Contributor)
  -e, --email EMAIL     Filter by principal name/email substring
      --restricted      Show only common read-only / limited-access roles
  -h, --help            Show this help
HELP
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  if [[ -n "$role_filter" && "$restricted" == true ]]; then
    echo "Error: --restricted cannot be combined with --role" >&2
    return 1
  fi

  local -a conditions=()
  [[ -n "$role_filter" ]] && conditions+=("roleDefinitionName=='${role_filter}'")
  [[ -n "$email_filter" ]] && conditions+=("contains(principalName,'${email_filter}')")

  if [[ "$restricted" == true ]]; then
    local role_cond="" sep=""
    for r in "${restricted_roles[@]}"; do
      role_cond+="${sep}roleDefinitionName=='${r}'"
      sep=" || "
    done
    conditions+=("(${role_cond})")
  fi

  local query="["
  (( ${#conditions} > 0 )) && query+="?${(j: && :)conditions}"
  query+="].{Role:roleDefinitionName, Principal:principalName, Scope:scope}"

  az role assignment list --all --query "$query" -o table
}

# Show recent activity log for a resource group
az-logs() {
  local rg=$1
  az monitor activity-log list --resource-group "$rg" --query "[].{Operation:operationName.value, Status:status.value, Time:eventTimestamp}" -o table
}

# --- /Azure Function App helpers ---
## /Azure products

## Completion
fpath=("$HOME/.zsh/completion" $fpath)
# Zsh speedup - Smarter completion initialization
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' "$HOME/.zcompdump" 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi
# Complete external git-* subcommands
zstyle ':completion:*:*:git:*' user-commands ${${(k)commands[(I)git-*]}#git-}
## /Completion
