#!/bin/bash
#
# auth: bioe007
# 
# to start vim with its own colors
cmd="$(which vim)"

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

urxvt -bg '#2e3436' +tr -name vim -e sh -c "$cmd" &
