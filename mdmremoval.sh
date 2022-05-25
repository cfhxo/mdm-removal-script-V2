{\rtf1\ansi\ansicpg1252\cocoartf2638
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;\red67\green72\blue75;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;\cssrgb\c33380\c35343\c36478;}
\paperw11900\paperh16840\margl1440\margr1440\vieww23120\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 cd ~\
echo Creating work directory. \
mkdir mdmscript/\
cd mdmscript/\
echo Retrieving files.\
wget https://github.com/ChazzaH014/mdm-removal-script/blob/main/CloudConfigurationDetails.plist\
echo Patching MDM Profile.\
mv CloudConfigurationDetails.plist \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec3 /var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles\
echo Done!\
}