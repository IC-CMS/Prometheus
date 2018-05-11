#!/usr/bin/env bash
#
#Instructions
#Using the Packer Template file for the project
#Use a build name from the packer template that you wish to build
#Create a credentials variable file for the platform desired.
# ex. aws use the fetch_credentials script to create the file from the current Instance Role
#Create a packer variable file that contains all of the user variables needed for the build in the packer template
#The variable file for each platform exists in this Prometheus project

function usage() {
    echo "USAGE: "
    echo "-b <build name>                       *REQUIRED"
    echo "-t <packer template name>             default = packer-template.json"
    echo "-p <password/credential file name>    default = packer_credentials.json"
    echo "-v <variable file name>               default = packer_var.json"
    echo "-c <packer container>                 default = hashicorp/packer"
    echo "-h display this help message"
    return 0
}

DEBUG=''
CONTAINER='hashicorp/packer'
TEMPLATE='prometheus_template.json'
CREDENTIALS='packer_credentials.json'
VARIABLES='packer_var_aws.json'
ADD_TRUST=' '

while getopts ":b:t:c:v:p:d:h?" opt ;
do
    case "$opt" in
        b)
            BUILD_NAME="${OPTARG}"
            ;;
        t)
            TEMPLATE="${OPTARG}"
            ;;
        p)
            CREDENTIALS="${OPTARG}"
            ;;
        v)
            VARIABLES="${OPTARG}"
            ;;
        c)
            CONTAINER="${OPTARG}"
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
elif [ "aws2_builder" = "${BUILD_NAME}" ]
  then
    echo "Adding Trust store"
    ADD_TRUST='-v '$(pwd)'/AllTrusted.crt:/etc/pki/tls/certs/AllTrusted.crt'
fi

echo " "
echo "Debug             : ${DEBUG}"
echo "Packer Container  : ${CONTAINER}"
echo "Template          : ${TEMPLATE}"
echo "Build name        : ${BUILD_NAME}"
echo "Credentials file  : ${CREDENTIALS}"
echo "Variables file    : ${VARIABLES}"
echo "Using Trust arg   : ${ADD_TRUST}"
echo " "

#TODO on-error should be changed to 'cleanup' for production and up the 'ssh_handshake_attempts' value to 50 in the template
sudo docker run -it --rm\
    --name promBuilder \
    --env-file=docker.env \
    -v $(pwd):/tmp/prometheus \
    ${ADD_TRUST} \
    -w /tmp/prometheus \
    ${CONTAINER} build \
        $DEBUG \
        -only=${BUILD_NAME} \
        -var-file=${CREDENTIALS} \
        -var-file=${VARIABLES} \
        -on-error=ask \
        ${TEMPLATE}

sudo docker container prune -f