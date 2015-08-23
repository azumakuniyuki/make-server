#!/bin/sh
#
PATH="/usr/local/bin:/usr/bin:/bin"
LANG="C"
LC_CTYPE="C"

if [ "$LOGNAME" = "vagrant" -a "`uname -s`" = "Linux" ]; then
    perl -i -ple 's|secure_path = .+$|secure_path = /usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin/:sbin|' /etc/sudoers
fi

