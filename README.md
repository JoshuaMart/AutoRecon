# AutoRecon
![Banner](https://image.noelshack.com/fichiers/2019/03/5/1547806549-ti-banner.png)![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)  ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

## Features
- Enum subdomains with [Amass](https://github.com/OWASP/Amass/), [Sublist3r](https://github.com/aboul3la/Sublist3r), [Subfinder](https://github.com/subfinder/subfinder), [Crtsh](http://crt.sh/) & [Certspotter](https://certspotter.com/)
- Combination of results, check with [MassDNS](https://github.com/blechschmidt/massdns)
- Check for TakeOver with [Subjack](https://github.com/haccer/subjack) & [TkoSubs](https://github.com/anshumanbh/tko-subs)
- Screenshot with [GoWitness](https://github.com/sensepost/gowitness) 
- Check CORS with [CORStest](https://github.com/RUB-NDS/CORStest)
- Check open ports with [Masscan](https://github.com/robertdavidgraham/masscan) 
- Creation of an archive and upload with unique link on [Transfer.sh](https://transfer.sh)

![Workflow](http://image.noelshack.com/fichiers/2019/25/4/1561050522-autoreconworkflow.png)

## Installation
- Installation tested on Debian 9 / Kali 2019.1
- Recon tested on Debian 9 / Ubuntu 18.04 / 2019.1

Requierement : [Golang](https://golang.org/doc/install)
```bash
git clone https://github.com/JoshuaMart/AutoRecon
cd AutoRecon
```
Edit the following variables on install.sh & create ToolsDir directories :
```bash
ToolsDIR="/root/Recon/Tools" #Directory where tools was installed
GoPath="/root/go" #Your Go Workspace
```
And the following variables on recon.sh :
```bash
ToolsDIR="/root/Recon/Tools" #Directory where tools was installed
ResultsPath="/root/Recon" #Directory where you want scans results
TransferSH="https://transfer.sh" #Change this if you have you own transfer.sh
subjackDebug="/root/go/src/github.com/haccer/subjack/fingerprints.json" #Subjack bug without this ...
```
Run installer :
```bash
./install.sh
```
Launch Subfinder once and fill in the configuration file :
```bash
/root/Recon/Tools/Subfinder
nano /root/.config/subfinder/config.json
```

## Usage

```bash
./recon.sh -d domain.tld -a -u
```
![screen](http://image.noelshack.com/fichiers/2019/25/5/1561100782-autorecon.png)

Options :
```bash
-d | --domain  (required) : Launch passive scan (Passive Amass, CRT.sh, Certspotter, Subfinder, Subjack, TkoSubs)
-a | --active  (optional) : Launch active scans (Active Amass, Sublist3r, GoWitness, CORStest)
-m | --masscan (optional) : Launch masscan (Can be very long & very aggressive ...)
-u | --upload  (optional) : Upload archive on Transfer.sh
```

**If your internet connection crash with Masscan options, change --rate options to 100 at line 102**
