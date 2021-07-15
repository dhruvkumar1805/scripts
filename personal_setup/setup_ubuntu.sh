#!/bin/bash

sudo echo

# Color setup
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

sudo apt-get update && sudo apt-get upgrade

sudo apt install git wget figlet -y

# clone Akhil Narang's script
git clone https://github.com/akhilnarang/scripts

# install apps

read -rp "Install Apps (Tg , VS Code , Chrome etc)? y/n " ANS

if [ $ANS == y ]; then
echo -e "$green Installing Apps! \n $white"
#install telegram
sudo apt install telegram-desktop

#install VS Code
sudo snap install --classic code

# download chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# install chrome
sudo dpkg -i google-chrome-stable_current_amd64.deb
fi

if [ $ANS == n ]; then
echo -e "$yellow Skipping The Installation Of Apps! \n $white"
echo -e "$green Setting Up Environment \n $white"
bash scripts/setup/android_build_env.sh
figlet "Done!"

fi
