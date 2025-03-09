# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="simple" #"minimal"
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
plugins=(gitfast colored-man-pages asdf golang) # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins

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

# Source .venv to prevent installing packages globally
source $HOME/.venv/bin/activate

# Load library path
LD_LIBRARY_PATH=/usr/local/lib

# Appimages
export PATH="$HOME/AppImages:$PATH"

# Tmux
[[ -d ~/.tmux ]] || mkdir ~/.tmux
alias tmux='tmux -S ~/.tmux/dev'

# System-wide editor
export EDITOR="nvim"

## log tasks - https://bsky.app/profile/chrisalbon.com/post/3ld24aoq4ik2p
log_task() {
   # Define path to your log file
    local log_file="$HOME/Documents/work_log.txt"

   # Get current ISO 8601 timestamp
   local timestamp=$(date -u +"%Y-%m-%d")

    # Append timestamp and message to log file
    echo "$timestamp $*" >> "$log_file"

    # Confirm that task was added
    echo "Logged: $timestamp $*"
}
## log tasks

## Julia
# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!
path=($HOME'/.juliaup/bin' $path)
export PATH
# <<< juliaup initialize <<<
export JULIA_NUM_THREADS=6 # $ julia --proj --threads auto 
                           #   julia> using Base.Threads
                           #   julia> nthreads()
                           #   8
                           # [ Info: For best performance, `JULIA_NUM_THREADS` (8) should be less than number of CPU threads (8).
## Julia

## MongoDB
export MONGODB_LIB="/var/lib/mongodb"
export MONGODB_LOG="/var/log/mongodb"
alias mongo_before_start_if_error="sudo systemctl daemon-reload"
alias mongo_start="sudo systemctl start mongod"
alias mongo_restart="sudo systemctl restart mongod"
alias mongo_verify_up="sudo systemctl status mongod"
alias mongo_stop="sudo service mongod stop"
alias mongo_start_after_sys_reboot="sudo systemctl enable mongod"
alias mongo_compass_download="curl -O https://downloads.mongodb.com/compass/mongodb-compass_1.42.2_amd64.deb ~/Downloads"
export CONNECTION_STRING_MONGODB="mongodb://127.0.0.1:27017"
## MongoDB

## asdf > v0.16
export PATH=$HOME/.asdf/bin:$PATH
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)  # append completions to fpath
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"  # asdf-erlang https://github.com/asdf-vm/asdf-erlang
## asdf > v0.16


rm -f ~/.zsh_history
# $ crontab -e
# @daily name_of_script.sh

## Ollama
export OLLAMA_MODELS="/usr/share/ollama/.ollama/models"

function update_ollama_fortnightly() {
    local last_run_file="$HOME/.last_fortnightly_run"
    local current_time=$(date +%s)
    local two_weeks=1209600  # seconds in 2 weeks

    # Create the file if it doesn't exist
    if [[ ! -f $last_run_file ]]; then
        echo "0" > "$last_run_file"
    fi

    local last_run=$(cat "$last_run_file")
    local time_diff=$((current_time - last_run))

    if [[ $time_diff -ge $two_weeks ]]; then
        echo "Running ollama script..."
        curl -fsSL https://ollama.com/install.sh | sh
        
        # Update the last run time
        echo "$current_time" > "$last_run_file"
    fi
}
#
update_ollama_fortnightly
## Ollama

## General aliases
alias yt-dlp_mp3="yt-dlp -x --audio-format mp3"
alias yt-dlp_best_format="yt-dlp -f \" bv+ba/b \" "
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
alias podman_stop_all='for id in $(podman ps -q); do echo "Stopping container: $id"; podman stop $id; done; echo "All containers have been stopped."'
alias podman_rmc="podman rm -f $(podman ps -aq)"
alias podman_rmi="podman rmi $(podman images -aq)"
alias podman_prune="podman system prune -af --volumes"
alias git_prune='git fetch -p && git branch -vv | grep ": gone]" | awk "{print \$1}" | { branches=$(cat); echo "Delete these local branches that no longer exist on remote? [y/N]"; echo "$branches"; } | xargs -p git branch -D'
alias grep="grep --color=auto"
alias rm_pycache="find . -type d -name "__pycache__" -exec rm -r {} +"
## General aliases

## Convert .epub to .md 
epub2md() {
  local input="$1"
  local output="${2:-${input%.*}.md}"
  pandoc -f epub -t html "$input" | lynx -dump -stdin -nomargins -width=1000 > "$output"
}
# Add completion definition
_epub2md() {
  _arguments '1:epub file:_files -g "*.epub"' '2:output file:_files'
}
compdef _epub2md epub2md
## Convert .epub to .md

## Deno
fpath=(~/.zsh $fpath)
autoload -U compinit && compinit
. "$HOME/.deno/env"
## Deno

## The following lines were added by compinstall
zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit
## End of lines added by compinstall

# uv uvx
export PATH=$HOME/.local/bin:$PATH

## Golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
## Golang

## Clojure installation path
export PATH=$HOME/.clojure/bin:$PATH
alias clj_rebel="clj -M:repl"
export TERM=xterm-256color # For Tmux to show correct colours
## Clojure installation path

# Print todo list
if command -v glow &>/dev/null; then
  todo.sh pending | glow
else
  todo.sh pending
fi
