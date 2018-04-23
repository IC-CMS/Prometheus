#!/bin/bash
# Fetch 24-hour AWS STS session token and set appropriate environment variables.
# See http://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html .
# You must have jq installed and in your PATH https://stedolan.github.io/jq/ .
# Add this function to your .bashrc or save it to a file and source that file from .bashrc .
# This is an adaptation of https://gist.github.com/ddgenome/f13f15dd01fb88538dd6fac8c7e73f8c
# Will only work in aws environments that are using roles
#
# usage: eval $(./fetch_credentials.sh ROLE_NAME)

    pkg=aws-credentials
    if [[ ! $1 ]]
    then
        echo "$pkg: missing required arguments: ROLE_NAME" 1>&2
        exit 1
    fi

    if [[ $AWS_IAM_USER ]]
    then
        iam_user=$AWS_IAM_USER
    else
        iam_user=$(whoami)
        if [[ $? -ne 0 || ! $iam_user ]]
        then
            echo "$pkg: failed to set IAM user: $iam_user"
            exit 1
        fi
    fi

    if [[ $AWS_ACCOUNT ]]
    then
        aws_account=$AWS_ACCOUNT
    else
        aws_account=$(aws sts get-caller-identity --output text --query 'Account')
    fi

    creds_json=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/$1)
    rv="$?"
    if [[ $rv -ne 0 || ! $creds_json ]]
    then
        echo "$pkg: failed to get credentials for user '$iam_user' account '$aws_account': $creds_json" 1>&2
        exit "$rv"
    fi

    jq="jq --exit-status --raw-output"
    ACCESS_KEY_ID=$(echo "$creds_json" | $jq .AccessKeyId)
    rv="$?"
    if [[ $rv -ne 0 || ! $ACCESS_KEY_ID ]]
    then
        echo "$pkg: failed to parse output for ACCESS_KEY_ID: $creds_json" 1>&2
        exit "$rv"
    fi
    SECRET_ACCESS_KEY=$(echo "$creds_json" | $jq .SecretAccessKey)
    rv="$?"
    if [[ $rv -ne 0 || ! $SECRET_ACCESS_KEY ]]
    then
        echo "$pkg: failed to parse output for SECRET_ACCESS_KEY: $creds_json" 1>&2
        exit "$rv"
    fi
    SESSION_TOKEN=$(echo "$creds_json" | $jq .Token)
    rv="$?"
    if [[ $rv -ne 0 || ! $SESSION_TOKEN ]]
    then
        echo "$pkg: failed to parse output for SESSION_TOKEN: $creds_json" 1>&2
        exit "$rv"
    fi
    CREDENTIALS_EXPIRATION=$(echo "$creds_json" | $jq .Expiration)
    rv="$?"
    if [[ $rv -ne 0 || ! $CREDENTIALS_EXPIRATION ]]
    then
        echo "$pkg: failed to parse output for CREDENTIALS_EXPIRATION: $creds_json" 1>&2
        exit "$rv"
    fi

    echo export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
    echo export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
    echo export AWS_SESSION_TOKEN=$SESSION_TOKEN
    echo export AWS_CREDENTIALS_EXPIRATION=$CREDENTIALS_EXPIRATION
