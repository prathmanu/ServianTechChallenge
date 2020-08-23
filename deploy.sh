#!/bin/bash
terraform init
terraform fmt
terraform validate
terraform apply
echo 'Deployed web app url'
terraform output webapp_url




