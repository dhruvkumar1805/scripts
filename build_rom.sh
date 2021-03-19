#!/bin/bash

# COLOURS

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

# LUNCH
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

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to build , check this for logs<code>error.log</code>"
}

# BEGIN COMPILATION!
. build/envsetup.sh
echo -e "$green Starting Build....... \n $white"
tg_post_msg "Starting Build ....." "$CHATID"
lunch $LUNCH
mka bacon | tee logs.txt
echo -e "$green Build Finished \n $white"
tg_post_msg "Build Finished..." "$CHATID"

		ZIP="out/target/product/ysl/*zip"

                if [ -f "$ZIP" ]; then
                echo -e "$green << Build completed ...... >> \n $white"
        else
                echo -e "$red << Failed To Build Some Targets , Build Failed .__. EXITING.... >>$white"

        fi

                # Upload the ROM to google drive else transfer.sh!
                                echo -e "Uploading ROM to Google Drive using gdrive CLI ..."
                                # In some cases when the gdrive CLI is not set up properly, upload fails.
                                # In that case upload it to transfer.sh itself

                tg_post_msg "Uploading Build....." "$CHATID"

                                if ! gdrive upload --share -p 1-2KH9G_xwIQ9dqkBirrWl2rd2mBON0aF $ZIP ; then
                                echo -e "\nAn error occured while uploading to Google Drive."
                                echo "Uploading ROM zip to transfer.sh..."
                                tg_post_msg "Build Uploaded....: $(curl -sT $ZIP https://transfer.sh/"$(basename $ZIP)")" $CHATID
                        else

                        url=$(echo $ZIP | cut -d / -f5)
                        tg_post_msg "Build Uploaded..... https://rums.dhruv.workers.dev/Rums/$url?rootId=0AMdva1bKNVXjUk9PVA" $CHATID

                        fi
