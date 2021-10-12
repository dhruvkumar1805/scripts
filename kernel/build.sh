#!/bin/bash

CHAT="" # Chatid of your group/acc
API="" # Your HTTP API bot token
CODENAME="" # Your device codename
DEFCONFIG="" # Name of your defconfig to be used
COMPILER="" # Compiler to be used clang/gcc
ANYKERNEL="" # Your AnyKernel repo url
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

MYDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
IMAGE="$MYDIR"/out/arch/arm64/boot/Image.gz-dtb
DATE="$(TZ=Asia/Kolkata date +"%Y%m%d")"

# Telegram env
export BOT_M_URL="https://api.telegram.org/bot$API/sendMessage"
export BOT_D_URL="https://api.telegram.org/bot$API/sendDocument"

message() {
        curl -s -X POST "$BOT_M_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

error() {
        curl --progress-bar -F document=@"$1" "$BOT_D_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to compile the kernel"
}

message "Script Started" "$CHAT"

echo ""

if [ -d AnyKernel ] || [ -d out ] || [ -f logs.txt ];
then
	echo "$grn ---> Cleaning $txtrst"
	rm -rf AnyKernel/ out/ logs.txt
	mkdir -p out
else
	echo "$grn ---> Creating dirs $txtrst"
	mkdir -p out
fi

toolchain() {
if [ "$COMPILER" == clang ]; then
	if [ ! -d "$HOME/proton" ]
	then
	echo "$grn ---> Cloning Proton clang $txtrst"
	git clone --depth=1 https://github.com/kdrag0n/proton-clang "$HOME"/proton
	fi

elif [ "$COMPILER" == gcc ]; then
	if [ ! -d "$HOME/gcc-arm64" ] || [ ! -d "$HOME/gcc-arm" ]
	then
	echo "$grn ---> Cloning EVA gcc $txtrst"
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 "$HOME"/gcc-arm64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm "$HOME"/gcc-arm
	fi
fi
}

compile() {
Start=$(date +"%s")

if [ "$COMPILER" == clang ]; then
	export PATH="$HOME/proton/bin:$PATH"
	export STRIP="$HOME/proton/aarch64-linux-gnu/bin/strip"
	echo "$bldgrn Compiling Kernel! $txtrst"
	message "<b>Compiling Kernel</b>%0A%0A<b>Device: </b><code>$CODENAME</code>%0A<b>Compiler: </b><code>$COMPILER</code>%0A<b>Kernel Version: </b><code>$(make kernelversion)</code>" "$CHAT"
	make O=out ARCH=arm64 "$DEFCONFIG"
	make -j$(nproc --all) CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=out ARCH=arm64 | tee logs.txt

elif [ "$COMPILER" == gcc ]; then
	export PATH="$HOME/gcc-arm64/bin:$HOME/gcc-arm/bin:$PATH"
        export STRIP="$HOME/gcc-arm64/aarch64-elf/bin/strip"
	echo "$bldgrn Compiling Kernel! $txtrst"
	message "<b>Compiling Kernel</b>%0A%0A<b>Device: </b><code>$CODENAME</code>%0A<b>Compiler: </b><code>$COMPILER</code>%0A<b>Kernel Version: </b><code>$(make kernelversion)</code>" "$CHAT"
	make O=out ARCH=arm64 "$DEFCONFIG"
	make -j$(nproc --all) O=out ARCH=arm64 CROSS_COMPILE=aarch64-elf- CROSS_COMPILE_ARM32=arm-eabi- 2>&1 | tee logs.txt
fi

End=$(date +"%s")
Diff=$(($End - $Start))
}

upload(){
	curl --upload-file $1 https://transfer.sh/
}

check() {
if [ -f "$IMAGE" ]; then
	echo "$grn Kernel compiled in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds! $txtrst"
	echo "$txtbld Creating zip $txtrst"
	git clone -qq "$ANYKERNEL" AnyKernel
	cp -r "$IMAGE" AnyKernel
	cd AnyKernel
	mv Image.gz-dtb zImage
	zip -r9 -qq TestKernel_"$CODENAME"_"$DATE".zip *
	echo "$txtbld Uploading kernel zip $txtrst"
	zip=$(upload TestKernel*2021*zip)
	size=$(ls -sh TestKernel*2021*zip | awk '{print $1}')
	md5sum=$(md5sum TestKernel*2021*zip | awk '{print $1}')
	message "<b>Kernel compiled in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds!</b>%0A%0A<b>Build Date: </b><code>$(TZ=Asia/Kolkata date)</code>%0A<b>Device: </b><code>$CODENAME</code>%0A<b>Size: </b><code>$size</code>%0A<b>MD5sum: </b><code>$md5sum</code>%0A<b>Download Link: </b>$zip" "$CHAT"
	cd ..
else
	echo "$red Kernel compilation failed! $txtrst"
	error "logs.txt" "$CHAT"
fi
}

toolchain
compile
check
