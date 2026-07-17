#!/bin/bash
clear

websc=https://raw.githubusercontent.com/zakiii20211/NINJA/main

#delete file
rm -f /usr/local/bin/add-xvless
rm -f /usr/local/bin/trial-xvless
# download script
cd /usr/local/bin
wget -O mxray.sh "https://raw.githubusercontent.com/zakiii20211/NINJA/main/xray/mxray.sh" && chmod +x mxray.sh
wget -O trial-xvless "${websc}/script/lifetime/upgrade/trial-xvless.sh" && chmod +x trial-xvless
cd
clear
