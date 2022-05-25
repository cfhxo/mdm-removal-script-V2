#!/bin/sh
cd ~
mkdir mdmscript/
cd mdmscript/
wget https://github.com/ChazzaH014/mdm-removal-script/blob/main/CloudConfigurationDetails.plist
mv CloudConfigurationDetails.plist /var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles

