# OS: Ubuntu 20.04.3 LTS
FROM ubuntu:focal
MAINTAINER Chang-Hsing Lee <changhsinglee@gmail.com>

# change SHELL from dash to bash
RUN ln -sf /bin/bash /bin/sh

# install rp-pppoe v3.12, pppd v2.4.7 (ubuntu package)
RUN apt-get update && apt-get install --no-install-recommends  -y \
pppoe iputils-ping vim-tiny iptables net-tools && \
	\
# export configuration files & log files
mkdir -p /srv/log && mv /etc/ppp /srv/pppoe-config && rm -fr /var/log && \
ln -sf /srv/log /var/log && ln -sf /srv/pppoe-config /etc/ppp

# copy startup script
COPY startService.sh /etc/

# start service/application
ENTRYPOINT /etc/startService.sh && /bin/bash
