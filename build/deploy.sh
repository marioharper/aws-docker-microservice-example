#!/bin/bash
set -e 

cd ./infrastructure/dev

terraform remote config \
  -backend=s3 \
  -backend-config="bucket=volusion-terraform-state-dev" \
  -backend-config="key=aws docker microservice example/terraform.tfstate" 

terraform get
terraform plan
terraform apply
