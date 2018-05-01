#!/bin/bash

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
./aws_credentials.sh    $ROLE_NAME

#Build the packer machine image
./build-image.sh    -b aws_builder -v packer_var_pac.json

#Remove certs now that we're done
rm -f packer_credentials.json