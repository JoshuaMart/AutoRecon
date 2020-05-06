#!/bin/bash

## VARIABLES
ResultsPath="/root/Recon"

## FUNCTION
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

help() {
  banner
  echo -e "Usage : ./recon.sh -d domain.tld -m
      -d  | --domain      (required) : Domain in domain.tld format
      -c  | --amassconfig (optional) : Provide Amass configuration files for better results
      -rp | --resultspath (optional) : Defines the output folder
  "
}

banner() {
  echo -e "
 █████╗ ██╗   ██╗████████╗ ██████╗ ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
███████║██║   ██║   ██║   ██║   ██║██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██║██║   ██║   ██║   ██║   ██║██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
 "
}

scan() {
  banner
  echo -e "Recon is in \e[31mprogress\e[0m, take a coffee"

  ## ENUM SUB-DOMAINS
  echo -e ">> \e[36mAmass\e[0m is in progress"

  ## LAUNCH AMASS
  if [ ! -d "$ResultsPath/$domain/Amass" ];then
    mkdir -p $ResultsPath/$domain/Amass
  fi
  wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -P $ResultsPath/$domain/ > /dev/null 2>&1
  if [ -z "$ac" ]
  then
    amass enum -active -d $domain -brute -w $ResultsPath/$domain/deepmagic.com-prefixes-top50000.txt -dir $ResultsPath/$domain/Amass -o $ResultsPath/$domain/domains_$(date +%F).txt > /dev/null 2>&1
  else
    amass enum -active -d $domain -brute -w $ResultsPath/$domain/deepmagic.com-prefixes-top50000.txt -config $ac -dir $ResultsPath/$domain/Amass -o $ResultsPath/$domain/domains_$(date +%F).txt > /dev/null 2>&1
  fi
  
  ## LAUNCH AQUATONE
  echo -e ">> \e[36mAquatone\e[0m is in progress"
  mkdir $ResultsPath/$domain/Aquatone_$(date +%F)
  cd $ResultsPath/$domain/Aquatone_$(date +%F)
  cat ../domains_$(date +%F).txt | aquatone -chrome-path /snap/bin/chromium -ports xlarge > /dev/null 2>&1

  ## REMOVE USELESS FILES
  rm $ResultsPath/$domain/deepmagic.com-prefixes-top50000.txt
 
  echo -e "=========== Recon is \e[32mfinish\e[0m ==========="
}

while :; do
    case $1 in
        -h|-\?|--help)
            help
            exit
            ;;
        -d|--domain)
            if [ "$2" ]; then
                domain=$2
                shift
            else
                die 'ERROR: "--domain" requires a non-empty option argument.'
            fi
            ;;
        --domain=)
            die 'ERROR: "--domain" requires a non-empty option argument.'
            ;;
        -c|--amassconfig)
            if [ "$2" ]; then
                ac=$2
                shift
            fi
            ;;
        -rp|--resultspath)
            if [ "$2" ]; then
                ResultsPath=$2
                shift
            fi
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac

    shift
done

if [ -z "$domain" ]
then
  help
  die 'ERROR: "--domain" requires a non-empty option argument.'
else
  if [ ! -d "$ResultsPath/$domain" ];then
    mkdir -p $ResultsPath/$domain
  fi
  scan
fi