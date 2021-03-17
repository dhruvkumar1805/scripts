#!bin/bash

sudo apt-get update
sudo apt-get install git

#Setting up build environment with akhilnarang script

git clone https://github.com/akhilnarang/scripts && cd scripts && bash setup/android_build_env.sh && cd ..

#Ccache

export USE_CCACHE=1
export USE_CCACHE_EXEC=$(command -v ccache)
ccache -M 50G
