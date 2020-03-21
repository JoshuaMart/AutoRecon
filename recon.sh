#!/bin/bash

## VARIABLES
ResultsPath="/root/Recon"
HOOK="https://hooks.slack.com/services/XXXXXXX/XXXXXX/XXXXXXXXXXXXX"
ports="80 81 300 443 591 593 832 981 1010 1311 2082 2087 2095 2096 2480 3000 3128 3333 4243 4567 4711 4712 4993 5000 5104 5108 5800 6543 7000 7396 7474 8000 8001 8008 8014 8042 8069 8080 8081 8088 8090 8091 8118 8123 8172 8222 8243 8280 8281 8333 8443 8500 8834 8880 8888 8983 9000 9043 9060 9080 9090 9091 9200 9443 9800 9981 12443 16080 18091 18092 20720 28017"

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

  ## LAUNCH AMASS (PASSIVE)
  wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-110000.txt -P $ResultsPath/$domain/ > /dev/null 2>&1
  if [ -z "$ac" ]
  then
    amass enum -active -brute -min-for-recursive 1 -d $domain -o $ResultsPath/$domain/domain.txt -w $ResultsPath/$domain/subdomains-top1million-110000.txt > /dev/null 2>&1
  else
    amass enum -active -brute -min-for-recursive 1 -d $domain -config $ac -o $ResultsPath/$domain/domain.txt -w $ResultsPath/$domain/subdomains-top1million-110000.txt > /dev/null 2>&1
  fi

  ## LAUNCH DNSGEN
  echo -e ">> \e[36mDNSGen\e[0m is in progress"
  cat $ResultsPath/$domain/domain.txt | dnsgen - >> $ResultsPath/$domain/domain.txt

  ## SORTS AND REMOVES DUPLICATES
  sort -u $ResultsPath/$domain/domain.txt > $ResultsPath/$domain/domains.txt

  ## CHECK RESULTS WITH SHUFFLEDNS
  echo -e ">> \e[36mShuffleDNS\e[0m is in progress"
  printf "8.8.8.8\n1.1.1.1" > $ResultsPath/resolvers.txt
  shuffledns -d $domain -list $ResultsPath/$domain/domain.txt -r $ResultsPath/resolvers.txt -o $ResultsPath/$domain/shuffledns.txt -silent > /dev/null 2>&1

  ## CLEAN SHUFFLEDNS RESULTS
  grep -Po "([A-Za-z0-9]).*$domain" $ResultsPath/$domain/shuffledns.txt > $ResultsPath/$domain/tmp_domains.txt
  sed 's/\..CNAME.*/ /g' $ResultsPath/$domain/tmp_domains.txt > $ResultsPath/$domain/tmp2_domains.txt
  sed 's/CNAME.*/ /g' $ResultsPath/$domain/tmp2_domains.txt | sort -u > $ResultsPath/$domain/domains_$(date +%F).txt
  
  ## LAUNCH AQUATONE
  echo -e ">> \e[36mAquatone\e[0m is in progress"
  mkdir $ResultsPath/$domain/Aquatone
  cd $ResultsPath/$domain/Aquatone
  cat ../domains_$(date +%F).txt | aquatone -chrome-path /snap/bin/chromium -ports xlarge > /dev/null 2>&1

  ## REMOVE USELESS FILES
  rm $ResultsPath/$domain/domain.txt $ResultsPath/$domain/subdomains-top1million-110000.txt $ResultsPath/resolvers.txt $ResultsPath/$domain/shuffledns.txt
  rm $ResultsPath/$domain/tmp_domains.txt $ResultsPath/$domain/tmp2_domains.txt $ResultsPath/$domain/domains.txt
 
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
  else
    cd $ResultsPath/$domain/
    ls | grep -v monitor | xargs rm -r
  fi
  scan
fi