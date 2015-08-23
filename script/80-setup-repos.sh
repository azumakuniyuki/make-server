#!/bin/sh
#
PATH="/usr/local/bin:/usr/bin:/bin"
LANG="C"
LC_CTYPE="C"
YUMREPOS="elff prosvc puppetlabs"

if [ "`uname -s`" = "Linux" ]; then
    for v in $YUMREPOS; do
        r="/etc/yum.repos.d/$v.repo"
        if [ -e "$r" ]; then
            perl -i -ple 's/enabled=1/enabled=0/g' $r
        fi
    done
fi

