#!/bin/bash
az login
terraform init
terraform fmt
terraform validate
terraform apply -auto-approve
echo 'Deployed web app url'
terraform output webapp_url




