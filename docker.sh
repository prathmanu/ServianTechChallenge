#!/bin/bash

az login

read -p "Please enter ACR url "  acrurl
read -p "Please enter Resource Group Name "  resourceGroup
read -p "Please enter Postgres Server Name "  postgresServer
read -p "Please enter public Ip to enable access to postgress server "  publicIp
read -p "Please enter postgress server host url "  postgresHost
read -p "Please enter postgress server username "  postgresUsername
read -p "Please enter postgress server password "  postgresPassword


echo "Building the image locally"
docker build . -t techchallengeacr.azurecr.io/techchallengeapp:latest
ID=$(docker images -q techchallengeacr.azurecr.io/techchallengeapp:latest)


echo "Pushing the image to ACR Please login when prompted"
docker login $acrurl
docker push "$acrurl/techchallengeapp:latest"

echo "Setting the firewall rule to allow current ip to run the db seed"
az postgres server firewall-rule create -g $resourceGroup -s $postgresServer -n allowip --start-ip-address $publicIp --end-ip-address $publicIp

echo "Runing the db seed"
docker run -e VTT_DBHOST=$postgresHost -e VTT_DBPASSWORD=$postgresPassword -e VTT_DBUSER="$postgresUsername@$postgresServer" -p 3000:3000 $ID updatedb -s

echo "Deleting the firewall rule created for runing the db feed"
az postgres server firewall-rule delete --name allowip --resource-group $resourceGroup --server-name $postgresServer