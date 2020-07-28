#!/bin/bash

# Script to download and extract iOS system symbols
# -----------------------------------------------------------------------------------

DEVICEMODEL=$1
OSVERSION=$2
ARCH=$3
if [[ -z $DEVICEMODEL || -z $OSVERSION || -z $ARCH ]];
then
    echo "Missing mandatory arguments: resource and container. "
    echo "Usage: ./downloadSymbols.sh  [device] [version] [architecture]"
	echo "Example: ./downloadSymbols.sh iPhone12,8 latest arm64e"
    exit 1
fi

# create a temporary folder (to be deleted separately after process finished)
mkdir tmp
cd tmp

# download tools
git clone git@github.com:Zuikyo/iOS-System-Symbols.git

# identiy required firmware
# see API description on https://ipsw.me/api/ios/docs/2.1/Firmware
# example https://api.ipsw.me/v2.1/iPhone12,1/latest/info.json

API_URL="https://api.ipsw.me/v2.1/$DEVICEMODEL/$OSVERSION"

FIRMWARE_VERSION=$(curl -s $API_URL/version)
echo "INFO: requested version is $FIRMWARE_VERSION"

FIRMWARE_URL=$(curl -s $API_URL/url)

FIRMWARE_BUILDID=$(curl -s $API_URL/buildid)

# download firmware (ipsw)
#curl $FIRMWARE_URL --output firmware.zip --keepalive-time 2

# unpack firmware
#unzip firmware.zip

# remove archive as we'll work with unpacked version
#rm -f firmware.zip

# identify relevant dmg file (it's the largest), e.g 038-35285-082.dmg
disk=$(du -a * | sort -r -n | head -1 | cut -f2)
echo $disk
echo "INFO: mount disk with iOS system symbols"
# example output of hdiutil attach: /dev/disk3s1  41504653-0000-11AA-AA11-0030654	/Volumes/YukonG17G68.N104N841OS
mountedDiskInfo=$(hdiutil attach $disk | egrep '/Volumes' | head -n1)
echo $mountedDiskInfo
# get first word (= /dev/disk3s1)
mountedDiskIdentifier=$(echo $mountedDiskInfo | awk '{print $1;}')
echo $mountedDiskIdentifier
# get last word (e.g. /Volumes/YukonG17G68.N104N841OS)
mountedDiskVolume=$(echo $mountedDiskInfo | awk '{print $NF}')
echo $mountedDiskVolume

FOLDERNAME=$DEVICEMODEL+$OSVERSION+$ARCH+$FIRMWARE_BUILDID
mkdir $FOLDERNAME

echo "INFO: copy and extract iOS systems .... be patient"
if [ $ARCH = "arm64" ]
then
cp $mountedDiskVolume/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64 $FOLDERNAME
./iOS-System-Symbols/tools/dsc_extractor $FOLDERNAME/dyld_shared_cache_arm64 $FOLDERNAME

rm -f $FOLDERNAME/dyld_shared_cache_arm64
else
cp $mountedDiskVolume/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64e $FOLDERNAME
./iOS-System-Symbols/tools/dsc_extractor $FOLDERNAME/dyld_shared_cache_arm64e $FOLDERNAME

rm -f $FOLDERNAME/dyld_shared_cache_arm64e
fi

echo "INFO: unmount disk with iOS system symbols"
# TODO determine disk name (modifiy mountedDiskIdentifier to get /dev/disk3 from /dev/disk3s1)
hdiutil detach ${mountedDiskIdentifier%"s1"}

echo "INFO: succes :)"
