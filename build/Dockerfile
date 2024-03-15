FROM rockylinux:8

# Prepare OS

RUN yum install epel-release -y \
  && yum groupinstall "Minimal Install" --allowerasing -y \
  && yum install -y \
  glibc-all-langpacks \
  net-tools \
  nmap-ncat \
  dnsutils \
  perl \
  spax \
  sqlite \
  libidn \
  libaio \
  libicu \
  perl-Socket6 \
  sysstat \
  tmux \
  supervisor \
  && yum update -y \
  && yum clean all \
  && rm -f /var/log/dnf.* \
  && rm -f /var/log/*log

# Install Zimbra softwareonly

COPY ZCSLicense.xml keystrokes /installer/

RUN cd /installer \
  && cat keystrokes | sed -e 's/.*Use Zimbra/y Use Zimbra/' | cut -d' ' -f1 > /tmp/keystrokes \
  && curl -LO -C - https://files.zimbra.com/downloads/10.0.0_GA/zcs-NETWORK-10.0.0_GA_4518.RHEL8_64.20230301065514.tgz \
  && tar xf zcs-NETWORK-10.0.0_GA_4518.RHEL8_64.20230301065514.tgz \
  && cd zcs-NETWORK-10.0.0_GA_4518.RHEL8_64.20230301065514 \
  && sed -i '/^checkRequired/d' install.sh \
  && ./install.sh -l ../ZCSLicense.xml -s < /tmp/keystrokes \
  && cd / \
  && rm -rf /installer \
  && rm -f /tmp/keystrokes \
  && mv /tmp/install.log* /opt/zimbra/log/ \
  && install -m 644 -o zimbra -g zimbra /dev/null /var/log/zimbra-stats.log

# Supervisor

COPY --chmod=644 supervisord.conf /supervisord.conf
COPY --chmod=775 supervisor/ /supervisor/
COPY --chmod=644 sysstat.cron /etc/cron.d/sysstat
COPY --chmod=775 savedata.sh /etc/cron.daily/savedata.sh
COPY --chmod=775 entrypoint.sh start.sh /

ENTRYPOINT ["/entrypoint.sh"]

VOLUME /data

EXPOSE 22
EXPOSE 80
EXPOSE 443
EXPOSE 25
EXPOSE 465
EXPOSE 587
EXPOSE 110
EXPOSE 143
EXPOSE 993
EXPOSE 995
EXPOSE 7071
EXPOSE 9071
