#!/bin/bash 
#
# Modeline "1280x1024_60.00"  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync
# 
# for samsung syncmaster 191t
# sudo xrandr --newmode 1280x1024_59.00 106.97 1280 1360 1496 1712 1024 1025 1028 1059 -HSync +Vsync
#
# for soyo 22" screen
# sudo xrandr --newmode 1440x900_60.00  106.47  1440 1520 1672 1904  900 901 904 932  -HSync +Vsync

# preferred mode grab
# PREFMODE="$(xrandr | grep ^\ .*+)"
# echo $PREFMODE
# exit 0


# {{{ lvds 
lvds () {
  # wait until display is valid
  while [[ -z "$DISPLAY" ]] ; do
    sleep 1
    iloop="$((iloop + 1))"
  done
  # check for LVDS in native mode
  if [ -z "$(xrandr | grep ^LVDS | grep -w 1280x800)" ]; then
    sudo xrandr --output LVDS --mode 1280x800
    echo 'Setting LVDS to 1280x800'
    iloop="0"
  fi
}
# }}}

off () {
  xrandr --output VGA --off
}
# {{{ syncmaster 
syncmaster () {
  lvds
  if [ -z "$(xrandr | grep 1280x1024_59 | grep -w "**$")" ] ; then
    sudo xrandr --newmode 1280x1024_59.00 106.97 1280 1360 1496 1712 1024 1025 1028 1059 -HSync +Vsync
    sudo xrandr --addmode VGA 1280x1024_59.00
  fi
  sudo xrandr --output VGA --mode 1280x1024_59.00 --left-of LVDS
}
# }}}

# {{{ soyo 
soyo () {
  lvds
#| grep -w "**$")" ] ; then 
  if [ -z "$(xrandr | grep '1680x1050_68.00')" ]; then 
    sudo xrandr --newmode 1680x1050_68.00  168.71  1680 1792 1976 2272  1050 1051 1054 1092  -HSync +Vsync
    sudo xrandr --addmode VGA  1680x1050_68.00
  fi
  echo in soyo
  # sudo xrandr --output VGA --mode 1680x1050_68.00 --right-of LVDS
  sudo xrandr --output VGA --mode 1680x1050_68.00 --above LVDS
}
# }}}

mgen() {
  mline="$(gtf 1440 900 ${refresh} | grep Modeline | sed s/Modeline\ // | tr -d '"' )"

}
  
# {{{ setup 
setup () {
  answer=""
  mline=""
  oline=""

  # default refresh is what i liked best
  refresh="59"
  while [[ ! "$answer" == "y" ]] ; do

    mline="$(gtf 1680 1050 ${refresh} | grep Modeline | sed s/Modeline\ // | tr -d '"' )"
    # mline="$(mgen $1 $2 ${refresh})"
    echo $mline

    sudo xrandr --newmode $mline
    sudo xrandr --addmode VGA "$(echo $mline | cut -f 1 -d ' ')"
    sudo xrandr --output VGA --mode $(echo $mline | cut -f 1 -d ' ') --right-of LVDS
    if [ ! -z "$oline" ] ; then
      sudo xrandr --delmode VGA $(echo $oline | cut -f 1 -d ' ')
    fi

    refresh="$(( refresh + 1 ))"

    echo -n "like this setting? [y/N/b]"
    read answer
    if [ "$answer" == "y" ]; then
      break
    elif [ "$answer" == "b" ]; then 
      if [ ! -z "$oline" ]; then
        echo "restoring previous: refresh=$refresh"
        sudo xrandr --addmode VGA "$(echo $oline | cut -f 1 -d ' ')"
        sudo xrandr --output VGA --mode "$(echo $oline | cut -f 1 -d ' ')" --right-of LVDS
      else
        echo "no old line to restore"
      fi
    else
      oline="$mline"
    fi
  done

  echo "exiting with refresh=$((refresh -1))"
  echo "modeline=$mline"
}
# }}}

if [[ "$1" == "--setup" ]] ; then 
  setup
  exit 0
elif [[ "$1" == "--sync" ]] ; then
  syncmaster
  exit 0
elif [[ "$1" == "--soyo" ]] ; then
  soyo
  exit 0
elif [[ "$1" == "--off" ]] ; then
  off
  exit 0 
else
  lvds
fi

# vim:set filetype=sh fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent: --
