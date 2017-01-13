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

terraform destroy --force
