#!/bin/bash

## VARIABLES
ResultsPath="/root/Recon"
ToolsPath="/root/Tools"

## FUNCTION
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

help() {
  banner
  echo -e "Usage : ./recon.sh -d domain.tld -r -s
      -d  | --domain      (required) : Domain in domain.tld format
      -r  | --recon       (optional) : Search subdomains for the specified domain
      -s  | --scan        (optional) : Scan the specified domain
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
  echo -e "Scan of \e[31m$1\e[0m is in progress"
  mkdir -p $ResultsPath/$domain/$(date +%F)/$1

  ## Nuclei
	echo -e ">> \e[36mNuclei\e[0m is in progress"
	echo -e $1 | httprobe -p http:81 -p https:81 -p https:8443 -p http:8080 -p https:8080 > $ResultsPath/$domain/$(date +%F)/$1/httprobe.txt
  nuclei -l $ResultsPath/$domain/$(date +%F)/$1/httprobe.txt -t "$ToolsPath/nuclei-templates/all/*.yaml" -o $ResultsPath/$domain/$(date +%F)/$1/nuclei.txt > /dev/null 2>&1

  ## GAU
  echo -e ">> \e[36mGAU\e[0m is in progress"
  gau $1 >> $ResultsPath/$domain/$(date +%F)/$1/gau.txt

  ## Hawkraler
	echo -e ">> \e[36mHakrawler\e[0m is in progress"
	echo -e $1 | hakrawler -forms -js -linkfinder -plain -robots -sitemap -usewayback -outdir $ResultsPath/$domain/$(date +%F)/$1/hakrawler | kxss >> $ResultsPath/$domain/$(date +%F)/$1/kxss.txt

  ## ParamSpider
	echo -e ">> \e[36mParamSpider\e[0m is in progress"
	cd $ToolsPath/ParamSpider/
	python3 paramspider.py --domain $1 --exclude woff,css,js,png,svg,jpg -o paramspider.txt > /dev/null 2>&1

  if [ -s $ToolsPath/ParamSpider/output/paramspider.txt ]
  then
    	mv ./output/paramspider.txt $ResultsPath/$domain/$(date +%F)/$1/

      ## GF
      echo -e ">> \e[36mGF\e[0m is in progress"
      mkdir $ResultsPath/$domain/$(date +%F)/$1/GF

      gf xss $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/xss.txt
      gf potential $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/potential.txt
      gf debug_logic $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/debug_logic.txt
      gf idor $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/idor.txt
      gf lfi $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/lfi.txt
      gf rce $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/rce.txt
      gf redirect $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/redirect.txt
      gf sqli $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/sqli.txt
      gf ssrf $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/ssrf.txt
      gf ssti $ResultsPath/$domain/$(date +%F)/$1/paramspider.txt >> $ResultsPath/$domain/$(date +%F)/$1/GF/ssti.txt
  fi

  ## SubDomainizer
  echo -e ">> \e[36mSubDomainizer\e[0m is in progress"
  python3 $ToolsPath/SubDomainizer/SubDomainizer.py -u $1 -o $ResultsPath/$domain/$(date +%F)/$1/SubDomainizer.txt > /dev/null 2>&1

  ## RM ParamSpider output
  if [ -s $ToolsPath/ParamSpider/output/paramspider.txt ]
  then
    rm $ToolsPath/ParamSpider/output/paramspider.txt
  fi
}

main() {
  banner

  if [ -v recon ] ## IF SCAN OPTION WAS PROVIDE
  then
    echo -e "Recon is in \e[31mprogress\e[0m, take a coffee"

    ## ENUM SUB-DOMAINS
    echo -e ">> \e[36mAmass\e[0m is in progress"

    ## LAUNCH AMASS
    mkdir -p $ResultsPath/$domain/Amass
    wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -P $ResultsPath/$domain/ > /dev/null 2>&1
    
    if [ -z "$ac" ]
    then
      amass enum -active -o $ResultsPath/$domain/$(date +%F)/domains_tmp.txt -d $domain -brute -w $ResultsPath/$domain/deepmagic.com-prefixes-top50000.txt -dir $ResultsPath/$domain/Amass > /dev/null 2>&1
    else
      amass enum -active -o $ResultsPath/$domain/$(date +%F)/domains_tmp.txt -d $domain -brute -w $ResultsPath/$domain/deepmagic.com-prefixes-top50000.txt -config $ac -dir $ResultsPath/$domain/Amass > /dev/null 2>&1
    fi

    ## LAUNCH GITHUB-SUBDOMAINS.PY
    echo -e ">> \e[36mGithub-Subdomains.py\e[0m is in progress"
    python3 /root/Tools/Github-Subdomains/github-subdomains.py -d $domain >> $ResultsPath/$domain/$(date +%F)/domains_tmp.txt

    ## SORT & REMOVE DUPLICATES ON DOMAINES.TXT
    cat $ResultsPath/$domain/$(date +%F)/domains_tmp.txt | sort -u > $ResultsPath/$domain/$(date +%F)/domains.txt
    rm $ResultsPath/$domain/$(date +%F)/domains_tmp.txt
    
    ## LAUNCH AQUATONE
    echo -e ">> \e[36mAquatone\e[0m is in progress"
    mkdir $ResultsPath/$domain/$(date +%F)/Aquatone
    cd $ResultsPath/$domain/$(date +%F)/Aquatone
    cat ../domains.txt | aquatone -chrome-path /snap/bin/chromium -ports xlarge > /dev/null 2>&1

    ## REMOVE USELESS FILES
    rm $ResultsPath/$domain/deepmagic.com-prefixes-top50000.txt
  fi

  if [ -v scan ] ## IF SCAN OPTION WAS PROVIDE
  then
    if [ -v recon ] ## IF RECON OPTION WAS PROVIDE
    then
      while read line; do
        scan $line
      done < $ResultsPath/$domain/$(date +%F)/domains.txt
    else
      scan $domain
    fi
  fi

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
        -s|--scan)
            scan=true
            ;;
        -r|--recon)
            recon=true
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
    mkdir -p $ResultsPath/$domain/$(date +%F)
  fi
  main
fi