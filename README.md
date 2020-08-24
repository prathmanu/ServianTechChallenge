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
3. open a command shell and change directory to ServianTechChallenge folder
4. run bash deploy.sh commad,it will open a browser to log into your azure subscription for az cli. This will create all the azure services for you.
5. Once the previous script completed, change directory to TechChallengeApp folder and run bash webdeploy.sh This will again ask you to log in to your Azure subscription.
6. This script will ask for a user input to delete a firewall rule created for seeding the data base from local machine
7. Once completed wait for some time for the web app to load(it will take 2-3 minutes to load the page, waiting for the web app to warm up)