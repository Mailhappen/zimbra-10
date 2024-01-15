#!/bin/bash
# Initialize our applications

function copyln() {
  source=$1
  target=$2
  [ -z "$source" -o -z "$target" ] && return
  [ ! -e $source ] && cp -a $target $source
  rm -rf $target && ln -s $source $target
}

function init() {
  # setup container to use data from our volumes
  # in case volume not attached, we create it
  [ ! -d /data ] && mkdir /data
  # do the job
  copyln /data/store            /opt/zimbra/store
  copyln /data/index            /opt/zimbra/index
  copyln /data/redolog          /opt/zimbra/redolog
  copyln /data/db               /opt/zimbra/db
  copyln /data/data             /opt/zimbra/data
  copyln /data/conf             /opt/zimbra/conf
  copyln /data/ssl              /opt/zimbra/ssl
  copyln /data/ssh              /opt/zimbra/.ssh
  copyln /data/logger           /opt/zimbra/logger
  copyln /data/common-conf      /opt/zimbra/common/conf
  copyln /data/common-etc       /opt/zimbra/common/etc
  copyln /data/common-jetty     /opt/zimbra/common/jetty_home
  copyln /data/jetty-etc        /opt/zimbra/jetty_base/etc
  copyln /data/install_history  /opt/zimbra/.install_history
  copyln /data/zimlets-deployed /opt/zimbra/zimlets-deployed
  copyln /data/rsyslog.conf     /etc/rsyslog.conf

  # done initialize
  touch /init.done
}

function configure() {

  # Use new license file if exists
  [ -f /configs/ZCSLicense.xml ] && install -m 644 -o zimbra -g zimbra /configs/ZCSLicense.xml /opt/zimbra/conf/ZCSLicense.xml

  cat <<EOT > /tmp/defaultsfile
HOSTNAME="$myfqdn"
LDAPHOST="$myfqdn"
AVDOMAIN="$myfqdn"
CREATEDOMAIN="$myfqdn"
AVUSER="$myadmin@$myfqdn"
CREATEADMIN="$myadmin@$myfqdn"
SMTPDEST="$myadmin@$myfqdn"
SMTPSOURCE="$myadmin@$myfqdn"
CREATEADMINPASS="$mypassword"
EOT

  # show what we used
  cat /tmp/defaultsfile

  # do the setup
  /opt/zimbra/libexec/zmsetup.pl -c /tmp/defaultsfile

  # keep results
  cp -a /var/spool/cron/zimbra /data/zimbra.cron
  cp -a /opt/zimbra/config.* /data/
  cp -a /opt/zimbra/log/zmsetup.*.log /data/

  touch /data/configure.done
}

# Main

# 1. No argv. Automatically configure Zimbra and run it.
# 2. With argv. Run the argv. Useful for testing.

# Run as service
if [ -z "$@" ]; then
  # Good to enable debug here
  set -x

  mypassword="${DEFAULT_PASSWORD:=zimbra}"
  myhostname="$(hostname -s)"
  mydomain="$(hostname -d)"
  myfqdn="$myhostname.$mydomain"
  myadmin="${DEFAULT_ADMIN:=sysadmin}"
  mytimezone="${DEFAULT_TIMEZONE}"

  # Avoid running if hostname not set properly
  [ "$myfqdn" == "$myhostname" ] && exit

  # Set system timezone
  [ -f /usr/share/zoneinfo/$mytimezone ] && ln -sf /usr/share/zoneinfo/$mytimezone /etc/localtime

  # Run init
  [ ! -f /init.done ] && init 

  # Configure
  [ ! -f /data/configure.done ] && configure

  # Get Ready
  [ ! -f /var/spool/cron/zimbra ] && cp -a /data/zimbra.cron /var/spool/cron/zimbra

  # Hand over to supervisord
  [ ! -f /run/supervisord.pid ] && exec /usr/bin/supervisord -c /supervisord.conf
else

# Run as command
  exec "$@"
fi
