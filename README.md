# AutoRecon
![Banner](https://image.noelshack.com/fichiers/2019/03/5/1547806549-ti-banner.png)![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)  ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

## Features
- Enum subdomains with [Amass](https://github.com/OWASP/Amass/)
- Create permutations with [DnsGen](https://github.com/ProjectAnte/dnsgen)
- Combination of results, check with [MassDNS](https://github.com/blechschmidt/massdns)
- Scan with [Aquatone](https://github.com/michenriksen/aquatone)
- New subdomains alerts with open ports

![Workflow](http://image.noelshack.com/fichiers/2019/41/2/1570532619-workflow.png)

## Installation
- Installation & Recon tested on Debian 10

Run installer :
```bash
./install.sh
source ~/.bashrc
```
Modify line 4 & 5 of ```recon.sh``` and add your result path & your slack webhook token

## Usage

```bash
./recon.sh -d domain.tld
```

Options :
```bash
-d | --domain  (required) : Launch passive scan (Amass & DnsGen)
-m | --monitor (optional) : Launch monitoring (Port scanning & Slack alerting)
```

![RunningScript](http://image.noelshack.com/fichiers/2019/41/2/1570533971-runningscript.png)

![SlackAlert](http://image.noelshack.com/fichiers/2019/41/2/1570533971-slackalert.png)