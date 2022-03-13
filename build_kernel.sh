#!/bin/bash

CHAT="" # Chatid of your group/acc
API="" # Your HTTP API bot token
KERNEL_NAME="" # Name of your kernel
CODENAME="" # Your device codename
DEFCONFIG="" # Name of your defconfig to be used
COMPILER="" # Compiler to be used clang/gcc
ANYKERNEL="" # Your AnyKernel repo url
BRANCH="" # Your AnyKernel repo branch you want to use
HOSST="" # Build host
USEER="" # Build user

# Colour setup
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
txtbld=$(tput bold)             #  bold
bldred=${txtbld}$(tput setaf 1) #  bold red
bldgrn=${txtbld}$(tput setaf 2) #  bold green
bldblu=${txtbld}$(tput setaf 4) #  bold blue
txtrst=$(tput sgr0)             #  reset

if [[ $DEFCONFIG == "" ]] || [[ $COMPILER == "" ]] || [[ $API == "" ]] || [[ $CHAT == "" ]] || [[ $USEER == "" ]] || [[ $HOSST == "" ]] || [[ $CODENAME == "" ]] || [[ $ANYKERNEL == "" ]]; then
	echo -e "$red\nBRUH: Specify all variables! Exiting...$txtrst\n"
	exit 1
fi

MYDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
IMAGE="$MYDIR"/out/arch/arm64/boot/Image.gz-dtb
DATE="$(TZ=Asia/Kolkata date +"%Y%m%d-%H%M")"
ZIP_NAME="$KERNEL_NAME"_"$CODENAME"_"$DATE".zip

# Telegram env
export BOT_M_URL="https://api.telegram.org/bot$API/sendMessage"
export BOT_D_URL="https://api.telegram.org/bot$API/sendDocument"

message() {
        curl -s -X POST "$BOT_M_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

post_build() {
    	curl -F document=@$1 "${BOT_D_URL}" \
        	-F chat_id="$2" \
        	-F "disable_web_page_preview=true" \
        	-F "parse_mode=html"
}

error() {
        curl --progress-bar -F document=@"$1" "$BOT_D_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to compile the kernel"
}

if [ -d out ];
then
	echo -e "$bldgrn\nCleaning and creating dirs...$txtrst"
	rm -rf AnyKernel/ out/ logs.txt > /dev/null
	mkdir -p out
else
	echo -e "$bldgrn\nCreating dirs...$txtrst"
	mkdir -p out
fi

if [ "$COMPILER" == clang ]; then
	if [ ! -d "$HOME/proton" ]
	then
	echo -e "$bldgrn\nCloning Proton clang...$txtrst"
	git clone --depth=1 https://github.com/kdrag0n/proton-clang "$HOME"/proton
	fi

elif [ "$COMPILER" == gcc ]; then
	if [ ! -d "$HOME/gcc-arm64" ] || [ ! -d "$HOME/gcc-arm" ]
	then
	echo -e "$bldgrn\nCloning EVA gcc...$txtrst"
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 "$HOME"/gcc-arm64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm "$HOME"/gcc-arm
	fi
fi

if [[ $1 = "-r" || $1 = "--regen" ]]; then
	make O=out ARCH=arm64 $DEFCONFIG
	cp out/.config arch/arm64/configs/"$DEFCONFIG"
	git add arch/arm64/configs/"$DEFCONFIG"
	git commit -m "arch/arm64: $DEFCONFIG: Regenerate"
	echo -e "$bldgrn\nSuccessfully regenerated $DEFCONFIG $txtrst\n"
	exit
fi

export KBUILD_BUILD_HOST="$HOSST"
export KBUILD_BUILD_USER="$USEER"

Start=$(date +"%s")
if [ "$COMPILER" == clang ]; then
	export PATH="$HOME/proton/bin:$PATH"
	echo -e "$bldgrn\nCompiling Kernel...$txtrst\n"
	message "<b>Compiling Kernel</b>%0A%0A<b>Device: </b><code>$CODENAME</code>%0A<b>Compiler: </b><code>$COMPILER</code>%0A<b>Kernel Version: </b><code>$(make kernelversion)</code>" "$CHAT"
	make O=out ARCH=arm64 "$DEFCONFIG"
	make -j$(nproc --all) CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=out ARCH=arm64 | tee logs.txt

elif [ "$COMPILER" == gcc ]; then
	export PATH="$HOME/gcc-arm64/bin:$HOME/gcc-arm/bin:$PATH"
	echo -e "$bldgrn\nCompiling Kernel...$txtrst\n"
	message "<b>Compiling Kernel</b>%0A%0A<b>Device: </b><code>$CODENAME</code>%0A<b>Compiler: </b><code>$COMPILER</code>%0A<b>Kernel Version: </b><code>$(make kernelversion)</code>" "$CHAT"
	make O=out ARCH=arm64 "$DEFCONFIG"
	make -j$(nproc --all) O=out ARCH=arm64 CROSS_COMPILE=aarch64-elf- CROSS_COMPILE_ARM32=arm-eabi- 2>&1 | tee logs.txt
fi
End=$(date +"%s")
Diff=$(($End - $Start))

if [ -f "$IMAGE" ]; then
	echo -e "$bldgrn\nKernel compiled in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds! $txtrst"
	echo -e "$txtbld\nCreating zip...$txtrst\n"
	git clone -qq "$ANYKERNEL" -b $BRANCH AnyKernel
	cp -r "$IMAGE" AnyKernel
	cd AnyKernel
	mv Image.gz-dtb zImage
	zip -r9 -qq $ZIP_NAME *
	echo -e "$txtbld\nUploading kernel zip on telegram...$txtrst\n"
	size=$(ls -sh $ZIP_NAME | awk '{print $1}')
	md5sum=$(md5sum $ZIP_NAME | awk '{print $1}')

	read -r -d '' zip <<EOT
	<b>Build status: Completed</b>%0A<b>Time elapsed:</b> <i>$(($Diff / 60)) minutes and $(($Diff % 60)) seconds</i>%0A%0A<b>Build Date: </b><code>$(TZ=Asia/Kolkata date)</code>%0A<b>Size: </b><code>$size</code>%0A<b>MD5 Checksum: </b><code>$md5sum</code>
EOT

	message "$zip" "$CHAT"
	post_build "$ZIP_NAME" "$CHAT"
	cd ..
else
	echo -e "$red\nKernel compilation failed! $txtrst\n"
	error "logs.txt" "$CHAT"
fi

