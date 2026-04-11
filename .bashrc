#░ █▄▄ ▄▀█ █▀ █░█ █▀█ █▀▀
#▄ █▄█ █▀█ ▄█ █▀█ █▀▄ █▄▄
# vim:fileencoding=utf-8:foldmethod=marker
# .bashrc - PhysicsBox

# Only run in interactive shells
case $- in
    *i*) ;;
    *) return ;;
esac

# ============================================================
# Environment
# ============================================================
export TERM="xterm-256color"
export EDITOR="vim"
export VISUAL="vim"
export BAT_THEME="zenburn"

# PATH additions
for dir in "$HOME/.bin" "$HOME/.local/bin" "/usr/local/sbin"; do
    [ -d "$dir" ] && PATH="$dir:$PATH"
done
mkdir -p "$HOME/.local/bin"

# Conda
source /opt/conda/etc/profile.d/conda.sh
conda activate physicsbox

# ============================================================
# History
# ============================================================
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTFILE=/workspace/.bash_history
export XDG_DATA_HOME=/workspace/.local

# ============================================================
# Shell options
# ============================================================
shopt -s autocd cdspell cmdhist histappend expand_aliases checkwinsize

# ============================================================
# Completion
# ============================================================
bind "set completion-ignore-case on"
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ============================================================
# Aliases
# ============================================================
[ -f ~/.aliases ] && source ~/.aliases

# bat - Debian ships it as batcat
command -v batcat &>/dev/null && alias bat='batcat'

alias ls='eza --icons'
alias ll='eza -lah --icons'
alias cat='batcat --paging=never'
alias notebook='jupyter lab --ip=0.0.0.0 --no-browser'

# ============================================================
# Prompt - shows conda env, user, host, path
# ============================================================
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
PS1='(${CONDA_DEFAULT_ENV}) \[\033[01;32m\]\u@physicsbox\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# ============================================================
# Functions
# ============================================================

# Make directory and cd into it
mkcd() {
    [[ -z "$1" ]] && echo "Usage: mkcd <dir>" && return 1
    mkdir -p "$1" && cd "$1"
}

# cd and list
cdls() {
    local dir="${1:-$HOME}"
    [[ -d "$dir" ]] && cd "$dir" && ls || echo "cdls: $dir: not found"
}

# Backup a file
bak() {
    [[ -z "$1" ]] && echo "Usage: bak <file>" && return 1
    cp "$1" "$1.bak" && echo "Backed up to $1.bak"
}

# Extract archives
ex() {
    [[ ! -f "$1" ]] && echo "'$1' is not a valid file" && return 1
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz|*.tar)   tar xf  "$1" ;;
        *.tar.zst)        unzstd  "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip  "$1" ;;
        *.zip)            unzip   "$1" ;;
        *.rar)            unrar x "$1" ;;
        *.7z)             7z x    "$1" ;;
        *)                echo "'$1' cannot be extracted via ex()" ;;
    esac
}

# ============================================================
# Local overrides - put personal aliases/settings here
# ============================================================
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
