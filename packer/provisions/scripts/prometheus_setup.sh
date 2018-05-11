#!/bin/bash

function usage() {
    echo " "
    echo "USAGE: "
    echo "-r <docker repository endpoint>   *required if not using the standard Docker Hub"
    echo "-u <user name for repository>     *required if not using the standard Docker Hub"
    echo "-p <user password for repository> *required if not using the standard Docker Hub"
    echo "-h display this help message"
    echo " "
    return 0
}

AWS='aws_builder'
AWS2='aws2_builder'
OPEN='open_builder'
DOCKER='docker'

while getopts ":u:p:r:h?" opt ;
do
    case "$opt" in
        u)
            USER_NAME="$(OPTARG)"
            ;;
        p)
            USER_PASS="$(OPTARG)"
            ;;
        r)
            CONTAINER_REPO="$(OPTARG)"
            ;;
        h|?)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

case "$PACKER_BUILD_NAME" in
    ${AWS2} )
                    echo "Using tls for docker in ${PACKER_BUILD_NAME}"
                    DOCKER='docker --tls'
                    ;;
    ${AWS}|${OPEN}|* )
                    echo "Not using tls for docker in ${PACKER_BUILD_NAME}"
                    ;;
esac

#Without this, docker pull throws an error
sleep 60

#Pull the docker image
sudo ${DOCKER} pull prom/prometheus:latest

#Attach storage: Keep if we decide to make the storage persistent
#sudo mkfs -t ext4 /dev/xvdf #Remove this if for some reason we suspect we might need to use this script on a previous drive (ex. a snapshot)
sudo mkdir -m 777 /data
# add the device on every reboot
#echo "/dev/xvdf /data ext3 defaults,nofail 0 2" | sudo tee -a /etc/fstab
#sudo mount -a

sudo mkdir -m 755 -p /etc/prometheus
sudo cp /tmp/provisions/config/prometheus.yml /etc/prometheus/prometheus.yml
sudo cp /tmp/provisions/config/alert.rules /etc/prometheus/alert.rules

#Clean out the certs and run the docker container for Prometheus
sudo rm -Rf /root/.docker

#This is now in the docker-compose file for terraform
#sudo ${DOCKER} run -d \
#        --name prometheus \
#        -p 9090:9090 \
#        --restart=on-failure:10 \
#        --network="host" \
#        -v /tmp/provisions/config/alert.rules:/etc/prometheus/alert.rules \
#        -v /tmp/provisions/config/prometheus.yml:/etc/prometheus/prometheus.yml \
#        -v /data:/prom/prometheus/data \
#        prom/prometheus:latest