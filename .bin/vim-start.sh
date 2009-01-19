#!/bin/bash
#
#
# to start vim with its own colors
cmd="$(which vim)"
xrdb -load ~/.Xdefaults.light

if [ "$#" -gt "0" ] ; then
  files="$@"
fi

srv="$($cmd --serverlist | head -1)"

echo $srv

# no existing vim server found use default master
if [ -z "$srv" ] ; then 
  srv="master" 
  cmd="$cmd --servername $srv $files"
else
  cmd="$cmd --servername $srv --remote-silent $files"
fi

urxvtc -name vim -e sh -c "$cmd" &

xrdb -load ~/.Xdefaults
