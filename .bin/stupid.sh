#!/bin/bash 
#
# A simple script to setup external momnitors using the xrandr 1.3 utility.
#
# Author: bioe007 perrydothargraveatgmail.com
#
#
# Modeline "1280x1024_60.00"  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync
# 
#
#0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# preferred mode grab
# PREFMODE="$(xrandr | grep ^\ .*+)"
# echo $PREFMODE
# exit 0
DISP_LOCAL="LVDS1"
DISP_LOCAL_NATIVE="1280x800"
DISP_EXT1="VGA1"

VIDEOSTATEFILE="$HOME/.var/video_state"
WP_CMD="`which nitrogen` --restore"

# default position, can be changed from cli args 
EXTPOS="--right-of"

# my screens
# add indices here and modelines below for new screens
I_SOYO=0
I_SYNC=1

MODELINES[I_SOYO]="1680x1050_69.00  171.19  1680 1792 1976 2272  1050 1051 1054 1092  -HSync +Vsync"
MODELINES[I_SYNC]="1280x1024_60.00  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync"

isnumber() {
    if [[ -z "$(echo $1 | tr -d '[0-9]')" ]] ; then
        return 0
    else
        return 1
    fi
}

# {{{ lvds 
lvds () {
    # wait until display is valid
    iloop=0
    while [[ -z "$DISPLAY" ]] ; do
        sleep 1
        iloop=$((iloop + 1))
    done

    # check for LVDS in native mode
    if [ -z "$(xrandr | grep ^$DISP_LOCAL | grep -w $DISP_LOCAL_NATIVE)" ]; then
        echo 'Setting $DISP_LOCAL to $DISP_LOCAL_NATIVE'
        xrandr --output $DISP_LOCAL --mode $DISP_LOCAL_NATIVE
    fi
}
# }}}

# {{{ ext_on sets up external display
# $1 = display
# $2 = mode name
# $3 = modeline
ext_on () {
    echo in ext_on
    if (( $# < 3 )); then
        echo "$0: ext_on: no argument supplied"
    fi

    EXTDISP=$1
    EXTMODENAME=$2
    shift 2
    EXTMODELINE="$@"

    if [ -z "$(xrandr | grep "$2")" ]; then 
        xrandr --newmode $EXTMODELINE
        xrandr --addmode $EXTDISP $EXTMODENAME
    fi

    xrandr --output $DISP_EXT1 --mode $EXTMODENAME $EXTPOS $DISP_LOCAL

    # at least for me, if i set VGA1 then sometimes LVDS gets borked
    lvds
}
# }}}

ext_off () {
    xrandr --output $DISP_EXT1 --off
}

# mgen takes 3 params
# $1 X res, $2 Y res, $3 refresh rate
# updates the value of modeline
mgen() {
    modeline="$(gtf $1 $2 $3 | grep Modeline | sed s/Modeline\ // | tr -d '"' )"
}

# {{{ setup 
# $1 = x res $2 = y res [optional $3 = starting refresh rate]
setup () {
    answer=""
    modeline=""
    oldmodeline=""
    INITREFRESH=$3

    # default refresh is what i liked best
    refresh=${INITREFRESH:-59}
    while [[ ! "$answer" == "y" ]] ; do
        # {{{ check that output & refresh rate are working well

        mgen $1 $2 ${refresh}
        echo "Trying: $modeline"

        ext_on "$DISP_EXT1" "$(echo $modeline | cut -f 1 -d ' ')" "${modeline}"

        if [ -n "$oldmodeline" ] ; then
            xrandr --delmode $DISP_EXT1 $(echo $oldmodeline | cut -f 1 -d ' ')
        fi

        refresh=$(( refresh + 1 ))

        # {{{ check if we should stop or backup now
        echo -n "like this setting? [y/N/b]"
        read answer
        if [ "$answer" == "y" ]; then
            break
        elif [ "$answer" == "b" ]; then 
            if [ -n "$oldmodeline" ]; then
                echo "restoring previous: refresh=$refresh"
                refresh=$(( refresh - 1))
                ext_on $DISP_EXT1 "$(echo $oldmodeline | cut -f 1 -d ' ')" "${oldmodeline}"
                xrandr --delmode $DISP_EXT1 $(echo $modeline | cut -f 1 -d ' ')
            else
                echo "no old line to restore"
            fi
        else
            oldmodeline="$modeline"
        fi
        # }}}
    done
    # }}}

    echo "exiting with refresh=$((refresh -1))"
    echo "modeline=$modeline"
}
# }}}

werror() {
    echo -e "$(basename $0): ERROR: $@"
    write_state "error"
    exit 1
}

write_state() {
    echo "$1" > $VIDEOSTATEFILE
}

FUNCTION=""
SHIFTDIST=1
# {{{ cli arguments
if (( $# > 0 )) ; then
    # {{{ have some arguments then parse them
    while (( $# > 0 )) ; do
        case $1 in

            "--off")
            FUNCTION="ext_off"
            ;;

            --pos*)
            if [[ -z "$2" ]] ; then
                werror
            else
                EXTPOS="$2"
                EXTPOS="--${EXTPOS#--}"
                SHIFTDIST=2
            fi
            ;;

            "--setup" )
            # {{{
            if (( $# >= 3 )) ; then
                # append any numeric arguments to the setup functions params
                for arg in $2 $3 $4 ; do
                    # ISNUM=$?
                    # if (( $ISNUM == 0 )) ; then
                    if isnumber "$arg" ; then

                        # add arg to list and increment number of args used
                        ARGS[$SHIFTDIST]=$arg
                        SHIFTDIST=$((SHIFTDIST+1))
                    else
                        # exit the for loop
                        break;
                    fi
                done

                FUNCTION="setup ${ARGS[@]}"
            else
                echo "$(basename $0): insufficient argument number"
                echo -e "\t--setup XRES YRES [initial refresh]"
            fi
            ;;
            # }}}

            --*)
            # {{{ select a pre-existing screen based on this argument
            SCRNAME="$(echo ${1#--} | tr [a-z] [A-Z])"
            ISCR="I_$SCRNAME"
            if [[ -n "${!ISCR}" ]] ; then
                FUNCTION="ext_on $DISP_EXT1 $(echo ${MODELINES[${!ISCR}]} | cut -f 1 -d ' ') ${MODELINES[${!ISCR}]}"
            else
                werror "$SCRNAME not found"
            fi
            ;;
            # }}}

            *)
            werror "Unknown option $1"
        esac

        shift $SHIFTDIST
        SHIFTDIST=1
    done
    # }}}
else
# if there are no args just set lvds
    FUNCTION="lvds"
fi
# }}}

${FUNCTION} || werror "$FUNCTION"

write_state $( echo $SCRNAME | tr -d '-')
$WP_CMD
exit 0 

# vim:set filetype=sh fdm=marker tabstop=4 sw=4 expandtab smarttab autoindent smartindent: 
