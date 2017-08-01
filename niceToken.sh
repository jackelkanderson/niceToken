#!/usr/bin/env bash


#Get initial session token
#$MFA_DEVICE is ARN of the MFA device.

echo "getting long-term token..."
aws sts get-session-token --serial-number $MFA_DEVICE --profile nice-identity-long-term --token-code $1 > ~/.aws/return.json

aws configure set aws_access_key_id "$(jq -r .Credentials.AccessKeyId < ~/.aws/return.json)" --profile "orch-dev-long-term"
aws configure set aws_secret_access_key "$(jq -r .Credentials.SecretAccessKey < ~/.aws/return.json)" --profile "orch-dev-long-term"
aws configure set aws_session_token "$(jq -r .Credentials.SessionToken < ~/.aws/return.json)" --profile "orch-dev-long-term"

#loop here someday
#note assume-role ARN is an environment variable: MFA_ASSUME_ROLE

COUNTER=0
while [ $COUNTER -lt 2 ]; do
    echo "renewing role token..."

    #Can use --query "Credentials" to drill down into result json json
    #Duration is 900 for test purposes
    aws sts assume-role --role-arn $MFA_ASSUME_ROLE --role-session-name jack-test --profile "orch-dev-long-term" --duration-seconds 3600 > ~/.aws/short_term_creds.json 

    aws configure set aws_access_key_id "$(jq -r .Credentials.AccessKeyId < ~/.aws/short_term_creds.json)" --profile "orch-dev"
    aws configure set aws_secret_access_key "$(jq -r .Credentials.SecretAccessKey < ~/.aws/short_term_creds.json)" --profile "orch-dev"
    aws configure set aws_session_token "$(jq -r .Credentials.SessionToken < ~/.aws/short_term_creds.json)" --profile "orch-dev"

    COUNTER=$[$COUNTER + 1]
    sleep 3600  
done
