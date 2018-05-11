#!/bin/bash
# Fetch 24-hour AWS STS session token and set appropriate environment variables.
# See http://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html .
# You must have jq installed and in your PATH https://stedolan.github.io/jq/ .
# This is an adaptation of https://gist.github.com/ddgenome/f13f15dd01fb88538dd6fac8c7e73f8c
# Will only work in aws environments that are using roles
#
# usage:
# To add credentials to the environment variables -> eval $(./get_aws_credentials.sh ROLE_NAME)
# or
# just add to file -> ./get_aws_credentials.sh ROLE_NAME

CREDENTIALS_FILE='aws_credentials.json'
pkg=aws-credentials

if [[ ! $1 ]]
then
    echo "$pkg: missing required arguments: ROLE_NAME" 1>&2
    exit 1
fi

creds_json=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/$1)
rv="$?"
if [[ $rv -ne 0 || ! $creds_json ]]
then
    echo "$pkg: failed to get credentials for the role: $1" 1>&2
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

echo 'AWS_ACCESS_KEY_ID= '$ACCESS_KEY_ID
echo 'AWS_SECRET_ACCESS_KEY= '$SECRET_ACCESS_KEY
echo 'AWS_SESSION_TOKEN= '$SESSION_TOKEN
#echo export AWS_CREDENTIALS_EXPIRATION=$CREDENTIALS_EXPIRATION

cat <<EOF > ${CREDENTIALS_FILE}
{
    "aws_access_key": "$ACCESS_KEY_ID",
    "aws_secret_key": "$SECRET_ACCESS_KEY",
    "aws_session_token": "$SESSION_TOKEN"
}
EOF