#!/bin/bash
#set -x

# some files get changed and should be saved back to /data

function save() {
  source=$1
  target=$2
  [ -z "$source" -o -z "$target" -o ! -e "$source" ] && return
  cp -a -f $source $target
}

save /var/spool/cron/zimbra  /data/zimbra.cron
save /etc/logrotate.d/zimbra /data/zimbra.logrotate

