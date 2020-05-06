
# AutoRecon
![Banner](https://zupimages.net/up/19/01/uikg.png)![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)  ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

## Features
- Enum subdomains, create permutation & wildcard removing with [Amass](https://github.com/OWASP/Amass/)
- Find web services and screenshots with[Aquatone](https://github.com/michenriksen/aquatone)

How I use this tool for BugBounty : [My subdomains enumeration process](https://www.jomar.fr/posts/2020/03/en-my-subdomains-enumeration-process/)

![Workflow](https://zupimages.net/up/20/19/cj3p.png)

## Installation
- Installation & Recon tested on Debian 10

Run installer :
```bash
./install.sh
```
If wanted (recommended), configure [Amass](https://github.com/OWASP/Amass/) with the desired API keys by creating a [config.ini](https://github.com/OWASP/Amass/blob/master/examples/config.ini) file.

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

![RunningScript](https://zupimages.net/up/20/19/exzj.png)
## Domain monitoring
The advantage of using amass with the "-dir" option is that it also allows monitoring with a bash script.

For example, you can create a cron task that executes the following content at regular intervals:

```bash
#!/bin/bash

DOMAIN=your-domain.tld

/root/AutoRecon.sh -d $DOMAIN -c /root/Tools/Amass/config.ini

MSG=$(amass track -d $DOMAIN -dir /root/Recon/$DOMAIN/Amass/ | grep 'Found:')

PAYLOAD="payload={\"text\": \"$MSG\"}"
HOOK=https://hooks.slack.com/services/XXXX/XXXX/XXXX

if [ ! -z "$var" ]
then
  curl -X POST --data-urlencode "$PAYLOAD" "$HOOK"
fi
```

![SlackAlert](https://zupimages.net/up/20/19/yozr.png)