#!/usr/bin/env bash
#
#Instructions
#Using the Terraform Template file for the project
#Create a credentials variable file for the platform desired.
# ex. aws use the fetch_credentials script to create the file from the current Instance Role
#The template file for each platform exists in this Prometheus project

function usage() {
    echo "USAGE: "
    echo "-t <terraform step (plan, apply, destroy, etc)>    *REQUIRED"
    echo "-b <build platform (aws, aws2, or open)>           *REQUIRED"
    echo "-p <password/credential file name>        default = aws_credentials.json"
    echo "-c <packer container>                     default = hashicorp/terraform:latest"
    echo "-d <debug>                                default = N/A"
    echo "-h display this help message"
    return 0
}


DEBUG=''
CONTAINER='hashicorp/terraform:latest'
TF_COMMAND=''
PLATFORM=''
CREDENTIALS='aws_credentials.json'
ADD_TRUST=' '

while getopts ":t:b:p:c:d:h?" opt ;
do
    case "$opt" in
        t)
            TF_COMMAND="${OPTARG}"
            ;;
        b)
            PLATFORM="${OPTARG}"
            ;;
        p)
            CREDENTIALS="${OPTARG}"
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

BUILD_DIR='buildStash_'${PLATFORM}

if [[ -z "${TF_COMMAND}" || -z "${PLATFORM}" ]]
  then
    echo "*** The -t <terraform step> argument is required"
    echo "*** The -b <build platform> argument is required"
    usage
    exit 1
elif [ "aws2" = "${TF_COMMAND}" ]
  then
    echo "Adding Trust store"
    cp AllTrusted.crt ${BUILD_DIR}/AllTrusted.crt
    ADD_TRUST='-v '$(pwd)'/AllTrusted.crt:/etc/pki/tls/certs/AllTrusted.crt'
fi

echo " "
echo "Debug                 : ${DEBUG}"
echo "Platform              : ${PLATFORM}"
echo "Terraform Container   : ${CONTAINER}"
echo "Terraform Step        : ${TF_COMMAND}"
echo "Credentials file      : ${CREDENTIALS}"
echo "Build Directory       : ${BUILD_DIR}"
echo "Using Trust arg       : ${ADD_TRUST}"
echo " "

#Add all terraform resources to the build directory
mkdir -m 755 -p ${BUILD_DIR}
files=("${CREDENTIALS}" "prometheus_main.tf.${PLATFORM}" "provider.tf.${PLATFORM}" "variables.tf")

for file in "${files[@]}"
do
    echo "--- Using ${file} as ${file//.${PLATFORM}} for terraform ${TF_COMMAND}"
    cp ${file} ${BUILD_DIR}/${file//.${PLATFORM}}
done

cd ${BUILD_DIR}

#TODO on-error should be changed to 'cleanup' for production and up the 'ssh_handshake_attempts' value to 50 in the template
#Going to working in the build directory so the paths have to be from there
TERRAFORM="sudo docker run -it --rm \
    --name promTF \
    --env-file=../docker.env \
    --log-driver=none \
    -v $(pwd):/tmp/TF \
    ${ADD_TRUST} \
    -w /tmp/TF \
    ${CONTAINER}"

list=$(${TERRAFORM} workspace list)
#Create workspace if it does not already exist
if [[ ! ${list} =~ (^|[[:space:]])"${PLATFORM}"($|[[:space:]]) ]]
  then
    ${TERRAFORM} workspace new ${PLATFORM}
fi

#Switch to the workspace
${TERRAFORM} workspace select ${PLATFORM}

#Initiate the project
${TERRAFORM} init

#Run Terraform Command
${TERRAFORM} ${TF_COMMAND}

#Clean Up
sudo docker container prune -f
#sudo rm -Rf ${BUILD_DIR}