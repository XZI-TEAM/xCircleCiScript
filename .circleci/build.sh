#!/usr/bin/env bash
echo "Downloading few Dependecies . . ."
git clone --depth=1 https://github.com/XZI-TEAM/Violet-Kernel merlin
git clone --depth=1 https://github.com/stormbreaker-project/stormbreaker-clang clang

# Main
KERNEL_NAME=Violet-Roselia # IMPORTANT ! Declare your kernel name
KERNEL_ROOTDIR=merlin # IMPORTANT ! Fill with your kernel source root directory.
DEVICE_CODENAME=merlin # IMPORTANT ! Declare your device codename
DEVICE_DEFCONFIG=merlin_defconfig # IMPORTANT ! Declare your kernel source defconfig file here.
CLANG_ROOTDIR=bin/clang # IMPORTANT! Put your clang directory here.
export KBUILD_BUILD_USER=XBIZART # Change with your own name or else.
export KBUILD_BUILD_HOST=XZI-TEAM # Change with your own hostname.
IMAGE=$(pwd)/$DEVICE_CODENAME/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%F-%S")
START=$(date +"%s")
PATH="${PATH}:${CLANG_ROOTDIR}/bin"

# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo xKernelCompiler CircleCI Edition
echo version : rev1.5 - gaspoll
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo CLANG_VERSION = $(${CLANG_ROOTDIR}/bin/clang strombreaker-clang)
echo CLANG_ROOTDIR = ${CLANG_ROOTDIR}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}


function compile() {

   # Your Telegram Group
   curl -s -X POST "https://api.telegram.org/1842769327:AAG6uFKIdqbl71LKSroDi9M14AucCNjIphI/sendMessage" \
        -d chat_id="-1001760033609" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>xKernelCompiler</b>%0ABUILDER NAME : <code>${KBUILD_BUILD_USER}</code>%0ABUILDER HOST : <code>${KBUILD_BUILD_HOST}</code>%0ADEVICE DEFCONFIG : <code>${DEVICE_DEFCONFIG}</code>%0ACLANG VERSION : <code>$(${CLANG_ROOTDIR}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0ACLANG ROOTDIR : <code>${CLANG_ROOTDIR}</code>%0AKERNEL ROOTDIR : <code>${KERNEL_ROOTDIR}</code>"

  cd ${KERNEL_ROOTDIR}
  make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
  make -j$(nproc) ARCH=arm64 O=out \
	CC=${CLANG_ROOTDIR}/bin/clang \
    CROSS_COMPILE=${CLANG_ROOTDIR}/bin/aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=${CLANG_ROOTDIR}/bin/arm-linux-gnueabi-

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi
    git clone --depth=1 $anykernel AnyKernel
	cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}

# Push
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi Note 9 (merlin)</b> | <b>$(${CLANG_ROOTDIR}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"

}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 ${KERNEL_NAME}-${DEVICE_CODENAME}-${DATE}.zip *
    cd ..
}
check
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
