#!/bin/bash

aws s3 rm s3://test.notfound404.click --recursive
rm -rf .terraform
terraform init
terraform destroy -auto-approve