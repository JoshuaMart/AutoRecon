
  

# AutoRecon

![Banner](https://zupimages.net/up/19/01/uikg.png)![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg) ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

## Features

- Enum subdomains, create permutation & wildcard removing with [Amass](https://github.com/OWASP/Amass/)
- Search subdomains on github with [Github-Subdomains](https://github.com/gwen001/github-search/blob/master/github-subdomains.py)
- Find web services and screenshots with [Aquatone](https://github.com/michenriksen/aquatone)
-  [Nuclei](https://github.com/projectdiscovery/nuclei) : Configurable targeted scanning based on templates
-  [Gau](https://github.com/lc/gau) : Fetch known URLs from AlienVault's Open Threat Exchange, the Wayback Machine, and Common Crawl for any given domain.
-  [Hakrawler](https://github.com/hakluke/hakrawler) : Simple, fast web crawler
-  [ParamSpider](https://github.com/devanshbatham/ParamSpider) : Mining parameters from dark corners of Web Archives
-  [Gf](https://github.com/tomnomnom/gf) : A wrapper around grep, to help you grep for things
	- With somes GF profiles from [Gf-Patterns](https://github.com/1ndianl33t/Gf-Patterns) and [ParamSpider](https://github.com/devanshbatham/ParamSpider/tree/master/gf_profiles)
-  [SubDomainizer](https://github.com/nsonaniya2010/SubDomainizer) : Designed to find hidden subdomains and secrets present is either webpage, Github, and external javascripts present in the given URL.

![Workflow](https://zupimages.net/up/20/28/mclg.png)

## Installation
- Installation & Recon tested on Ubuntu 20.04

Run installer :
```bash
./install.sh
```

If wanted (recommended), configure [Amass](https://github.com/OWASP/Amass/) with the desired API keys by creating a [config.ini](https://github.com/OWASP/Amass/blob/master/examples/config.ini) file.

Create the file `.tokens` in `/root/Tools/Github-Subdomains/` with one or more github token.

## Usage
```bash
./recon.sh -d domain.tld -r -s -c /root/Tools/Amass/config.ini
```

Options :
```bash
-d | --domain (required) : Domain in domain.tld format
-r | --recon (optional) : Search subdomains for the specified domain
-s | --scan (optional) : Scan the specified domain
-c | --amassconfig (optional) : Provide Amass configuration files for better results
-rp | --resultspath (optional) : Defines the output folder
```

![RunningScript](https://zupimages.net/up/20/28/j650.png)

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
  curl -X POST --data-urlencode "$PAYLOAD"  "$HOOK"
fi
```

![SlackAlert](https://zupimages.net/up/20/19/yozr.png)
