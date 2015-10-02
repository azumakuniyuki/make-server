#!/bin/sh
#
PATH="/usr/local/bin:/usr/bin:/bin"
LANG="C"
LC_CTYPE="C"

if [ "`uname -s`" = "Linux" ]; then
    /usr/sbin/setenforce 0
    perl -i -ple 's/^SELINUX=.+$/SELINUX=disabled/' /etc/sysconfig/selinux
fi

