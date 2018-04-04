#!/bin/bash

set -eo pipefail

CACHE_DIR=~/.aws/cli/cache

# Make sure we get or refresh the temporary credentials
aws sts get-caller-identity > /dev/null

if [ -n "$AWS_PROFILE" ]; then
  source_profile="$(aws configure get source_profile --profile "$AWS_PROFILE" || echo "")"
  if [ -n "$source_profile" ]; then
    role_arn="$(aws configure get role_arn --profile "$AWS_PROFILE")"
    mfa_serial="$(aws configure get mfa_serial --profile "$AWS_PROFILE")"
    cache_file=${CACHE_DIR}/$(echo -n "{\"RoleArn\": \"$role_arn\", \"SerialNumber\": \"$mfa_serial\"}" | openssl dgst -sha1 | cut -d " " -f 2).json
    AWS_DEFAULT_REGION=$(aws configure get region --profile "$source_profile" || echo "")
    AWS_ACCESS_KEY_ID="$(cat $cache_file | jq -r ".Credentials.AccessKeyId")"
    AWS_SECRET_ACCESS_KEY="$(cat $cache_file | jq -r ".Credentials.SecretAccessKey")"
    AWS_SECURITY_TOKEN="$(cat $cache_file | jq -r ".Credentials.SessionToken")"
    AWS_SESSION_TOKEN=$AWS_SECURITY_TOKEN
  else
    AWS_DEFAULT_REGION="$(aws configure get region --profile "$AWS_PROFILE" || echo "")"
    AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id --profile "$AWS_PROFILE" || echo "")"
    AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key --profile "$AWS_PROFILE" || echo "")"
  fi
fi

[ -n "$AWS_DEFAULT_REGION" ] && export AWS_DEFAULT_REGION
[ -n "$AWS_ACCESS_KEY_ID" ] && export AWS_ACCESS_KEY_ID
[ -n "$AWS_SECRET_ACCESS_KEY" ] && export AWS_SECRET_ACCESS_KEY
[ -n "$AWS_SECURITY_TOKEN" ] && export AWS_SECURITY_TOKEN
[ -n "$AWS_SESSION_TOKEN" ] && export AWS_SESSION_TOKEN

exec "$@"
