#!/bin/bash

# update to the lastest version of code
git stash
git pull origin develop

echo "Cloned! Starting to deploy ..."

./deploy.sh
