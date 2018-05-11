#!/usr/bin/env bash

while getopts ":r:h?" opt;
do
    case "$opt" in
        r )
                ROLE_NAME="${OPTARG}"
                ;;
        : )
                echo "Option -${OPTARG} requires an argument"
                exit 1
                ;;
        h|? )
                echo " "
                echo "Usage: "
                echo "-r <Role Name>    *Required        default: none"
                echo " "
                exit 0
                ;;
    esac
done

if [[ -z "${ROLE_NAME}" ]]
then
        echo "The builder requires argument -r <role name>."
        exit 1
fi

echo "ROLE_NAME - ${ROLE_NAME}"

#Get aws credentials
../common/get_aws_credentials.sh  $ROLE_NAME

#Start the packer instance(s)
./build-instance.sh  -t apply -b aws -p aws_credentials.json