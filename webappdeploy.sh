#!/bin/bash
az login

#Grabing all the values required for automation from vault. This vault van be used with DevOps tools
AcrAdminPassword=$(az keyvault secret show --name "AcrAdminPassword" --vault-name "ServianVault" --query value)
AcrAdminUsername=$(az keyvault secret show --name "AcrAdminUsername" --vault-name "ServianVault" --query value)
AcrServerUrl=$(az keyvault secret show --name "AcrServerUrl" --vault-name "ServianVault" --query value)
postgresServerName=$(az keyvault secret show --name "postgresServerName" --vault-name "ServianVault" --query value)
postgresServerUsername=$(az keyvault secret show --name "postgresServerUsername" --vault-name "ServianVault" --query value)
postgresServerPassword=$(az keyvault secret show --name "postgresServerPassword" --vault-name "ServianVault" --query value)
postgresServerUrl=$(az keyvault secret show --name "postgresServerUrl" --vault-name "ServianVault" --query value)
ResourceGroupName=$(az keyvault secret show --name "ResourceGroupName" --vault-name "ServianVault" --query value)

# Build Docker Image , Login to ACR and Push the Image to ACR
az acr login --name techchallengeacr
echo "${ResourceGroupName//\"}"
echo "Building the image locally"
docker build . -t "${AcrServerUrl//\"}""/techchallengeapp:latest" 
docker push "${AcrServerUrl//\"}""/techchallengeapp:latest"
ID=$(docker images -q "${AcrServerUrl//\"}""/techchallengeapp:latest")

#Creating the seed data in the db.
read -p "Please enter public Ip to enable access to postgress server "  publicIp
echo "Setting the firewall rule to allow current ip to run the db seed"
az postgres server firewall-rule create -g "${ResourceGroupName//\"}" -s "${postgresServerName//\"}" -n allowip --start-ip-address $publicIp --end-ip-address $publicIp

echo "Runing the db seed"
docker run -e VTT_DBHOST="${postgresServerUrl//\"}" -e VTT_DBPASSWORD="${postgresServerPassword//\"}" -e VTT_DBUSER=""${postgresServerUsername//\"}"@"${postgresServerName//\"}"" -p 3000:3000 $ID updatedb -s

# Cleaning up the firewall setting enable for db connection
echo "Deleting the firewall rule created for runing the db feed"
az postgres server firewall-rule delete --name allowip --resource-group "${ResourceGroupName//\"}" --server-name "${postgresServerName//\"}"

az webapp browse --name techchallenge-AppService --resource-group "${ResourceGroupName//\"}"