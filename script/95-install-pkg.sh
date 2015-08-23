#!/bin/sh
#
PATH="/usr/local/bin:/usr/bin:/bin"
LANG="C"
LC_CTYPE="C"

if [ "`uname -s`" = "Linux" ]; then
    yum -y install python-simplejson
fi

