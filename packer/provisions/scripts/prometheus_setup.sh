#!/bin/bash

function usage() {
    echo "USAGE: "
    echo "-r <docker repository endpoint>   *required if not using the standard Docker Hub"
    echo "-u <user name for repository>     *required if not using the standard Docker Hub"
    echo "-p <user password for repository> *required if not using the standard Docker Hub"
    echo "-h display this help message"
    return 0
}

CONTAINER_NAME=prometheus
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

if [ -n "${CONTAINER_REPO}" ]
then
    if [[ -z "${USER_NAME}"  ||  -z "${USER_PASS}" ]]
    then
        echo "*** missing required arguments:"
        usage
        exit 1
    fi

    #Login to contianer repository
    sudo docker login -u ${USER_NAME} -p ${USER_PASS} ${CONTAINER_REPO}
fi

#Pull the docker image
sudo docker pull prom/prometheus:latest

#Position files
sudo mkdir /opt/${CONTAINER_NAME}
sudo cp /tmp/provisions/docker-compose.yml /opt/${CONTAINER_NAME}
sudo cp /tmp/provisions/config /opt/${CONTAINER_NAME}

#Attach storage: Keep if we decide to make the storage persistent
sudo mkfs -t ext4 /dev/xvdf #Remove this if for some reason we suspect we might need to use this script on a previous drive (ex. a snapshot)
sudo mkdir -m 777 /data
# add the device on every reboot
echo "/dev/xvdf /data ext3 defaults,nofail 0 2" | sudo tee -a /etc/fstab
sudo mount -a
