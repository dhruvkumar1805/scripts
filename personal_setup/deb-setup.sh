#!/bin/bash

sudo echo

# Color setup
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

sudo apt-get update && sudo apt-get upgrade

sudo apt install git wget figlet -y

# Git credentials
echo -e "$green Setting Up Git Credentials \n $white"
git config --global user.name "DhruvChhura"
git config --global user.email "dhruvchhura18@gmail.com"

# clone Akhil Narang's scripts
mkdir tmp
git clone https://github.com/akhilnarang/scripts tmp/scripts

echo -e "$green Running Environment Setup Script \n $white"
bash tmp/scripts/setup/android_build_env.sh

echo -e "$green Installing Apps! \n $white"
sudo snap install telegram-desktop
sudo snap install --classic code
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo -e "$green Cleaning! \n $white"
rm -rf tmp

echo -e "$green Done! \n $white"
