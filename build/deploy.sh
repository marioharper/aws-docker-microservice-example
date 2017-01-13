#!/bin/bash
set -e 

BASEDIR=$(dirname "$0")
BASEDIR=$PWD/$BASEDIR

export TF_VAR_aws_account_id=$(aws sts get-caller-identity --output text --query 'Account')
export TF_VAR_aws_region=$AWS_DEFAULT_REGION
export app_version_label="default"
export TF_VAR_app_version_label=$app_version_label

cd $BASEDIR/../infrastructure/dev

terraform remote config \
  -backend=s3 \
  -backend-config="bucket=volusion-terraform-state-dev" \
  -backend-config="key=microservice-example/terraform.tfstate" 

terraform get
terraform plan
terraform apply

export version_exists=$(aws elasticbeanstalk describe-application-versions --application-name "microservice-example" --version-labels $app_version_label | grep VersionLabel)

if [ -z "$version_exists" ]; then
  echo "creating $app_version_label app version since it was not found."
  # create app version // terraform should support this soon
  aws elasticbeanstalk create-application-version \
    --application-name "microservice-example" \
    --version-label $app_version_label \
    --source-bundle S3Bucket=$(terraform output app_code_s3_bucket),S3Key=$(terraform output app_code_s3_key) \
    --no-auto-create-application
fi

# deploy app version 
aws elasticbeanstalk update-environment \
  --application-name "microservice-example" \
  --environment-name "Default-Environment" \
  --version-label $app_version_label