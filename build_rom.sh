#/!bin/bash

# COLOURS

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

# LUNCH
LUNCH=""

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

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to build , check this for logs<code>error.log</code>"
}

# BEGIN COMPILATION!
. build/envsetup.sh
echo -e "\nStarting Build ...\n"
tg_post_msg "Starting Build ....." "$CHATID"
lunch $LUNCH
mka bacon | tee logs.txt
tg_post_msg "Build Finished..." "$CHATID"



		ZIP="out/target/product/ysl/*zip"

		# Upload the ROM to google drive
			echo -e "Uploading ROM to Google Drive using gdrive CLI ..."
	                tg_post_msg "Uploading Build....." "$CHATID"
			file=$(gdrive upload --share -p 1-2KH9G_xwIQ9dqkBirrWl2rd2mBON0aF $ZIP)
			tg_post_msg "Build Uploaded..... : $file" "$CHATID"
