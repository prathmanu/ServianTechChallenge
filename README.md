# ServianTechChallenge
## Architecture
![Architecture](/Images/TechChallenge.png)


A simple architecture adopted here to show case the automation.

## Pre-requisite for Deployment

Following tools to be installed

1. az cli 
2. terraform 
3. bash(preferably mac or linux)

## Steps to be carried out for deployment

1. Clone following repositories from Github
https://github.com/prathmanu/ServianTechChallenge.git   and

https://github.com/servian/TechChallengeApp.git

2. Copy webappdeploy.sh from ServianTechChallenge  to TechChallengeApp root folder. 
3. Edit db.go file in db folder line 44 and line 50 sslmode=disable to sslmode=enable to allow ssl to postgres server
3. open a command shell and change directory to ServianTechChallenge folder
4. run bash deploy.sh commad,it will open a browser to log into your azure subscription for az cli. This will create all the azure services for you.
5. Once the previous script completed, change directory to TechChallengeApp folder and run bash webdeploy.sh This will again ask you to log in to your Azure subscription.
6. This script will ask for a user input to delete a firewall rule created for seeding the data base from local machine
7. Once completed wait for some time for the web app to load(it will take 2-3 minutes to load the page, waiting for the web app to warm up)

## Factors not considered 

1. Terraform state is local not remote(to avoid complexity)
2. Terraform module

## How it works

1. deploy.sh creates web app, postgres sql , key vault and container registry, web app  and keeps all the specific information in key vault.(here terraform apply --auto-approve is enabled to avoid user interation which is similar to a CI pipeline scenario). Web app will be configured to run from container from ACR Image and all the environment variables will be set in app settings.
2. webappdeploy.sh will fetch all the info from key vault , build docker image push to container registry, run data base seed from local machine  

