#!/bin/bash

# Build info.
ROM_NAME="" # Name of the ROM you are compiling e.g. LineageOS
LUNCH="" # Lunch command e.g. lineage_ysl-userdebug
MAKE_TARGET="" # Compilation target. e.g. bacon or bootimage
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
if [[ $LUNCH == "" ]] || [[ $MAKE_TARGET == "" ]] || [[ $API_BOT == "" ]] || [[ $CHATID == "" ]] || [[ $ROM_NAME == "" ]]; then
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

# Clean old builds/logs if found
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
		END=$(TZ=Asia/Kolkata date +"%s")
		DIFF=$(( END - START ))
		zip=$(up out/target/product/$DEVICE/*2021*zip)
		md5sum=$(md5sum "$OUT"/*2021*zip | awk '{print $1}')
		size=$(ls -sh "$OUT"/*2021*zip | awk '{print $1}')
		echo -e "\nUploading zip. . .\n"

		read -r -d '' final <<EOT
		<b>Build status: Completed</b>%0A<b>Time taken: $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)</b>%0A%0A<b>Size:</b> <code>$size</code>%0A<b>MD5:</b> <code>$md5sum</code>%0A<b>Download:</b> <a href="$zip">here</a>
EOT

		message "$final" "$CHATID" > /dev/null
		error "log.txt" "$CHATID" > /dev/null
	fi
}

# Build
build() {
	source build/envsetup.sh
	lunch "$LUNCH"
	make "$MAKE_TARGET" | tee log.txt
}

# Checker
check() {
    if ! [ -f "$OUT"/*2021*.zip ]; then
	END=$(TZ=Asia/Kolkata date +"%s")
	DIFF=$(( END - START ))

	read -r -d '' failed <<EOT
        <b>Build status: Failed</b>%0A<b>Failed in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!</b>%0A%0ACheck log below
EOT

	message "$failed" "$CHATID" > /dev/null
	error "$ERROR_LOG" "$CHATID" > /dev/null
    else
        upload
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
check
