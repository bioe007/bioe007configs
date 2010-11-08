export ZSH="$HOME/.zsh"
export ZSH_THEME="bioe007"
export DISABLE_AUTO_UPDATE="true"
plugins=('git')


__mgcc() {
    DEFOPT='-W -Wall -g'
    while [ "$#" -gt "0" ] ; do
        case $1 in
            -*)
                DEFOPT="$DEFOPT $1"
                ;;
            *)
                IN="$@"
                ;;
        esac
        shift
    done
    CMD=$DEFOPT
    OUT="${IN%%.*}"

    eval gcc $DEFOPT $IN -o $OUT
}

# setopt print_exit_value   # print $? if nonzero
autoload -U edit-command-line

source $ZSH/zsh_init.sh
