#!/bin/bash

# ROM
FNAME="" # This is for filename
ROM="" # This is for build
DEVICE="" # Device Codename
TARGET="" # Build type: user/userdebug/eng
VERSION="" # Android version

# TELEGRAM BOT
CHATID="" # Fill Chat Id Of Telegram Group/Channel
API_BOT="" # Fill API Id Of Bot From BotFater On Telegram

# Init
FOLDER="${PWD}"
OUT="${FOLDER}/out/target/product/$DEVICE"
ERROR_LOG="out/error.log"

# Setup Telegram Env
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"
}

# Setup transfer.sh
up(){
	curl --upload-file $1 https://transfer.sh/
}

# CleanUp
cleanup() {
    if [ -f "$OUT"/*2021*.zip ]; then
        rm "$OUT"/*2021*.zip
    fi
    if [ -f "$ERROR_LOG" ]; then
        rm "$ERROR_LOG"
    fi
    if [ -f log.txt ]; then
        rm log.txt
    fi
}

# Upload Build
upload() {
     if [ -f out/target/product/$DEVICE/*2021*zip ]; then
	zip=$(up out/target/product/$DEVICE/*2021*zip)
	md5sum=$(md5sum "$OUT"/*2021*zip | awk '{print $1}')
	size=$(ls -sh "$OUT"/*2021*zip | awk '{print $1}')
	echo " "
	echo "zip"
	END=$(TZ=Asia/Kolkata date +"%s")
 	DIFF=$(( END - START ))
	tg_post_msg  "<b>Build took *$((DIFF / 60))* minute(s) and *$((DIFF % 60))* second(s)</b>%0A%0A<b>Rom: </b> <code>$FNAME</code>%0A<b>Date: </b> <code>$BUILD_DATE</code>%0A<b>Size: </b> <code>$size</code>%0A<b>Md5sum: </b> <code>$md5sum</code>%0A<b>Link: </b> <code>$zip</code>" "$CHATID"
	tg_error "log.txt" "$CHATID"
     fi
}

# Build
build() {
	source build/envsetup.sh
	lunch "$ROM"_"$DEVICE"-"$TARGET"
	make bacon | tee log.txt
}

# Checker
check() {
    if ! [ -f "$OUT"/*2021*.zip ]; then
        END=$(TZ=Asia/Kolkata date +"%s")
	DIFF=$(( END - START ))
        tg_post_msg "$FNAME Build for $DEVICE <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!" "$CHATID"
	tg_post_msg "Check log below" "$CHATID"
        tg_error "$ERROR_LOG" "$CHATID"
    else
        upload
    fi
}

# Let's start
BUILD_DATE="$(TZ=Asia/Kolkata date)"
START=$(TZ=Asia/Kolkata date +"%s")
tg_post_msg "<b>STARTING BUILD</b>%0A%0A<b>Rom: </b> <code>$FNAME</code>%0A<b>Device: </b> <code>$DEVICE</code>%0A<b>Target: </b> <code>$TARGET</code>%0A<b>Version: </b> <code>$VERSION</code>%0A<b>Build Start: </b> <code>$BUILD_DATE</code>" "$CHATID"

cleanup
build
check
