# TechChallenge App Deployment
## Architecture
![Architecture](/Images/TechChallenge.png)


A simple architecture adopted here to show case the automation.

## Prerequisite for Deployment

Following tools to be installed

1. az cli 
2. terraform 
3. bash(preferably mac or linux)
4. Docker Installed

## Steps to be carried out for deployment

1. Clone following repositories from Github
https://github.com/prathmanu/ServianTechChallenge.git   and

https://github.com/servian/TechChallengeApp.git

2. Copy webappdeploy.sh from ServianTechChallenge  to TechChallengeApp root folder. 
3. Edit db.go file in db folder line 44 and line 50 sslmode=disable to sslmode=require to allow ssl to postgres server
![Edit](/Images/edit.png)
4. open a command shell and change directory to ServianTechChallenge folder
5. run bash deploy.sh commad,it will open a browser to log into your azure subscription for az cli. This will create all the azure services for you.
6. Once the previous script completed, change directory to TechChallengeApp folder and run bash webdeploy.sh This will again ask you to log in to your Azure subscription.
7. This script will ask for a user input to delete a firewall rule created for seeding the data base from local machine dont forget to press y and enter
![input](/Images/input.png)
8. Once completed wait for some time( will take 3-4 minutes to warm up) for the web app to load(it will take 2-3 minutes to load the page, waiting for the web app to warm up)


## All the steps in command shell
![Step1](/Images/step1.png)
![Step2](/Images/step2.png)

## Result
![webApp](/Images/webapp.png)

## How to clean up
1. Change directory to ServianTechChallenge Directory
2. Run 'terraform destroy' command

## Factors not considered 

1. Terraform state is local not remote(to avoid complexity)
2. Terraform module

## How it works

1. deploy.sh creates web app, postgres sql , key vault and container registry, web app  and keeps all the specific information in key vault.(here terraform apply --auto-approve is enabled to avoid user interation which is similar to a CI pipeline scenario). Web app will be configured to run from container from ACR Image and all the environment variables will be set in app settings.
2. webappdeploy.sh will fetch all the info from key vault , build docker image push to container registry, run data base seed from local machine  

##  Another Approach: Infrastructure pipeline using Azure DevOps
### changes 
Add remote state store in main.tf file 

```json
 terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "mytfstateaccount"
    container_name       = "tfcontainer"
  }
```
  Added Azure-pipelines.yml to the repo 
  https://github.com/prathmanu/ServianTechChallenge/blob/master/azure-pipelines.yml

  ### Build Pipe line 

![pipeline](/Images/AzDevOps2.png)
  ### Validate Stage
  
  ![Validate](/Images/AzDevOps3.png)
   ### Deploy Stage
  
  ![Deploy](/Images/AzDevOps4.png)
