#!/bin/bash

#Update & Upgrade
apt-get update && apt-get upgrade -y
rm README.md

#Install requierements
apt-get install unzip libldns-dev git snapd dnsutils -y

#Ensures that the snapd service is running.
systemctl start snapd

#Install Aquatone
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
unzip aquatone_linux_amd64_1.7.0.zip
rm aquatone_linux_amd64_1.7.0.zip README.md LICENSE.txt
mv aquatone /usr/local/bin/

#Install Chromium for Aquatone
snap install chromium

#Install Amass for recon
snap install amass

#Add /snap/bin to $PATH
echo -e "export PATH=\"$PATH:/snap/bin\"" >> ~/.profile
source ~/.profile

## END
rm install.sh