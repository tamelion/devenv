#
# Environment variables
#

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

# Editors
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Less (disable history)
export PAGER='less'
export LESSHISTFILE=-

# FZF (use ripgrep)
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Composer
export COMPOSER_HOME="$XDG_CONFIG_HOME"/composer
export COMPOSER_CACHE_DIR="$XDG_CACHE_HOME"/composer

# Development
export NODE_ENV=dev

#
# Paths
#
path=(
$HOME/.local/bin
$HOME/.cargo/bin
/usr/local/bin
$path
)

# Ensure unique paths in array
typeset -gU cdpath fpath mailpath path

#
# History, completion, aliases
#

# Write history when term exits, remove duplicates
setopt append_history hist_ignore_all_dups
HISTFILE="$XDG_DATA_HOME"/zsh/history
HISTSIZE=1000
SAVEHIST=1000

# Complete with menu
zstyle ':completion:*' menu select

# custom aliases
[[ -f "$XDG_CONFIG_HOME/zsh/.alias" ]] && source "$XDG_CONFIG_HOME/zsh/.alias"
# fuzzy find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# asdf
[ -f $ASDF_DIR/asdf.sh ] && source $ASDF_DIR/asdf.sh
[ -f $ASDF_DIR/completions/asdf.bash ] && source $ASDF_DIR/completions/asdf.bash

#
# Zplug
#
if [[ -s "$ZPLUG_HOME" ]]; then
    # init
    source $ZPLUG_HOME/init.zsh

    # theme
    zplug "denysdovhan/spaceship-zsh-theme", as:theme
    SPACESHIP_VI_MODE_SHOW=false

    # more commands for git
    zplug "unixorn/git-extra-commands"

    # bookmarks
    zplug "urbainvaes/fzf-marks"

    # bd to go back up to a dir
    zplug "Tarrasch/zsh-bd"

    # syntax highlighting and history come last
    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    zplug "zsh-users/zsh-history-substring-search", defer:3

    # history substring settings
    zmodload zsh/terminfo
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down

    # Check for plugins which need installing
    if ! zplug check --verbose; then
        echo; zplug install
    fi

    # Source plugins and add commands to $PATH
    zplug load
fi
