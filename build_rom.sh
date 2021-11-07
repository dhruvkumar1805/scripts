#!/bin/bash

# Build info.
ROM_NAME="" # Name of the ROM you are compiling e.g. LineageOS
LUNCH="" # Lunch command e.g. lineage_ysl-userdebug
MAKE_TARGET="" # Compilation target. e.g. bacon or bootimage
USE_BRUNCH="" # yes|no Set to yes if you need to use brunch to build else no for lunch and bacon
CHATID="" # Your telegram group/channel chatid
API_BOT="" # Your HTTP API bot token

# Setup Telegram Env
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"

message() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"
}

# Exit if not specified
if [[ $LUNCH == "" ]] || [[ $USE_BRUNCH == "" ]] || [[ $MAKE_TARGET == "" ]] || [[ $API_BOT == "" ]] || [[ $CHATID == "" ]] || [[ $ROM_NAME == "" ]]; then
	echo -e "\nBRUH: All commands are not specified! Exiting. . .\n"
	exit 1
fi

DEVICE="$(sed -e "s/^.*_//" -e "s/-.*//" <<< "$LUNCH")"
OUT="$(pwd)/out/target/product/$DEVICE"
ERROR_LOG="out/error.log"

# Setup transfer.sh
up(){
	curl --upload-file $1 https://transfer.sh/
}

# Clean old logs if found
cleanup() {
	if [ -f "$ERROR_LOG" ]; then
		rm "$ERROR_LOG"
	fi
	if [ -f log.txt ]; then
		rm log.txt
	fi
}

# Upload Build
upload() {
	if [ -s out/error.log ]; then
		END=$(TZ=Asia/Kolkata date +"%s")
		DIFF=$(( END - START ))

		read -r -d '' failed <<EOT
        	<b>Build status: Failed</b>%0A<b>Failed in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!</b>%0A%0ACheck log below
EOT
		message "$failed" "$CHATID" > /dev/null
		error "$ERROR_LOG" "$CHATID" > /dev/null
	else
		ZIP_PATH=$(ls "$OUT"/*2021*.zip | tail -n -1)
		END=$(TZ=Asia/Kolkata date +"%s")
		DIFF=$(( END - START ))
		echo -e "\nUploading zip. . .\n"
		zip=$(up $ZIP_PATH)
		md5sum=$(md5sum $ZIP_PATH | awk '{print $1}')
		size=$(ls -sh $ZIP_PATH | awk '{print $1}')

		read -r -d '' final <<EOT
		<b>Build status: Completed</b>%0A<b>Time elapsed: $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)</b>%0A%0A<b>Size:</b> <code>$size</code>%0A<b>MD5:</b> <code>$md5sum</code>%0A<b>Download:</b> <a href="$zip">here</a>
EOT

		message "$final" "$CHATID" > /dev/null
		error "log.txt" "$CHATID" > /dev/null
	fi
}

# Build
build() {
	if [ "$USE_BRUNCH" == yes ]; then
		source build/envssetup.sh
		brunch "$DEVICE" | tee log.txt
	else
		source build/envsetup.sh
		lunch "$LUNCH"
		make "$MAKE_TARGET" | tee log.txt
	fi
}

# Start
START=$(TZ=Asia/Kolkata date +"%s")

read -r -d '' start <<EOT
<b>Build status: Started</b>

<b>Rom:</b> <code>$ROM_NAME</code>
<b>Device:</b> <code>$DEVICE</code>
<b>Source directory:</b> <code>$(pwd)</code>
<b>Make target:</b> <code>$MAKE_TARGET</code>
EOT

message "$start" "$CHATID" > /dev/null

cleanup
build
upload
