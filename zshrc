# Set up the prompt

# autoload -Uz promptinit
# promptinit

setopt histignorealldups sharehistory

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit


### Added by Zplugin's installer
source '/home/perry/.zplugin/bin/zplugin.zsh'
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

zplugin load zdharma/history-search-multi-word
zplugin ice compile"*.lzui"
zplugin load zdharma/zui
zplugin ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zplugin light tj/git-extras

zplugin light zsh-users/zsh-autosuggestions
# Load the pure theme, with zsh-async that's bundled with it
zplugin ice pick"async.zsh" src"pure.zsh"; zplugin light sindresorhus/pure

# Load OMZ Git library
zplugin snippet OMZ::lib/git.zsh

zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
# Load Git plugin from OMZ
zplugin snippet OMZ::plugins/git/git.plugin.zsh
# zplugin snippet OMZ::plugins/virtualenv/virtualenv.plugin.zsh
# zplugin snippet OMZ::plugins/ruby/ruby.plugin.zsh
zplugin cdclear -q # <- forget completions provided up to this moment

########################################################################
# Stuff i have not time to figure out for zplugin..
# WARN: Must have dircolors defined before completion setting below
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

setopt promptsubst
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Load theme from OMZ
zplugin snippet OMZ::themes/dstufft.zsh-theme

# zplugin snippet OMZ::themes/bira.zsh-theme


if [ -r ~/.env ] ; then
    source ~/.env
fi
if [ -r ~/.alias ] ; then
    source ~/.alias
fi
if [ -r /usr/share/nvm/init-nvm.sh ] ; then
    source /usr/share/nvm/init-nvm.sh
fi
alias p="sudo pacman"
alias snap="sudo snap"
alias suspend="sudo systemctl suspend"
alias ls="ls --color"
alias less="less -R"
alias grep="grep --color=auto"
alias gst="git status"
alias tma="tmux attach || tmux"
# alias ca="conda deactivate && conda activate"

bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

#zle -N zle-line-init
#zle -N zle-keymap-select
export KEYTIMEOUT=1

# export GOROOT=
export GOPATH="$HOME/go"
PATH="${GOPATH}/bin:$PATH"
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"

export EDITOR="$(which nvim)"

# ole words. de# key bindings
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\ee[C" forward-word
bindkey "\ee[D" backward-word
bindkey "\^H" backward-delete-word
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
# completion in the middle of a line
bindkey '^i' expand-or-complete-prefix

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/perry/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
    # eval "$__conda_setup"
# else
    # if [ -f "/home/perry/anaconda3/etc/profile.d/conda.sh" ]; then
        # . "/home/perry/anaconda3/etc/profile.d/conda.sh"
    # else
        # export PATH="/home/perry/anaconda3/bin:$PATH"
    # fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/perry/google-cloud-sdk/path.zsh.inc' ]; then . '/home/perry/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/perry/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/perry/google-cloud-sdk/completion.zsh.inc'; fi

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# source ~/.fzf/shell/key-bindings.zsh
# source ~/.fzf/shell/completion.zsh
eval "$(fzf --zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

function zvm_after_init() {
    bindkey -r '^G'
    source fzf-git.sh
 }
source "$HOME/bin/fzf-git/fzf-git.sh"
