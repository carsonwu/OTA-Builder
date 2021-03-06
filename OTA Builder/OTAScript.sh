#!/bin/sh

#  OTAScript.sh
#  OTA Builder
#
#  Created by Carson Wu on 1/12/15.
#  Copyright © 2015 Carson Wu. All rights reserved.

cd "${1}"

echo "*********************************"
echo "Beginning to clean & archive your project"
echo "*********************************"
#xcodebuild archive -project "${2}" -scheme "${3}" -archivePath "${4}"
xcodebuild clean archive -archivePath "${3}" -scheme "${3}"
#xcodebuild -configuration Release -scheme Cityplaza -workspace "Cityplaza.xcodeproj/project.xcworkspace" clean archive -archivePath "/Users/cpuser/cityplaza-treasurehun-ios/keewee/Cityplaza"

echo "*********************************"
echo "Beginning to export your archive"
echo "*********************************"
xcodebuild -exportArchive -archivePath "${4}" -exportPath "${6}" -exportFormat ipa -exportProvisioningProfile "${5}"

#delete the archive file after the export process completed
rm -r "${4}"

#run otabuddy script to generate plist file
echo "*********************************"
echo "Generating plist file"
echo "*********************************"
"${7}" plist "${6}.ipa" "${8}" "${6}.plist"
