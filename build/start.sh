#!/bin/bash
set -x

# stage1: wait until ready
while [ ! -f /init.done -a ! -f /data/configure.done ]; do
    sleep 10
done

# stage2: start zimbra and dump mailbox.log to stay on
if [ ! -f /zimbra.started ]; then
  /etc/init.d/zimbra restart
  touch /zimbra.started
  tail -f /opt/zimbra/log/mailbox.log
fi
