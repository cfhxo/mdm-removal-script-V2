#!/bin/sh
cd ~
echo Creating work directory
mkdir mdmscript/
cd mdmscript/
echo Retrieving files
wget https://github.com/ChazzaH014/mdm-removal-script/blob/main/CloudConfigurationDetails.plist
echo Patching MDM Profile
mv CloudConfigurationDetails.plist /var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles
echo Done
