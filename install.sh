#!/bin/bash

## VARIABLES
ToolsDIR="/root/Recon/Tools"
GoPath="/root/go"

## SCRIPTS DEPENDANCES
apt-get install git jq zip python3 python3-pip python3-dev unzip -y
pip2 install jsbeautifier
mkdir -p $ToolsDIR

## Install AMASS
wget https://github.com/OWASP/Amass/releases/download/3.0.3/amass_3.0.3_linux_amd64.zip
unzip amass_3.0.3_linux_amd64.zip -d $ToolsDIR/
rm amass_3.0.3_linux_amd64.zip
mv $ToolsDIR/amass_3.0.3_linux_amd64 $ToolsDIR/Amass

## Install MassDNS
git clone https://github.com/blechschmidt/massdns.git $ToolsDIR/MassDNS
mkdir -p $ToolsDIR/MassDNS/bin
cc  -O3 -std=c11 -DHAVE_EPOLL -DHAVE_SYSINFO -Wall -fstack-protector-strong $ToolsDIR/MassDNS/main.c -o $ToolsDIR/MassDNS/bin/massdns

## Install Sublist3r
git clone https://github.com/aboul3la/Sublist3r.git $ToolsDIR/Sublist3r
pip3 install -r $ToolsDIR/Sublist3r/requirements.txt

## Install GoWitness
apt-get install chromium -y
wget https://github.com/sensepost/gowitness/releases/download/1.0.8/gowitness-linux-amd64
mv gowitness-linux-amd64 $ToolsDIR/GoWitness
chmod +x $ToolsDIR/GoWitness

## Install Subjack
go get github.com/haccer/subjack
cp $GoPath/bin/subjack $ToolsDIR/Subjack

## Install TkoSubs
go get github.com/bgentry/heroku-go
go get github.com/gocarina/gocsv
go get github.com/google/go-github/github
go get github.com/olekukonko/tablewriter
go get golang.org/x/net/publicsuffix
go get golang.org/x/oauth2
go get github.com/miekg/dns

git clone https://github.com/anshumanbh/tko-subs.git $ToolsDIR/TkoSubs
go build $ToolsDIR/TkoSubs/tko-subs.go
mv tko-subs $ToolsDIR/TkoSubs/TkoSubs

## Install DirSearch
git clone https://github.com/maurosoria/dirsearch.git $ToolsDIR/DirSearch

## Install CORStest
git clone https://github.com/RUB-NDS/CORStest.git $ToolsDIR/CORStest

## Install LinkFinder
git clone https://github.com/GerbenJavado/LinkFinder.git $ToolsDIR/LinkFinder
cd $ToolsDIR/LinkFinder
python setup.py install

## Install WafW00F
pip install wafw00f

## Install MassCan
apt-get install masscan -y

## END
