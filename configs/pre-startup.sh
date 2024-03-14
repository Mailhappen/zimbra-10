#!/bin/bash
set -x

# Write commands that can be run once everytime Zimbra startup

# Our working dir
cd /configs

# Fix Too many open files error during zmmboxmove
sed -i 's/65536/524288/' /opt/zimbra/jetty/etc/jetty-setuid.xml

