#!/usr/bin/python
# 
# volume.py
#     - simple volume adjustment
#     - to execute use 

# {{{ get_volume - duh
def get_volume():
  return commands.getoutput('aumix -v q').split(" ")[2]
# }}}

# {{{ smute - mute sound
def smute():
  if get_volume() == "0":
        vol = adjust()
  else:
    os.system("aumix -S")
    os.system("aumix -v 0")
    vol = "0"
  return vol
# }}} 
 
# {{{ adjust - restores and increments sound state
def adjust(increment=0): 

  # load previous sound level
  os.system("aumix -L > /dev/null 2>&1")
  adjvol=int(get_volume())+int(increment)

  # dont go below zero
  if adjvol< 0:
    adjvol = 0
  elif adjvol > 100:
    adjvol = 100

  # adjust sound level
  os.system("aumix -v"+str(adjvol)+" > /dev/null 2>&1")
  # save the current state
  os.system("aumix -S > /dev/null 2>&1")

  return adjvol
# }}}

# {{{ display - onscreen show 
def display(dispvol):
  os.system("kill $(/usr/bin/pgrep osd_cat) > /dev/null 2>&1 ")
  font="-bitstream-bitstream\ vera\ sans-bold-r-*-*-17-*-*-*-*-*-*-*"
  osdcmd="osd_cat --color=blue --pos=bottom --align=center --delay=1 --font=" + font

  if dispvol == "0":
    os.system("echo 'Volume Mute' | "+ osdcmd )
  else:
    os.system( osdcmd +" --barmode=percentage --percentage="+str(dispvol)+" --text=Volume")

  return
# }}}

if __name__ == "__main__":
  import commands, os, sys

  # with no arguments just mute, with arguments adjust the sound 
  if len(sys.argv) > 1:
    vol = adjust(sys.argv[1])
  else:
    vol = smute()

  display(vol)

# vim: set filetype=python fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent nu:
