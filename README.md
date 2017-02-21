# aws-auth

AWS authentication wrapper to handle MFA and IAM roles. It's useful for applications which are not able to handle MFA or switch IAM roles.

If you defined your AWS credentials with the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY variables the script will simply pass them through.

If you defined AWS profiles in ~/.aws/credentials and ~/.aws/config the script will handle authentication, get temporary credentials if necessary and expose the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SECURITY_TOKEN variables.

## Dependencies

The AWS cli (>= 1.10.18) and jq must be installed on your system.

```
pip install awscli
```

For installing jq please follow the instructions: https://stedolan.github.io/jq/download/

## Installation

```
sudo curl -s https://raw.githubusercontent.com/alphagov/aws-auth/master/aws-auth.sh -o /usr/local/bin/aws-auth
sudo chmod +x /usr/local/bin/aws-auth
```

## Usage

Simply prepend your command with aws-auth.

E.g. to see the AWS_* environment variables exposed:

```
AWS_PROFILE=some-profile aws-auth env | grep AWS
```

## AWS profile examples

~/.aws/credentials

```
[some-profile]
region=eu-west-1
aws_access_key_id=AKIAI...
aws_secret_access_key=FYd4t...
```

~/.aws/config

```
[profile some-profile-with-role]
source_profile=some-profile
mfa_serial=arn:aws:iam::<AWS account id>:mfa/<IAM username>
role_arn = arn:aws:iam::<AWS account id>:role/<IAM role>
```

## How it works

The script simply calls ```aws sts get-caller-identity``` to handle the whole authentication process with the AWS cli.
Temporary credentials are stored in ~/.aws/cli/cache and are valid for one hour.
