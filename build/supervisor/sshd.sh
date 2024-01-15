#!/bin/bash

# Start sshd
[ ! -s /etc/ssh/ssh_host_rsa_key ] && /usr/libexec/openssh/sshd-keygen rsa
[ ! -s /etc/ssh/ssh_host_ecdsa_key ] && /usr/libexec/openssh/sshd-keygen ecdsa
sed -i --follow-symlinks '/ssh_host_ed25519_key/d' /etc/ssh/sshd_config
sed -i --follow-symlinks '/pam_nologin/d' /etc/pam.d/sshd
exec /usr/sbin/sshd -D
