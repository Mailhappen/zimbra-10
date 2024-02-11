#!/bin/bash
set -x

# stage1: wait until ready
while [ ! -f /init.done -a ! -f /data/configure.done ]; do
    sleep 10
done

# stage2: start zimbra and dump mailbox.log to stay on
/etc/init.d/zimbra restart && exec tail -f /opt/zimbra/log/mailbox.log
