#!/bin/bash
set -x

# Write commands that can be run once everytime Zimbra startup

# Our working dir
cd /configs

# Install logo
function install_logo () {
  [ ! -s logos/logo.svg ] && return
  install -o root -g root -m 755 -d /opt/zimbra/jetty/webapps/zimbra/logos
  install -o root -g root -m 644 logos/logo.svg /opt/zimbra/jetty/webapps/zimbra/logos/logo.svg
  install -o root -g root -m 644 logos/logo.svg /opt/zimbra/jetty/webapps/zimbra/modern/clients/default/assets/logo.svg
  su - zimbra -c 'zmprov mcf zimbraSkinLogoLoginBanner /logos/logo.svg'
  su - zimbra -c 'zmprov mcf zimbraSkinLogoAppBanner /logos/logo.svg'
  su - zimbra -c 'zmprov fc skin'
}
install_logo

