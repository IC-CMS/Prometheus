#!/bin/bash

function usage() {
    echo "USAGE: "
    echo "-r <docker repository endpoint>   *required if not using the standard Docker Hub"
    echo "-u <user name for repository>     *required if not using the standard Docker Hub"
    echo "-p <user password for repository> *required if not using the standard Docker Hub"
    echo "-h display this help message"
    return 0
}

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

#pull the docker image
sudo docker pull prom/prometheus:latest

