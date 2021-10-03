#!/bin/bash

# Colour setup
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

# install packages
echo -e "$green Installing Packages..\n $white"
pkg install git zip tsu wget openssh figlet python p7zip curl build-essential vim -y

# Git credentials
echo -e "$green Setting Up Git Credentials \n $white"
git config --global user.name "DhruvChhura"
git config --global user.email "dhruvchhura18@gmail.com"

echo -e "$yellow Done! \n $white"
