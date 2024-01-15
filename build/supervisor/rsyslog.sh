#!/bin/bash

# Start rsyslog
sed -i --follow-symlinks 's/SysSock.Use="off"/SysSock.Use="on"/' /etc/rsyslog.conf
sed -i --follow-symlinks 's/^module(load="imjournal"/#module(load="imjournal"/' /etc/rsyslog.conf
sed -i --follow-symlinks 's/^\s*UsePid="system"/  #UsePid="system"/' /etc/rsyslog.conf
sed -i --follow-symlinks 's/^\s*StateFile="imjournal.state"/  #StateFile="imjournal.state"/' /etc/rsyslog.conf
exec /usr/sbin/rsyslogd -n
