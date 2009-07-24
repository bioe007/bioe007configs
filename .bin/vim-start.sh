#!/bin/bash
#
# auth: bioe007
# 
# to start vim with its own colors
cmd="$(which vim)"

F2OPEN=""
if [ "$#" -gt "0" ] ; then
  files="$@"
  F2OPEN="1"
fi

srv="$($cmd --serverlist | head -1)"

# no existing vim server found use default master
if [ -z "$srv" ] ; then 
  srv="master" 

  # open with files from cli or not
  if [ "$F2OPEN" ] ; then
    cmd="$cmd --servername $srv \"$files\""
  else
    cmd="$cmd --servername $srv" 
  fi
else
  echo "Opening files in server: $srv"
  cmd="$cmd --servername $srv --remote-silent \"$files\""
fi

# opens vim in urxvt
urxvt -bg '#2e3436' +tr -name vim -e sh -c "$cmd" &





# vim:set filetype=sh textwidth=80 fdm=syntax tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent:
