# AutoRecon
![Banner](https://zupimages.net/up/19/01/uikg.png)![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)  ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

## Features
- Enum subdomains with [Amass](https://github.com/OWASP/Amass/)
- Create permutations with [DnsGen](https://github.com/ProjectAnte/dnsgen)
- Check and remove wildcard with [ShuffleDNS](https://github.com/projectdiscovery/shuffledns)
- Scan with [Aquatone](https://github.com/michenriksen/aquatone)

How I use this tool for BugBounty : [My subdomains enumeration process](https://www.jomar.fr/posts/2020/03/en-my-subdomains-enumeration-process/)

![Workflow](https://zupimages.net/up/20/12/a8re.png)

## Installation
- Installation & Recon tested on Debian 10

Run installer :
```bash
./install.sh
source ~/.bashrc
```
Modify line 5 of ```recon.sh``` and add your slack webhook token
If wanted (recommended), configure [Amass](https://github.com/OWASP/Amass/) with the desired API keys

## Usage

```bash
./recon.sh -d domain.tld -c ~/Tools/Amass/config.ini
```

Options :
```bash
-d  | --domain      (required) : Launch passive scan (Amass & DnsGen)
-c  | --amassconfig (optional) : Provide Amass configuration files for better results
-rp | --resultspath (optional) : Defines the output folder
```

![RunningScript](https://zupimages.net/up/20/12/176d.png)