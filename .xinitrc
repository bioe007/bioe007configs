#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

[[ -r "$HOME/.Xmodmap" ]] && xmodmap ~/.Xmodmap &
/usr/share/eclipse/eclimd > ~/.var/eclimd.log 2>&1 &

# handles themes, starts gnome-screensaver. You may have to use gconf to
# disable it setting the background.
# gnome-session &
gnome-settings-daemon &
nm-applet &             # assuming you're using Network Manager
gnome-power-manager &   # for laptops and stuff
# gnome-volume-manager &  # for mounting CDs, USB sticks, and such
# awesome receives xinit's process id; when it terminates, X will be terminated
exec ck-launch-session dbus-launch awesome
