#!/bin/bash

set -e

export LC_ALL=C

# Initialize pe repository
function init_main_repo() {
    echo -e "\033[01;33m\nInit main repo... \033[0m"
    repo init -u https://github.com/PixelExperience/manifest -b ten-plus --depth=1
}

# Initialize local repository
function init_local_repo() {
    echo -e "\033[01;33m\nCopy local manifest.xml... \033[0m"
    mkdir .repo/local_manifests
    cp build_scripts/local_manifest.xml .repo/local_manifests/local_manifest.xml
}

function sync_repo() {
    echo -e "\033[01;33m\nSync fetch repo... \033[0m"
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
}

function apply_patches() {
    echo -e "\033[01;33m\nApplying patches... \033[0m"
    bash build_scripts/apply-patches.sh patches
}

function envsetup() {
    . build/envsetup.sh
    lunch aosp_pyxis-userdebug
    mka installclean
}

function cleanup() {
    echo -e "\033[01;33m\nClean up old packages... \033[0m"
    if [ -f signed-target_files.zip ] ;then
      rm -rf signed-target_files.zip
    fi

    if [ -f signed-ota_update.zip ] ;then
      rm -rf signed-ota_update.zip
    fi
}

function buildsigned() {
    mka target-files-package otatools -j$(nproc --all)

    echo -e "\033[01;33m\nSigning FULL package... \033[0m"
    ./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs \
        $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
        signed-target_files.zip

    echo -e "\033[01;33m\nSigning OTA package... \033[0m"
    ./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey \
        signed-target_files.zip \
        signed-ota_update.zip

    mkdir -p release
    mv signed-ota_update.zip ./release/PixelExperience_Plus-10.0-"$(date +%Y%m%d)"-UNOFFICIAL-pyxis.zip
}

function buildbacon() {
    mka bacon -j$(nproc --all)
}

## handle command line arguments
read -p "Do you want to sync repo? (y/N) " choice_sync

if [[ $choice_sync == *"y"* ]]; then
    init_main_repo
    init_local_repo
    sync_repo
    apply_patches
fi

echo -e "\033[01;33m\n###### Setting up build environment ###### \033[0m"
envsetup
cleanup

read -p "Do you want a signed build? (y/N) " choice_build

if [[ $choice_build == *"y"* ]]; then
    echo -e "\033[01;33m\n###### Start building with signature ###### \033[0m"
    buildsigned
else
    echo -e "\033[01;33m\n###### Start building with bacon ###### \033[0m"
    buildbacon
fi

echo -e "\033[01;33m\n>>> Enjoy <<< \033[0m"