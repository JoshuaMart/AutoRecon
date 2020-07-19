#!/bin/bash

Tools="/root/Tools"
mkdir $Tools

#Update & Upgrade
apt-get update && apt-get upgrade -y

#Install requirements
apt-get install unzip libldns-dev git snapd dnsutils python3 python3-pip jq -y
pip3 install colored

#Ensures that the snapd service is running.
systemctl start snapd

## Install Golang
wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.2.linux-amd64.tar.gz
rm go1.14.2.linux-amd64.tar.gz
echo -e "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile

#Install Aquatone
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
unzip aquatone_linux_amd64_1.7.0.zip
rm aquatone_linux_amd64_1.7.0.zip README.md LICENSE.txt
mv aquatone /usr/local/bin/

#Install Chromium for Aquatone
snap install chromium

#Install Amass for recon
snap install amass

## Install Nuclei
wget https://github.com/projectdiscovery/nuclei/releases/download/v1.1.3/nuclei-linux-amd64.gz
gunzip nuclei-linux-amd64.gz
mv nuclei-linux-amd64 /usr/bin/nuclei
chmod +x /usr/bin/nuclei

cd $Tools
git clone https://github.com/projectdiscovery/nuclei-templates
cd nuclei-templates
mkdir all
cp $(find . -type f -name '*.yaml') all/

## Install Httprobe
go get -u github.com/tomnomnom/httprobe
mv ~/go/bin/httprobe /usr/bin/

## Install Hakrawler
go get github.com/hakluke/hakrawler
mv ~/go/bin/hakrawler /usr/bin/

## Install Kxss
git clone https://github.com/tomnomnom/hacks
cd hacks/kxss
go build main.go
mv main /usr/bin/kxss
cd ../.. && rm -r hacks/

## Install ParamSpider
cd $Tools
git clone https://github.com/devanshbatham/ParamSpider
cd ParamSpider 
pip3 install -r requirements.txt

## Install GF
go get -u github.com/tomnomnom/gf
echo 'source /root/go/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
source ~/.bashrc
cp -r /root/go/src/github.com/tomnomnom/gf/examples ~/.gf
mv ~/go/bin/gf /usr/bin/
cd ~/.gf
cp $Tools/ParamSpider/gf_profiles/* .

## Add more GF patterns
git clone https://github.com/1ndianl33t/Gf-Patterns
mv Gf-Patterns/*.json .
rm -r Gf-Patterns/

## Install GAU
GO111MODULE=on go get -u -v github.com/lc/gau
mv ~/go/bin/gau /usr/bin/

## Install SubDomainizer
cd $Tools
git clone https://github.com/nsonaniya2010/SubDomainizer.git
cd SubDomainizer
pip3 install -r requirements.txt

## Install Github-Subdomains.py
mkdir $Tools/Github-Subdomains/ && cd $Tools/Github-Subdomains
wget https://raw.githubusercontent.com/gwen001/github-search/master/github-subdomains.py

#Add /snap/bin to $PATH
echo -e "export PATH=\"$PATH:/snap/bin\"" >> ~/.profile
source ~/.profile

## END
cd ~
rm install.sh