#!/bin/bash

## VARIABLES
ResultsPath="/root/Recon"
HOOK="https://hooks.slack.com/services/XXXX/XXXXX"
ports="80 81 300 443 591 593 832 981 1010 1311 2082 2087 2095 2096 2480 3000 3128 3333 4243 4567 4711 4712 4993 5000 5104 5108 5800 6543 7000 7396 7474 8000 8001 8008 8014 8042 8069 8080 8081 8088 8090 8091 8118 8123 8172 8222 8243 8280 8281 8333 8443 8500 8834 8880 8888 8983 9000 9043 9060 9080 9090 9091 9200 9443 9800 9981 12443 16080 18091 18092 20720 28017"

## FUNCTION
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

help() {
  banner
  echo -e "Usage : ./recon.sh -d domain.tld -m
      -d | --domain  (required) : Launch passive scan (Amass & DnsGen)
      -m | --monitor (optional) : Launch monitoring (Port scanning & Slack alerting)
  "
}

banner() {
  echo -e "
                _        _____                      
     /\        | |      |  __ \                     
    /  \  _   _| |_ ___ | |__) |___  ___ ___  _ __  
   / /\ \| | | | __/ _ \|  _  // _ \/ __/ _ \| '_ \ 
  / ____ \ |_| | || (_) | | \ \  __/ (_| (_) | | | |
 /_/    \_\__,_|\__\___/|_|  \_\___|\___\___/|_| |_|
 "
}

scan() {
  banner
  echo -e "Recon is in \e[31mprogress\e[0m, take a coffee"

  ## ENUM SUB-DOMAINS
  echo -e ">> \e[36mAmass\e[0m is in progress"

  ## LAUNCH AMASS (PASSIVE)
  wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-110000.txt -P $ResultsPath/$domain/ > /dev/null 2>&1
  amass enum -passive -d $domain -o $ResultsPath/$domain/passive.txt > /dev/null 2>&1
  amass enum -active -brute -min-for-recursive 1 -d $domain -o $ResultsPath/$domain/active.txt -p 80,443 -w $ResultsPath/$domain/subdomains-top1million-110000.txt > /dev/null 2>&1

  ## COMBINE RESULTS OF AMASS PASSIVE & ACTIVE
  cat $ResultsPath/$domain/passive.txt $ResultsPath/$domain/active.txt > $ResultsPath/$domain/domain.txt

  ## LAUNCH DNSGEN
  cat $ResultsPath/$domain/domain.txt | dnsgen - >> $ResultsPath/$domain/domain.txt

  ## SORTS AND REMOVES DUPLICATES
  sort $ResultsPath/$domain/domain.txt | uniq > $ResultsPath/$domain/domains.txt

  ## CHECK RESULTS WITH MASSDNS
  echo -e ">> \e[36mMassDNS\e[0m is in progress"
  printf "8.8.8.8\n1.1.1.1" > $ResultsPath/resolvers.txt
  massdns -r $ResultsPath/resolvers.txt -t A -o S -w $ResultsPath/$domain/massdns.txt $ResultsPath/$domain/domains.txt > /dev/null 2>&1 

  ## CLEAN MASSDNS RESULTS
  grep -Po "([A-Za-z0-9]).*$domain" $ResultsPath/$domain/massdns.txt > $ResultsPath/$domain/tmp_domains.txt
  sed 's/\..CNAME.*/ /g' $ResultsPath/$domain/tmp_domains.txt > $ResultsPath/$domain/tmp2_domains.txt
  sed 's/CNAME.*/ /g' $ResultsPath/$domain/tmp2_domains.txt | sort | uniq > $ResultsPath/$domain/domains_$(date +%F).txt
  
  ## LAUNCH AQUATONE
  echo -e ">> \e[36mAquatone\e[0m is in progress"
  mkdir $ResultsPath/$domain/Aquatone
  cd $ResultsPath/$domain/Aquatone
  cat ../domains_$(date +%F).txt | aquatone -chrome-path /snap/bin/chromium -ports xlarge > /dev/null 2>&1

  ## REMOVE USELESS FILES
  rm $ResultsPath/$domain/passive.txt $ResultsPath/$domain/active.txt $ResultsPath/$domain/subdomains-top1million-110000.txt $ResultsPath/resolvers.txt
  rm $ResultsPath/$domain/tmp_domains.txt $ResultsPath/$domain/tmp2_domains.txt $ResultsPath/$domain/domains.txt $ResultsPath/$domain/massdns.txt

  if [ -v monitor ] ## IF MONITOR OPTION WAS PROVIDE
  then
    echo -e ">> \e[36mMonitoring\e[0m process is in progress"
    if [ ! -d "$ResultsPath/$domain/monitor" ];then
      mkdir $ResultsPath/$domain/monitor
    fi

    cp $ResultsPath/$domain/domains_$(date +%F).txt $ResultsPath/$domain/monitor/domains_new.txt
    
    if [ -f "$ResultsPath/$domain/monitor/domains_old.txt" ]; then
      diff $ResultsPath/$domain/monitor/domains_old.txt $ResultsPath/$domain/monitor/domains_new.txt > $ResultsPath/$domain/monitor/changes.txt
      cat $ResultsPath/$domain/monitor/changes.txt | grep '> ' | sed 's/> //g' > $ResultsPath/$domain/monitor/tmp.txt

      while read p; do
        for port in $ports; do
          timeout 1 bash -c "echo >/dev/tcp/$p/$port" && (echo "$port" >> open_ports.txt) || (echo "port $port is closed" > /dev/null 2>&1)
        done
        cat $ResultsPath/$domain/monitor/open_ports.txt | tr '\n' ',' > $ResultsPath/$domain/monitor/open_ports2.txt
        ## SEND SLACK ALERT
        MSG="{\"text\":\"New subdomains $p with open ports :"$(cat $ResultsPath/$domain/monitor/open_ports2.txt)"\"}"
        curl -X POST -H 'Content-type: application/json' --data "$MSG" $HOOK

        rm $ResultsPath/$domain/monitor/open_ports.txt $ResultsPath/$domain/monitor/open_ports2.txt
      done <$ResultsPath/$domain/monitor/tmp.txt
      ## RM OLD FILE & MOVE NEW FILE (THIS SCAN) TO OLD (FOR NEXT COMPARISON
      cat $ResultsPath/$domain/monitor/domains_old.txt >> $ResultsPath/$domain/monitor/domains_new.txt
      cat $ResultsPath/$domain/monitor/domains_new.txt | sort | uniq > mv $ResultsPath/$domain/monitor/domains_tmp.txt
      rm $ResultsPath/$domain/monitor/tmp.txt $ResultsPath/$domain/monitor/changes.txt $ResultsPath/$domain/monitor/domains_old.txt $ResultsPath/$domain/monitor/domains_new.txt
      mv $ResultsPath/$domain/monitor/domains_tmp.txt $ResultsPath/$domain/monitor/domains_old.txt
      
    else ## CASE IF IT'S THE FIRST SCAN WITH "-m" OPTION, MOVE NEW FILE (THIS SCAN) TO OLD (FOR NEXT COMPARISON)
      mv $ResultsPath/$domain/monitor/domains_new.txt $ResultsPath/$domain/monitor/domains_old.txt
    fi
  fi
 
  echo -e "\n=========== Recon is \e[32mfinish\e[0m ==========="
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
        -m|--monitor)
            monitor=true
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
    mkdir $ResultsPath/$domain
  else
    cd $ResultsPath/$domain/
    ls | grep -v monitor | xargs rm -r
  fi
  scan
fi