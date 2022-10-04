#!/bin/bash

# Colour setup
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
txtbld=$(tput bold)             #  bold
bldred=${txtbld}$(tput setaf 1) #  bold red
bldgrn=${txtbld}$(tput setaf 2) #  bold green
bldblu=${txtbld}$(tput setaf 4) #  bold blue
txtrst=$(tput sgr0)             #  reset

echo -e "$grn\nUpdating and installing packages. . .$txtrst\n"
sudo apt-get update -qq && sudo apt-get upgrade -y
sudo apt install -qq git automake adb fastboot clang lzip apt-utils gnupg libtool subversion flex bc bison neofetch build-essential zip curl zlib1g-dev gcc gcc-multilib \
                        g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev jq \
                        lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig imagemagick \
                        python2 python3 python3-pip python3-dev python-is-python3 schedtool ccache libtinfo5 \
                        libncurses5 lzop tmux libssl-dev patch patchelf apktool dos2unix git-lfs default-jdk \
                        libxml-simple-perl zram-config -y

sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

# Git
if [[ $USER == "dhruv" ]]; then
echo -e "$grn\nSetting up git. . .$txtrst\n"
git config --global user.name "DhruvChhura"
git config --global user.email "dhruvchhura18@gmail.com"
fi

# Apps
echo -e "$grn\nInstalling Telegram. . .$txtrst\n"
sudo snap install telegram-desktop

echo -e "$grn\nInstalling VS Code. . .$txtrst\n"
sudo snap install --classic code

echo -e "$grn\nInstalling Google Chrome. . .$txtrst\n"
mkdir tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P tmp/
sudo dpkg -i tmp/google-chrome-stable_current_amd64.deb

echo -e "$grn\nCleaning. . .$txtrst\n"
rm -rf tmp/
sudo apt-get purge firefox -y

echo -e "$grn\nDone.$txtrst"
