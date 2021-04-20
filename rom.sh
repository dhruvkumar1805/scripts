#!/bin/bash

# ROM
ROMNAME="" # This is for filename
ROM="" # This is for build
DEVICE="" #eg : ysl
TARGET="" # EG: user/userdebug
VERSION="" # Android Version! eg: 11/10

# Init
FOLDER="${PWD}"
OUT="${FOLDER}/out/target/product/$DEVICE"

# TELEGRAM BOT
CHATID="" # Fill Chat Id Of Telegram Group/Channel
TELEGRAM_TOKEN="" # Fill API Id Of Bot From BotFater On Telegram

# Setup Telegram Env
TELEGRAM_FOLDER="${HOME}"/telegram
if ! [ -d "${TELEGRAM_FOLDER}" ]; then
    git clone https://github.com/DhruvChhura/telegram.sh/ "${TELEGRAM_FOLDER}"
fi

TELEGRAM="${TELEGRAM_FOLDER}"/telegram

tg_cast() {
    "${TELEGRAM}" -t "${TELEGRAM_TOKEN}" -c "${CHATID}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

tg_pub() {
    "${TELEGRAM}" -t "${TELEGRAM_TOKEN}" -c "${CHATID}" -T "ROM BUILD COMPLETE" -i "$BANNER" -M \
    "$(
                for POST in "${@}"; do
                        echo "${POST}"
                done
    )"
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
    if [ -f log.txt ]; then
        rm log.txt
    fi
}

# Upload Build
upload() {
     if [ -f out/target/product/$DEVICE/*2021*zip ]; then
		zip=$(up out/target/product/$DEVICE/*2021*zip)
		echo " "
		echo "zip"
    END=$(date +"%s")
    DIFF=$(( END - START ))
    tg_pub  "Build took *$((DIFF / 60))* minute(s) and *$((DIFF % 60))* second(s)!" \
            "--------------------------------------------------------------------" \
            "Rom: ${ROMNAME}" \
            "Date: ${BUILD_DATE}" \
            "Link: ${zip}"
    "${TELEGRAM}" -f log.txt -t "${TELEGRAM_TOKEN}" -c "${CHATID}"

     fi
}

# Build
build() {
    source build/envsetup.sh
    lunch $ROM_$DEVICE-$TARGET
    make bacon | tee log.txt
}

# Checker
check() {
    if ! [ -f "$OUT"/*2021*.zip ]; then
        END=$(date +"%s")
	        DIFF=$(( END - START ))
        tg_cast "${ROMNAME} Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!" \
	        "Check log below"
        "${TELEGRAM}" -f log.txt -t "${TELEGRAM_TOKEN}" -c "${CHATID}"
    else
        upload
    fi
}

# Let's start
BUILD_DATE="$(date)"
START=$(date +"%s")
tg_cast "<b>STARTING ROM BUILD</b>" \
        "ROM: <code>${ROMNAME}</code>" \
        "Device: <code>${DEVICE}</code>" \
        "Version: <code>${VERSION}</code>" \
        "Build Start: <code>${BUILD_DATE}</code>"

cleanup
build
check
