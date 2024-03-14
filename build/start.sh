#!/bin/bash
set -x

# step1: wait for container to get ready
while [ ! -f /init.done -a ! -f /data/configure.done ]; do
    sleep 10
done

# step2: run pre-startup.sh script 
[ -x /configs/pre-startup.sh ] && /configs/pre-startup.sh

# step3: startup zimbra
/etc/init.d/zimbra restart

# step4: run post-startup.sh script
[ -x /configs/post-startup.sh ] && /configs/post-startup.sh

# step5: Go into uninterrupted running
exec tail -f /opt/zimbra/log/mailbox.log
