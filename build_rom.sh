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

		# Upload the ROM to google drive if it's available, else upload to transfer.sh
		if [ -x "$(command -v gdrive)" ]; then
			echo -e "Uploading ROM to Google Drive using gdrive CLI ..."
			# In some cases when the gdrive CLI is not set up properly, upload fails.
			# In that case upload it to transfer.sh itself
			if ! gdrive upload --share -p 1-2KH9G_xwIQ9dqkBirrWl2rd2mBON0aF $ZIP; then
				echo -e "\nAn error occured while uploading to Google Drive."
				echo "Uploading ROM zip to transfer.sh..."
				echo "ROM zip uploaded succesfully: $(curl -sT "$zippath" https://transfer.sh/"$(basename "$zippath")")"
			fi
		else
			echo "Uploading ROM zip to transfer.sh..."
			echo "ROM zip uploaded succesfully: $(curl -sT "$zippath" https://transfer.sh/"$(basename "$zippath")")"
		fi
		echo -e "\n Good bye!"
		exit 0
	else echo -e "\n $MAKE_TARGET compiled succesfully in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) :-) Good bye! \n"; fi
else echo -e "\nERROR OCCURED DURING COMPILATION :'( EXITING ... \n"; exit 1; fi
