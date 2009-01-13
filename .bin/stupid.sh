#!/bin/bash 
# Modeline "1280x1024_60.00"  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync

setup () {
answer=""

# default refresh is what i liked best
refresh="59"
while [[ -z "$answer" ]] ; do
 mline="$(gtf 1280 1024 "$refresh" | grep Modeline | sed s/Modeline\ //)"
 sudo xrandr --newmode $mline
 sudo xrandr --addmode VGA "$(echo $mline | cut -f 1 -d ' ')"
 sudo xrandr --output VGA --mode "$(echo $mline | cut -f 1 -d ' ')" --above LVDS
 refresh="$(( refresh + 1 ))"
 echo -n "like this setting? "
 read answer
 echo 
done
}

if [[ "$1" == "--setup" ]] ; then 
  setup
  exit 0
elif [[ "$1" == "--left" ]] ; then
  sudo xrandr --output VGA --mode "1280x1024_59.00" --left-of LVDS
else
  while [[ -z "$DISPLAY" ]] ; do
    sleep 1
  done
  sudo xrandr --newmode "1280x1024_59.00" 106.97 1280 1360 1496 1712 1024 1025 1028 1059 -HSync +Vsync
  sudo xrandr --addmode VGA "1280x1024_59.00"
  sudo xrandr --output VGA --mode "1280x1024_59.00" --left-of LVDS
  feh --xinerama=0 --bg-scale "/home/perry/images/awesome/my-bg.png" &

fi

# to make laptop primary use --preferred
