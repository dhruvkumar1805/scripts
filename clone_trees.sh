#!/bin/bash
# Script to clone my trees for ysl!

# EDIT PROPERLY IF U USE IT

read -rp "Enter branch name of device tree (default 11): " DEVICE_BRANCH
read -rp "Enter branch name of remaining trees (default 11): " BRANCH

GITHUB='https://github.com/DhruvChhura'

if [ -z "$BRANCH" ]; then BRANCH="11"; fi
if [ -z "$DEVICE_BRANCH" ]; then DEVICE_BRANCH="11"; fi

echo -e "\n============== CLONING DEVICE TREE ==============\n"
git clone -b $DEVICE_BRANCH $GITHUB/device_xiaomi_ysl device/xiaomi/ysl

echo -e "\n============== CLONING VENDOR TREE ==============\n"
git clone -b $BRANCH $GITHUB/vendor_xiaomi_ysl vendor/xiaomi

echo -e "\n============== CLONING KERNEL ==============\n"
git clone -b $BRANCH $GITHUB/kernel_xiaomi_ysl kernel_xiaomi_ysl

echo -e "\n============== DONE ==============\n"
