# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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
ZSH_THEME="powerlevel10k/powerlevel10k" #"minimal"
# ZSH_THEME="powerlevel9k/powerlevel9k"
# POWERLEVEL9K_DISABLE_RPROMPT=true
# POWERLEVEL9K_PROMPT_ON_NEWLINE=true
# POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="> "
# POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""

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
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Load library path
LD_LIBRARY_PATH=/usr/local/lib

# Appimages
export PATH="$HOME/AppImages:$PATH"

# Neovim
export PATH="$HOME/AppImages/nvim-linux-x86_64/bin:$PATH"

# System-wide editor
export EDITOR="nvim"

# Tmux
[[ -d ~/.tmux ]] || mkdir ~/.tmux
alias tmux='tmux -S ~/.tmux/dev'

## Show git status on ls
function ls {
  # If we’re inside a Git repository, show the short status first
  git rev-parse --is-inside-work-tree &>/dev/null && git status --short --branch
  # Run the real ls with whatever arguments were passed
  command ls "$@"
}
## Show git status on ls

## log tasks - https://bsky.app/profile/chrisalbon.com/post/3ld24aoq4ik2p
# Define path to your log file
log_task() {
    local TASK_FILE="$HOME/Documents/work_log.md"
    # Get current ISO 8601 timestamp
    local timestamp=$(date -u +"%Y-%m-%d")

    # Append timestamp and message to log file
    echo "$timestamp $*" >> "$TASK_FILE"

    # Confirm that task was added
    echo "Logged: $timestamp $*"
}
## log tasks

rm -f ~/.zsh_history
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
## List big packages

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
## Find and replace

## General aliases
alias yt-dlp_mp3="yt-dlp -x --audio-format mp3"
alias yt-dlp_best_format="yt-dlp -f \" bv+ba/b \" "
# --list-subs: en        English vtt, srt, ttml, srv3, srv2, srv1, json3
alias yt-dlp_subs="yt-dlp --write-subs --write-auto-sub --skip-download --sub-format \"srt\" "
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
alias git_prune='git fetch -p && git branch -vv | grep ": gone]" | awk "{print \$1}" > /tmp/gone_branches && cat /tmp/gone_branches | { echo "Delete these local branches that no longer exist on remote? [y/N]"; cat; } && read -q "REPLY?Proceed? " && git branch -D $(cat /tmp/gone_branches)'
alias grep="grep --color=auto"
alias rm_pycache="find . -type d -name "__pycache__" -exec rm -r {} +"
## General aliases

## yt-dlp download multiple video subs
function yt-dlp_multi_subs() {
find . -type f -iname '*.mp4' | while read file; do
  youtube_id=$(basename "$file" .mp4 | grep -o '\[.*\]' | tr -d '[]')
  yt-dlp_subs "https://youtu.be/$youtube_id"
done
}
## yt-dlp download multiple video subs

## PiperTTS
PATH=$PATH:$HOME/AppImage/piper
export PATH
alias piper="piper-tts --model /usr/share/piper-voices/en_GB-alba-medium.onnx"
## PiperTTS

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
## Convert .epub to .md

## Python
# uv uvx
export PATH=$HOME/.local/bin:$PATH
# Fix completions for uv run https://github.com/astral-sh/uv/issues/8432#issuecomment-2867318195
function _uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

# Clean __pycache__
function clean_pycache() {
  local target_dir="${1:-.}"
  find "$target_dir" -type d -name "__pycache__" -print -exec rm -rf {} \; 2>/dev/null
  echo "Cleaned __pycache__ directories from $target_dir"
}

# Source .venv to prevent installing packages globally
source $HOME/.venv/bin/activate
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
## Python

## Deno
# if .deno exists, source the env file
[ -f "$HOME/.deno/env" ] && 
    . "$HOME/.deno/env"
## Deno

## Zig - https://ziglang.org/download/
export ZIG_HOME="$HOME/.zig"
export PATH="$ZIG_HOME:$PATH"
## Zig

## todo list
# Save in PATH, as `task`
if command -v glow &>/dev/null; then
    task pending | glow
else
    task pending
fi
## todo list

## Rust and Cargo
export PATH="$HOME/.cargo/bin:$PATH"
# If .cargo exists, source the env file
[ -f "$HOME/.cargo/env" ] && 
    . "$HOME/.cargo/env"
## Rust and Cargo

## Claude Code
# If Claude Code is not installed
if !command -v claude &>/dev/null; then
    echo "Claude Code is not installed. Please install it by running `curl -fsSL https://claude.ai/install.sh | bash`"
    exit 1
fi

# https://support.anthropic.com/en/articles/11940350-claude-code-model-configuration
# export ANTHROPIC_MODEL_3="claude-3-7-sonnet-20250219" # Model was probably sunset recently
export ANTHROPIC_MODEL_4="claude-sonnet-4-20250514"
alias claude4="claude --model $ANTHROPIC_MODEL_4"
## Claude Code

## Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
## Node Version Manager

## Azure products
# https://github.com/Azure/azure-functions-core-tools?tab=readme-ov-file#telemetry
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
# https://github.com/Azure/azure-cli?tab=readme-ov-file#telemetry-configuration
az config set core.collect_telemetry=no --only-show-errors
## Azure products

## Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
## Powerlevel10k

## Completion
fpath=(~/.zsh/completion $fpath)
# Zsh speedup - Smarter completion initialization
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi
# Load git completions for aliases
zstyle ':completion:*:*:git:*' user-commands ${${(k)commands[(I)git-*]}#git-}
## Completion
