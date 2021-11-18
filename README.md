# docker-pppoe-server
The example for setup PPPoE server which running in Docker container.

Initial Date:

	2021/10/31

Version:

	Ubuntu Linux: 20.04.3 LTS (Focal Fossa)
	rp-pppoe: 3.12
	pppd: 2.4.7

Documentation:


Docker Hub:

><https://hub.docker.com/r/changhsinglee/pppoe-server>

GitHub (source):

><https://github.com/ChangHsingLee/docker-pppoe-server.git>

# Install docker engine
Refer to <https://docs.docker.com/engine/install/ubuntu/>
1. remove old versions of Docker
2. Update the apt package index and install packages to allow apt to use a repository over HTTPS
```shell
sudo apt-get update && \
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg \
     lsb-release
```
3. Add Docker's official GPG key:
```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
4. Use the following command to set up the stable repository
```shell
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] 		  https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
5. Update the apt package index, and install the latest version of Docker Engine and containerd:
```shell
sudo apt-get update && \
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

# Enable IPv6 in docker
Refer to <https://docs.docker.com/config/daemon/ipv6/>
1. Edit **/etc/docker/daemon.json**, set the ipv6 key to true and the fixed-cidr-v6 key to your IPv6 subnet.

> In this example we are setting it to 2001:db8:1::/64.
```json
{
	"ipv6": true,
	"fixed-cidr-v6": "2001:db8:1::/64"
}
```
> Save the file.

2. Reload the Docker configuration file.
```shell
systemctl reload docker (or service docker restart)
```
> or
```shell
service docker restart
```

# Installation
1. Create docker network which uses to connect to PPPoE clients

```shell
SUBNET="10.255.255.0/24"; \
GATEWAY=10.255.255.1; \
SUBNET_IPV6="2001:db8:2::/64"; \
GATEWAY_IPV6="2001:db8:2::1"; \
PPPOE_NIC=eno2; \
NETNAME=pppoe_net; \
docker network create -d macvlan --ipv6 --subnet="$SUBNET_IPV6" --gateway="$GATEWAY_IPV6" \
--subnet=$SUBNET --gateway=$GATEWAY -o parent=$PPPOE_NIC $NETNAME
```

> **PPPOE_NIC**: physical network interface that is connected to PPPoE clients.<br>
 **NETNAME**: naming of this network<br>
 **SUBNET**: IPv4 subnet in CIDR format that represents a network segment<br>
 **GATEWAY**: IPv4 Gateway for the master subnet<br>
 **SUBNET_IPV6**: IPv6 subnet in CIDR format that represents a network segment<br>
 **GATEWAY_IPV6**: IPv6 Gateway for the master subnet

2. Get docker image (download or create)
- Download docker image
```shell
docker pull changhsinglee/pppoe-server
```
- Create docker image
> You should get source code from [GitHub](https://github.com/ChangHsingLee/docker-pppoe-server) and put it into directory '$SRC_DIR'
```shell
SRC_DIR=$HOME/workspace/docker-pppoe-server; \
DOCKER_IMG_NAME="changhsinglee/pppoe-server:latest"; \
cd $SRC_DIR && docker build -t $DOCKER_IMG_NAME .
```
3. Prepare docker volume which uses to store configuration files and log files (Optional)
```shell
VOLUME_TOPDIR=$HOME/workspace/dockerVolumes/pppoe-server; \
mkdir -p $VOLUME_TOPDIR && cp -a srv/* $VOLUME_TOPDIR/
```

# Start Container
```shell
DOCKER_IMG_NAME="changhsinglee/pppoe-server:latest"; \
CONTAINER_NAME=pppoe-server; \
VOLUME_TOPDIR=$HOME/workspace/dockerVolumes/pppoe-server; \
HOST_NAME=PPPoEserver; \
NETNAME=pppoe_net; \
REMOTE_IP=192.168.255.1; \
MAX_SESSION=200; \
docker create --privileged -h $HOST_NAME \
--env REMOTE_IP=$REMOTE_IP \
--env MAX_SESSION=$MAX_SESSION \
--env MANUALLY_START=no \
--env DEFAULT_CFG=no \
-v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro \
-v $VOLUME_TOPDIR:/srv \
-it --restart always --name $CONTAINER_NAME $DOCKER_IMG_NAME && \
docker network connect $NETNAME $CONTAINER_NAME && \
docker start $CONTAINER_NAME
```
# Default Configuration
- DNS1<br>
    168.95.1.1
- DNS2<br>
    8.8.8.8
- Authentication Protocol<br>
    CHAP
- Log File<br>
    $VOLUME_TOPDIR/log/pppd.log (in container: /var/log/pppd.log)<br>
- Account (User Name/Password)<br>
    pppoe-user1/pppoe1234<br>
    pppoe-user2/pppoe2341<br>
    pppoe-user3/pppoe3412<br>
    pppoe-user4/pppoe4123<br>

### Backup docker image
    DOCKER_IMG_NAME="changhsinglee/pppoe-server:latest"; \
    BACKUP_DOCKER_IMAGE=pppoe-server-dockerImg.tar.bz2; \
    docker save $DOCKER_IMG_NAME | bzip2 -9vz > $BACKUP_DOCKER_IMAGE

### Restore docker image
    BACKUP_DOCKER_IMAGE=pppoe-server-dockerImg.tar.bz2; \
    bzip2 -dcv $BACKUP_DOCKER_IMAGE | docker load
