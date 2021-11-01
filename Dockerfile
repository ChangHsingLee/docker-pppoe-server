# OS: Ubuntu 20.04.3 LTS
FROM ubuntu:focal
MAINTAINER Chang-Hsing Lee <changhsinglee@gmail.com>

# install rp-pppoe v3.12, pppd v2.4.7 (ubuntu package)
RUN apt-get update && apt-get install --no-install-recommends  -y \
pppoe iputils-ping vim-tiny iptables net-tools && \
	\
# export configuration files & log files
mkdir -p /srv/log && mv /etc/ppp /srv/pppoe-config && rm -fr /var/log && \
ln -sf /srv/log /var/log && ln -sf /srv/pppoe-config /etc/ppp && \
	\
# backup default configuration files
echo "ms-dns 168.95.1.1\nms-dns 8.8.8.8\nauth">/srv/pppoe-config/pppoe-server-options && \
echo "proxyarp\nlcp-echo-interval 30\nlcp-echo-failure 4">>/srv/pppoe-config/pppoe-server-options && \
echo "debug 1\nlogfile /var/log/pppd.log">>/srv/pppoe-config/pppoe-server-options && \
echo '"pppoe-user1" * "pppoe1234" *'>>/srv/pppoe-config/chap-secrets && \
echo '"pppoe-user2" * "pppoe2341" *'>>/srv/pppoe-config/chap-secrets && \
echo '"pppoe-user3" * "pppoe3412" *'>>/srv/pppoe-config/chap-secrets && \
echo '"pppoe-user4" * "pppoe4123" *'>>/srv/pppoe-config/chap-secrets && \
mkdir /srv.bak && mv /srv/* /srv.bak/ && \
	\
# change SHELL from dash to bash
ln -sf /bin/bash /bin/sh

# copy startup script
COPY startService.sh /etc/

# start service/application
ENTRYPOINT /etc/startService.sh && /bin/bash
