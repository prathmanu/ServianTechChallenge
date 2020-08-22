#!/bin/bash
terraform init
terraform fmt
terraform validate
terraform apply
echo 'ACR server url'
terraform output acr_server_url
echo 'ACR admin Username'
terraform output acr_admin_username
echo 'ACR admin Password'
terraform output acr_admin_password
echo 'Resource group name'
terraform output resource_groupname
echo 'postgres server name'
terraform output postgress_server_name
echo 'postgres server url'
terraform output postgress_server_url
echo 'postgres  username'
terraform output postgress_server_username
echo 'postgres password'
terraform output postgress_server_password



