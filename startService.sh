#/bin/sh

# eth0: connect to Internet (docker network type: bridge)
# eth1: connect to PPPoE clients (docker network type: macvlan )
INTERNET_IFACE=eth0
PPPOE_IFACE=eth1

# check network interfaces eth0 && eth1
for i in $INTERNET_IFACE $PPPOE_IFACE; do
	if ! ifconfig $i >&- 2>/dev/null; then
		echo "Network interface '$i' not found!"
		exit 1
#	else
#		echo "Network interface '$i' exist!"
	fi
done

# setup parameters for pppoe-server
local_ip=`ifconfig $INTERNET_IFACE 2>/dev/null | grep 'inet' | head -n1 | awk '{print $2}'`
if [ -z $local_ip ]; then
	echo "Not assign IP address on $INTERNET_IFACE"
	exit 2
fi
remote_ip=${REMOTE_IP:-192.168.255.1}
remote_netmask=$(echo $remote_ip|sed 's/[0-9]\+$/0/g')
max_session=${MAX_SESSION:-100}


pppoe-server -I $PPPOE_IFACE -L $local_ip -R $remote_ip -N $max_session && \
iptables -A POSTROUTING -t nat -s ${remote_netmask}/24 -j MASQUERADE
