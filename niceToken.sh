#!/usr/bin/env bash

#needs:
#TODO: move nice-identity-long-term to a variable.
#note that AWS CLI uses AWS_DEFAULT_PROFILE while AWS SDK uses AWS_PROFILE


#Get initial session token
#$MFA_DEVICE is ARN of the MFA device.

LONG_TERM_PROFILE=$AWS_PROFILE"-long-term"

echo "getting long-term token for $LONG_TERM_PROFILE..."
aws sts get-session-token --serial-number $MFA_DEVICE --profile nice-identity-long-term --token-code $1 --query "Credentials" > ~/.aws/return.json

aws configure set aws_access_key_id "$(jq -r .AccessKeyId < ~/.aws/return.json)" --profile $LONG_TERM_PROFILE
aws configure set aws_secret_access_key "$(jq -r .SecretAccessKey < ~/.aws/return.json)" --profile $LONG_TERM_PROFILE
aws configure set aws_session_token "$(jq -r .SessionToken < ~/.aws/return.json)" --profile $LONG_TERM_PROFILE

#note assume-role ARN is an environment variable: MFA_ASSUME_ROLE
#change role-session-name

COUNTER=0
while [ $COUNTER -lt 12 ]; do
    echo "renewing role token..."
    aws sts assume-role --role-arn $MFA_ASSUME_ROLE --role-session-name jack-test --profile $LONG_TERM_PROFILE --duration-seconds 3600 --query "Credentials" > ~/.aws/short_term_creds.json 

    echo "role token renewed, will expire at $(jq -r .Expiration < ~/.aws/short_term_creds.json)"
    aws configure set aws_access_key_id "$(jq -r .AccessKeyId < ~/.aws/short_term_creds.json)" --profile $AWS_PROFILE
    aws configure set aws_secret_access_key "$(jq -r .SecretAccessKey < ~/.aws/short_term_creds.json)" --profile $AWS_PROFILE
    aws configure set aws_session_token "$(jq -r .SessionToken < ~/.aws/short_term_creds.json)" --profile $AWS_PROFILE

    COUNTER=$[$COUNTER + 1]
    sleep 3540 #59 minutes  
done
