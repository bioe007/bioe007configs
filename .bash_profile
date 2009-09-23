if [ -r $HOME/.bashrc ] && [ -z "$SANDBOX" ] ; then
  . $HOME/.bashrc
fi

# the very basics
export PATH="~/.bin:/usr/local/bin:/opt/mozilla/bin":${PATH}
export MOZILLA_FIVE_HOME="/usr/lib/xulrunner-1.9.1"

#---------------------- deprecated -----------------------#
# replaced this with a symbolic link in /usr/local/bin
#alias erload='sh /home/perry/scripts/wine/ercmd.sh'    # this executes the econoromIII load or test function

# prompts -----------------------
# export PS1="\[\e]2;\w\a\e\[\e[33;1m\]\j\[\e[0m\] :\[\e[34;1m\] \W \[\e[0m\]: \[\e[37;0m\]\\$\[\e[0m\] "
#export PS1="\[\e[33;1m\]\j\[\e[0m\] :\[\e[34;1m\] \W \[\e[0m\]: \[\e[37;0m\]\\$\[\e[0m\] "
# this version puts path into window title bar
# export PS1="\[\e]2;\u@\H:\w\a\e[30;1m\]\\$\[\e[0m\] "

# stuff required for mozilla
# LD_LIBRARY_PATH=/opt/mozilla/lib:${LD_LIBRARY_PATH}
# PKG_CONFIG_PATH=/opt/mozilla/lib/pkgconfig:${PKG_CONFIG_PATH}
export AWT_TOOLKIT=MToolkit
export OOO_FORCE_DESKTOP=gnome
export INTEL_BATCH=2
