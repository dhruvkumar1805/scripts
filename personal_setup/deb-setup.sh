#!/bin/bash

sudo echo

# Colour setup
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
txtbld=$(tput bold)             #  bold
bldred=${txtbld}$(tput setaf 1) #  bold red
bldgrn=${txtbld}$(tput setaf 2) #  bold green
bldblu=${txtbld}$(tput setaf 4) #  bold blue
txtrst=$(tput sgr0)             #  reset

echo "$grn Updating and installing packages. . . $txtrst"
sudo apt-get update -qq && sudo apt-get upgrade -y && sudo apt install git -y

# Git credentials
echo "$grn Setting Up Git Credentials. . . $txtrst"
git config --global user.name "DhruvChhura"
git config --global user.email "dhruvchhura18@gmail.com"

# clone Akhil Narang's scripts
mkdir tmp
git clone https://github.com/akhilnarang/scripts tmp/scripts

echo "$grn Running Environment Setup Script. . .$txtrst"
bash tmp/scripts/setup/android_build_env.sh

echo "$grn Installing Apps. . .$txtrst"
sudo snap install telegram-desktop
sudo snap install --classic code
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P tmp/
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo "$grn Cleaning. . .$txtrst"
rm -rf tmp/

echo "$grnbld Done! $txtrst"
