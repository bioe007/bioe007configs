#!/bin/bash
#
#
# to start vim with its own colors
cmd="$(which vim)"
if [ "$#" -gt "0" ] ; then
  cmd="$cmd vim -s $@"
fi
xrdb -load ~/.Xdefaults.light
urxvtc -name vim -e sh -c "$cmd" &
xrdb -load ~/.Xdefaults
