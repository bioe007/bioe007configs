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
autocutsel -s PRIMARY -buttonup -fork
dropboxd > ~/.var/dropboxd.log 2>&1 &
xset +dpms dpms 300 900 0 &
xset +fp $HOME/.fonts/misc,$HOME/.fonts/new,$HOME/.fonts/profont-x11 &

exec ck-launch-session dbus-launch awesome
