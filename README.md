# docker-pppoe-server
The example for setup PPPoE server which running in Docker container.

Initial Date:

	2020/10/31

Version:

	Ubuntu Linux: 20.04.3 LTS 
	rp-pppoe: 3.12
	pppd: 2.4.7

Documentation:


Docker Hub:


GitHub (source):

    https://github.com/ChangHsingLee/docker-pppoe-server.git

# Install docker engine
	Refer to https://docs.docker.com/engine/install/ubuntu/
	a. remove old versions of Docker
	b. Update the apt package index and install packages to allow apt to use a repository over HTTPS:
		sudo apt-get update
		sudo apt-get install \
		    apt-transport-https \
		    ca-certificates \
		    curl \
		    gnupg \
		    lsb-release
	c. Add Docker's official GPG key:
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	d. Use the following command to set up the stable repository
		echo \
		  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] 		  https://download.docker.com/linux/ubuntu \
		  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	e. Update the apt package index, and install the latest version of Docker Engine and containerd:
		sudo apt-get update
		sudo apt-get install docker-ce docker-ce-cli containerd.io

# Enable IPv6 in docker
	refer to https://docs.docker.com/config/daemon/ipv6/
	1. Edit /etc/docker/daemon.json, set the ipv6 key to true and the fixed-cidr-v6 key to your IPv6 subnet. 
       In this example we are setting it to 2001:db8:1::/64.
	   {
	      "ipv6": true,
	      "fixed-cidr-v6": "2001:db8:1::/64"
	   }
	   Save the file.
	2. Reload the Docker configuration file.
	   systemctl reload docker (or service docker restart)

# Installation
	1. Create docker network which uses to connect to PPPoE clients
		SUBNET="10.255.255.0/24"; \
        GATEWAY=10.255.255.1; \
        SUBNET_IPV6="2001:db8:2::/64"; \
        GATEWAY_IPV6="2001:db8:2::1"; \
        PPPOE_NIC=eno2; \
        NETNAME=pppoe_net; \
        docker network create -d macvlan --ipv6 --subnet="$SUBNET_IPV6" --gateway="$GATEWAY_IPV6" --subnet=$SUBNET --gateway=$GATEWAY -o parent=$PPPOE_NIC $NETNAME

		PPPOE_NIC   : physical network interface that is connected to PPPoE clients.
		NETNAME     : naming of this network
		SUBNET      : IPv4 subnet in CIDR format that represents a network segment
		GATEWAY     : IPv4 Gateway for the master subnet
		SUBNET_IPV6 : IPv6 subnet in CIDR format that represents a network segment
		GATEWAY_IPV6: IPv6 Gateway for the master subnet
	2. Create docker image
		DOCKER_IMG_NAME="chlee/pppoe-server:latest"; \
        docker build -t $DOCKER_IMG_NAME .
	3. Prepare docker volume which uses to store configuration files and log files
		VOLUME_TOPDIR=$HOME/workspace/dockerVolumes/pppoe-server; \
        cp -a srv/* $VOLUME_TOPDIR/

# Start Container
    DOCKER_IMG_NAME="chlee/pppoe-server:latest"; \
    CONTAINER_NAME=pppoe-server; \
    VOLUME_TOPDIR=$HOME/workspace/dockerVolumes/pppoe-server; \
    HOST_NAME=PPPoEserver; \
    NETNAME=pppoe_net; \
    REMOTE_IP=192.168.255.1; \
    MAX_SESSION=200; \
    docker create --privileged -h $HOST_NAME \
    --env REMOTE_IP=$REMOTE_IP \
    --env MAX_SESSION=$MAX_SESSION \
    -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro \
    -v $VOLUME_TOPDIR:/srv \
    -it --restart always --name $CONTAINER_NAME $DOCKER_IMG_NAME && \
    docker network connect $NETNAME $CONTAINER_NAME && \
    docker start $CONTAINER_NAME
