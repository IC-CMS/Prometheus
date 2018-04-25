#!/bin/bash

function usage() {
    echo "USAGE: "
    echo "-b <build name>              *REQUIRED"
    echo "-t <packer template name>    default = packer-template.json"
    echo "-c <credential file name>    default = packer_credentials.json"
    echo "-v <variable file name>      default = packer_var.json"
    echo "-h display this help message"
    return 0
}

DEBUG= ""
TEMPLATE='packer_template.json'
CREDENTIALS='packer_credentials.json'
VARIABLES='packer_var.json'

while getopts ":b:t:c:v:h?" opt ;
do
    case "$opt" in
        b)
            BUILD_NAME="$(OPTARG)"
            ;;
        t)
            TEMPLATE="$(OPTARG)"
            ;;
        c)
            CREDENTIALS="$(OPTARG)"
            ;;
        v)
            VARIABLES="$(OPTARG)"
            ;;
        d)
            DEBUG="--debug"
            echo "Debug Enabled"
            ;;
        h|?)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${BUILD_NAME}" ]
then
    echo "*** The -b <build name> argument is required"
    usage
    exit 1
fi

sudo docker run -it --env-file=docker.env \
    -v $(pwd):/tmp/prometheus \
    -v Apache_Bundle_AllTrustedPartners.crt:/etc/pki/tls/certs/Apache_Bundle_AllTrustedPartners.crt
    hashicorp/packer:latest build \
        $DEBUG \
        -only=${BUILD_NAME}
        -var-file=${CREDENTIALS} \
        -var-file=${VARIABLES} \
        ${TEMPLATE}