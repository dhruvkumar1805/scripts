#!/bin/bash

# COLOURS

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

# DEVICE
CODENAME="" # FILL DEVICE CODENAME

# BUILD
MAKE_TARGET="" # FILL TARGET
LUNCH="" # FILL LUNCH COMMAND

# TELEGRAM BOT

CHATID="" # Fill Chat Id Of Telegram Group/Channel
API_BOT="" # Fill API Id Of Bot From BotFater On Telegram

# Setup Telegram Env

export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

# Setup transfer.sh

up(){
	curl --upload-file $1 https://transfer.sh/
}

# BEGIN COMPILATION!

. build/envsetup.sh
echo -e "$green Starting Build....... \n $white"
tg_post_msg " Build Triggered ......" "$CHATID"

lunch $LUNCH

mka $MAKE_TARGET | tee logs.txt
echo -e "$green Build Finished \n $white"
tg_post_msg " Triggered Build Finished ....." "$CHATID"

	if [ -f out/target/product/$CODENAME/*zip ]; then
		zip=$(up out/target/product/$CODENAME/*zip)
		echo " "
		echo "$zip"
		tg_post_msg "<b>Build Completed</b>%0A%0A<b>Link : </b> <code>"$zip"</code>" "$CHATID"
	else
		tg_post_msg "<b>Build Failed, check the error plox.. lol</b>" "$CHATID"
	fi
