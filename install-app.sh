#!/bin/bash

# Automates install of app dependencies, clones app to instance, and runs app

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash 
. ~/.nvm/nvm.sh
nvm install 16 

npm install -g express-generator 
express
npm install

sudo yum install git
git clone https://gitlab.com/Reece-Elder/devops-m5-nodeproject/
cd devops-m5-nodeproject

node index.js 