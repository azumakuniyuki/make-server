#!/bin/sh
#
PATH="/usr/local/bin:/usr/bin:/bin"
LANG="C"
LC_CTYPE="C"

getent passwd vagrant | grep ':500:500:' > /dev/null
if [ "$?" -eq "0" ]; then
    perl -i -ple 's/\A(vagrant:x):500:/$1:401:/' /etc/group
    perl -i -ple 's/\A(vagrant:x):500:500:/$1:401:401:/' /etc/passwd

    if [ -e "/home/vagrant" ]; then
        chown -R vagrant:vagrant /home/vagrant
    fi

    if [ -e "/var/spool/mail/vagrant" ]; then
        chown vagrant /var/spool/mail/vagrant
    fi
fi

