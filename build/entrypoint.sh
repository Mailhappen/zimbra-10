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
  copyln /data/zimlets-deployed /opt/zimbra/zimlets-deployed
  copyln /data/rsyslog.conf     /etc/rsyslog.conf

  # to improve more in future...
  copyln /data/common-conf      /opt/zimbra/common/conf
  copyln /data/common-etc       /opt/zimbra/common/etc
  copyln /data/common-jetty     /opt/zimbra/common/jetty_home
  copyln /data/jetty-etc        /opt/zimbra/jetty_base/etc
  copyln /data/install_history  /opt/zimbra/.install_history
  #copyln /data/onlyoffice       /opt/zimbra/onlyoffice

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

  # keep results after configure
  cp -a /var/spool/cron/zimbra        /data/zimbra.cron
  cp -a /etc/rsyslog.conf             /data/rsyslog.conf
  cp -a /etc/logrotate.d/zimbra       /data/zimbra.logrotate
  cp -a /opt/zimbra/config.*          /data/
  cp -a /opt/zimbra/log/zmsetup.*.log /data/

  touch /data/configure.done
}

function adjustmemorysize() {
  # size must be 4 and above. Default 8
  size=$1
  [ -z $size ] && size=8
  [ $size -lt 4 ] && size=4
  if [ $size -ge 16 ]; then
    memory=$(($size*1024/5))
  else
    memory=$(($size*1024/4))
  fi
  su - zimbra -c "zmlocalconfig -e mailboxd_java_heap_size=$memory"

  # mysql always use 30 percent
  memKB=$(($size * 1024 * 1024))
  ((bufferPoolSize=memKB * 1024 * 30 / 100))
  sed -i --follow-symlinks "s/^innodb_buffer_pool_size.*/innodb_buffer_pool_size        = $bufferPoolSize/" /opt/zimbra/conf/my.cnf
}

# Main

mypassword="${DEFAULT_PASSWORD:=zimbra}"
myhostname="$(hostname -s)"
mydomain="$(hostname -d)"
myfqdn="$myhostname.$mydomain"
myadmin="${DEFAULT_ADMIN:=sysadmin}"
mytimezone="${DEFAULT_TIMEZONE:=Asia/Kuala_Lumpur}"
maxmem="${MAX_MEMORY_GB:=8}"

# Set system timezone
[ -f /usr/share/zoneinfo/$mytimezone ] && ln -sf /usr/share/zoneinfo/$mytimezone /etc/localtime && echo $mytimezone > /etc/timezone

# Automatic run as service
if [ -z "$@" ]; then
  # Good to enable debug here
  set -x

  # Avoid running if mydomain is empty
  [ -z "$mydomain" ] && exit

  # Run init
  [ ! -f /init.done ] && init 

  # Configure
  [ ! -f /data/configure.done ] && configure

  #
  # System ready to start up.
  #
 
  # restore system files
  [ ! -f /var/spool/cron/zimbra ] && cp -a /data/zimbra.cron /var/spool/cron/zimbra
  [ ! -f /etc/logrotate.d/zimbra ] && cp -a /data/zimbra.logrotate /etc/logrotate.d/zimbra

  # Adjust mailboxd heap and mysql memory size for container
  adjustmemorysize $maxmem

  # Hand over to supervisord
  [ ! -f /run/supervisord.pid ] && exec /usr/bin/supervisord -c /supervisord.conf

else
# Manual run as command to develop entrypoint.sh
  exec "$@"
fi
