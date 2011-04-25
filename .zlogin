if [ -r $HOME/.zshrc ] && [ -z "$SANDBOX" ] ; then
  . $HOME/.zshrc
fi
# the very basics
export PATH="~/.bin:/usr/local/bin:/opt/mozilla/bin":${PATH}
export PYTHONPATH="$(pwd):$PYTHONPATH"

export MOZILLA_FIVE_HOME="/usr/lib/xulrunner-1.9.0.4"
# a hack for awesome+java
export AWT_TOOLKIT=MToolkit
export OOO_FORCE_DESKTOP=gnome
export INTEL_BATCH=2
