#!/bin/bash

# please define your external interface
ext_if="ens192"

# tear down
if [ -n "$1" -a "$1" == "-d" ]; then
  sudo iptables -D DOCKER-USER -i $ext_if -o zimbra0 -j ACCEPT >/dev/null 2>&1
  sudo docker network inspect zimbranet >/dev/null 2>&1 &&
  sudo docker network rm zimbranet
  exit
fi

# create zimbranet (interface zimbra0)
sudo docker network inspect zimbranet >/dev/null 2>&1 ||
sudo docker network create -d bridge \
  --subnet=172.16.3.0/24 \
  --gateway=172.16.3.1 \
  -o "com.docker.network.bridge.enable_icc"="true" \
  -o "com.docker.network.bridge.enable_ip_masquerade"="false" \
  -o "com.docker.network.bridge.name"="zimbra0" \
  -o "com.docker.network.driver.mtu"="1500" \
  zimbranet

# allow passthru in iptables
sudo iptables -C DOCKER-USER -i $ext_if -o zimbra0 -j ACCEPT >/dev/null 2>&1 || \
sudo iptables -I DOCKER-USER -i $ext_if -o zimbra0 -j ACCEPT >/dev/null 2>&1
