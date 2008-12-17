#!/bin/sh
#
# simple awesome-clock
while true 
do
  if [ -S ~/.awesome_ctl.0 ]; then
    while true
    do
      # See 'man date' to see the possible replacements for the % fields.
      # uncomment the following line for use with awesome 2.3
      # echo "0 widget_tell mystatusbar clock text "   "`date +\"%g:%m:%d %H:%M %p\"`"
      echo "0 widget_tell mystatusbar clock text "   "`date +\"%H:%M %g%m%d\"`"
      # echo "0 widget_tell clock "   " `date +\"%a, %b %d %I:%M\"`"
      echo "" # an empty line flushes data inside awesome
      sleep 10
    done | awesome-client
  else
    sleep 1
  fi
done

