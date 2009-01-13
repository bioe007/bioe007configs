chroot "$LFS" /usr/bin/env -i HOME=/root TERM="$TERM" PS1="\[\e[32;1m\]\u@\H \\$ \[\e[0m\]" PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login
