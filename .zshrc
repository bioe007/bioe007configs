
if [ -z "$(echo $PATH | grep perry)" ] ; then
    export PATH="$HOME/.bin:/usr/local/bin:/opt/java/bin:/opt/mozilla/bin:${PATH}"
    export AWT_TOOLKIT=MToolkit
    export OOO_FORCE_DESKTOP=gnome
    export INTEL_BATCH=2
    export MOZILLA_FIVE_HOME="/usr/lib/xulrunner-1.9.1"
    export GEM_PATH='/.gem/ruby/1.9.1/gems/'
fi

if [ -r "$HOME/.var/dbus_session_bus_address" ] ; then
    . "$HOME/.var/dbus_session_bus_address"
fi

# {{{ History

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# }}}


# {{{ Variables
SANDBOX=${HOME}/sandbox

# this fixes troubles with glibc and malloc debugging
# 0 = Do not generate an error message, and do not kill the program
# 1 = Generate an error message, but do not kill the program
# 2 = Do not generate an error message, but kill the program
# 3 = Generate an error message and kill the program
MALLOC_CHECK_="0"

# compiling
CFLAGS="-march=prescott -O2 -pipe -fomit-frame-pointer -mfpmath=sse -msse3"
CHOST="i686-pc-linux-gnu"
CXXFLAGS="${CFLAGS} -fvisibility-inlines-hidden"

# for CVS
CVS_RSH=ssh
CVSROOT=":ext:phargrave@10.1.1.16:/srv/Engineering/ph1000/cvs_root_bcsi"
CVSEDITOR="/usr/bin/vim"
EDITOR="/usr/bin/vim"

# required for tasking compiler
LM_LICENSE_FILE=/home/perry/.wine/drive_c/cc51/license.dat
CC51INC=/home/perry/.wine/drive_c/cc51/include
CC51LIB=/home/perry/.wine/drive_c/cc51/lib


# geda stuff
GEDADATA="/usr/share/gEDA"

# pager
PAGER="less"
LESS="-FRSXiqg"
# us seems to be ref text and stuff like options in manpages
export PAGER LESS LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m' LESS_TERMCAP_md=$'\E[01;34m'
export LESS_TERMCAP_se=$'\E[0m' LESS_TERMCAP_so=$'\E[01;47;30m'
export LESS_TERMCAP_ue=$'\E[0m' LESS_TERMCAP_us=$'\E[00;33m'

export CFLAGS CXXFLAGS CHOST CVSROOT CVSEDITOR LM_LICENSE_FILE CC51INC
export CC51LIB MALLOC_CHECK_ EDITOR GEDADATA SANDBOX CVS_RSH

# }}}


# {{{ Dircolors

if [ "$SHELL" != "dumb" ] ; then
  # zshrc default
  # dircolors ~/.dircolors
  LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:\
bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=00;31:\
ow=04;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:\
*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:\
*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:\
*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:\
*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:\
*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:\
*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:\
*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:\
*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:\
*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:\
*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:\
*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:\
*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:\
*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:\
*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:\
*.oga=00;36:*.spx=00;36:*.xspf=00;36:*.h=01;33:*.c=01;36:*.hex=01;44:\
*.map=04;32:*.lst=04;32:*.src=04;32:*.lua=01;36:*.R=01;36:*.py=01;36:\
*.cpp=01;36:*.pyc=01;32:"
  export LS_COLORS
  alias ls='ls -Lh --group-directories-first --color=auto'
else
  alias ls='ls -h -L --group-directories-first'
fi

# }}}


# {{{ Alias stuff

alias p="sudo pacman"
alias pc="sudo pacman-color"
alias y="yaourt"
alias vi="/usr/bin/vim"
alias vim="/home/perry/.bin/vim-start.sh"
alias :q="exit"
alias cds="cd $SANDBOX"
alias mv="mv -i"
alias t="ctags -R"
alias grepn="grep -n"
alias pg="less"
alias R="PAGER=\"`which less`\" `which R` --save --quiet"

# ls
alias lsf='ls -hlF --color="yes" | grep -v "\/" |' $PAGER

# required for man to operate correctly using utf-8
alias man='LC_ALL=C man'

# command shortcuts for windows compiler functions
TASKPATH="$HOME/.wine/drive_c/cc51/bin"      # path to tasking binaries
DYNCPATH="$HOME/.wine/drive_c/DCRABBIT_9.21" # path to dynamic-C

WINECMD=$(which wine)
alias mk51="$WINECMD    ${TASKPATH}/mk51.exe"
alias cc51="$WINECMD    ${TASKPATH}/cc51.exe"     # compiler
alias mpp51="$WINECMD   ${TASKPATH}/mpp51.exe"    # macro preprocessor
alias asm51="$WINECMD   ${TASKPATH}/asm51.exe"    # assembler
alias ld51="$WINECMD    ${TASKPATH}/link51.exe"   # linker
alias ihex51="$WINECMD  ${TASKPATH}/ihex51.exe"   # hex converter
alias dync="$WINECMD    ${DYNCPATH}/Dccl_cmp.exe" # dyn-c compiler

# }}}


# {{{ options

setopt correctall
setopt hist_ignore_all_dups
setopt autocd
setopt extendedglob
setopt sharehistory histappend
setopt hist_ignore_space

# }}}


# {{{ Completion stuff

zmodload zsh/complist
autoload -Uz compinit
autoload -U edit-command-line
compinit
zstyle :compinstall filename '${HOME}/.zshrc'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

#}}}

# {{{ Keybindings

bindkey -v
typeset -g -A key
#bindkey '\e[3~' delete-char
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
#bindkey '\e[2~' overwrite-mode
bindkey '^?' backward-delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[5~' history-beginning-search-backward
bindkey '^[[3~' delete-char
bindkey '^[[4~' end-of-line
bindkey '^[[6~' down-line-or-history
bindkey '^[[A'  history-beginning-search-backward
bindkey '^[[D' backward-char
bindkey '^[[B' down-line-or-history
bindkey '^[[C' forward-char
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line

# completion in the middle of a line
bindkey '^i' expand-or-complete-prefix

bindkey '\eOd' backward-word
bindkey '\eOc' forward-word
# }}}

# {{{ Window title

case $TERM in
    # *xterm*|rxvt*|rxvt-unicode|rxvt-256color|(dt|k|E)term)
    *xterm*|rxvt*|(dt|k|E)term)
        precmd () { print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a" }
        preexec () { print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a" }
    ;;
    screen*)
        precmd () {
            print -Pn "\e]83;title \"$1\"\a"
            # print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a"
        }
        preexec () {
            print -Pn "\e]83;title \"$1\"\a"
            print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a"
        }
    ;;
esac

#}}}


fortune.clone

# {{{ prompt
autoload -U promptinit

promptinit

. ~/.zshprompt
# setprompt
#- prompt mine
# prompt_mine_setup

#}}}

# vim:set ft=sh tw=80 fdm=marker ts=4 sw=4 et sta ai si:
alias clyde="sudo clyde"
