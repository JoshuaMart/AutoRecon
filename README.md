# AutoRecon
![Banner](https://zupimages.net/up/19/01/uikg.png)![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)  ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

## Features
- Enum subdomains with [Amass](https://github.com/OWASP/Amass/)
- Create permutations with [DnsGen](https://github.com/ProjectAnte/dnsgen)
- Check and remove wildcard
- Combination of results, check with [MassDNS](https://github.com/blechschmidt/massdns)
- Scan with [Aquatone](https://github.com/michenriksen/aquatone)
- New subdomains alerts with open ports

![Workflow](https://zupimages.net/up/19/01/pdd2.png)

## Installation
- Installation & Recon tested on Debian 10

Run installer :
```bash
./install.sh
source ~/.bashrc
```
Modify line 5 of ```recon.sh``` and add your slack webhook token
If necessary it is necessary to configure [Amass](https://github.com/OWASP/Amass/) with the desired API keys

## Usage

```bash
./recon.sh -d domain.tld
```

Options :
```bash
-d | --domain  (required) : Launch passive scan (Amass & DnsGen)
-m | --monitor (optional) : Launch monitoring (Port scanning & Slack alerting)
-ac | --amassconfig (optional) : Provide Amass configuration files for better results
-rp | --resultspath (optional) : Defines the output folder
```

![RunningScript](https://zupimages.net/up/19/01/41kr.png)

![SlackAlert](https://zupimages.net/up/19/01/xibo.png)

Place a crontab to execute the script periodically in order to be removed from the new subdomains
```
#Execute recon.sh for domain "domain.tld" each monday at 4:00 AM
0 4 * * 1 /root/recon.sh -d domain.tld -m
```