#!/bin/sh
NM=nmap
IP_REG='[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}'
CIDR_REG=$(printf "%s/[0-9]{1,3}" $IP_REG)
FNAME=nmap_$(date '+%s')
TMP=/tmp
DEFLINE=a
FLAGS=' '
TIM='-T4'
TIMEOUT=120
HOST_TMP=host
BCAST=1
EXPL_TIMEOUT=60
EXPL_STR="--script http-brute --script-args unpwdb.timelimit=$EXPL_TIMEOUT
	--script telnet-brute --script-args unpwdb.timelimit=$EXPL_TIMEOUT"
GET_SCRIPTS=1
MY_IP=0

# Show intro
echo "Starting automap..."

# Parse command line options
echo "Options:"
while [ $# -gt 0 ]; do
	key="$1"
	case $key in
		-f)FLAGS="$FLAGS -F";echo "Fast scan";shift 1;;
		-b)BCAST=0;echo "Broadcast-only scan";shift 1;;
		-s)FLAGS="$FLAGS -sV";echo "Version scan";shift 1;;
		-v)FLAGS="$FLAGS -sV --script=./my_vulners.nse";echo "Vulners scan (run ./get_vulners.sh first)";shift 1;;
		-d)FLAGS="$FLAGS --script default and safe";echo "Discovery script scan";shift 1;;
		-e)FLAGS="$FLAGS $EXPL_STR";echo "Password exploitation";shift 1;;
		-g)GET_SCRIPT=0;echo "Auto script download";shift 1;;
		*)shift;;
	esac
done
echo "--------"

# Run get_script.sh if selected
if [ $GET_SCRIPTS ]; then
	echo 'Running auto script download...'
	./get_scripts.sh
	echo 'Auto script download done'
fi

# Check for WSL
if [ -x "$(command -v nmap.exe)" ]; then
	echo 'Detected WSL, using nmap.exe...'
	echo ' '
	NM=nmap.exe
	HOST_TMP=host
fi

# Find default network interface
echo 'Finding default interface...'
NLINES=$(ip r | wc -l)
if [ $NLINES -eq 1 ]; then
	DEFLINE=$(ip r)
	echo "1 line"
else
	DEFLINE=$(ip r | grep default)
fi
IFACE=$(echo $DEFLINE | grep -o "dev .*" | awk '{print $2}')
printf 'Found default interface [%s]\n' $IFACE

# Find default network range
echo 'Finding default network...'
IP_RANGE=$(ip -o -f inet addr | grep $IFACE | grep -Eo $CIDR_REG)
MY_IP=$(echo $IP_RANGE | grep -Eo $IP_REG)
FLAGS="$FLAGS --exclude $MY_IP"
printf 'Found default network [%s]\n' $IP_RANGE
printf 'Found user ip [%s], will exclude from scan\n\n' $MY_IP

# Start host discovery
echo 'Starting host discovery...'
if [ $BCAST -eq 1 ]; then
	echo "Starting full net scan with timeout of $TIMEOUT sec..."
	timeout $TIMEOUT $NM -oG $HOST_TMP -sn $TIM $IP_RANGE | grep -Fq "."
fi
echo "Starting mDNS scan..."
$NM -oN $HOST_TMP --append-output --script=broadcast-dns-service-discovery | grep -Fq "."
echo "Starting broadcast ping scan..."
$NM -oN $HOST_TMP --append-output --script=broadcast-ping | grep -Fq "."

# Filter host data
HOST_LIST="${HOST_TMP}_list"
cat $HOST_TMP | grep "Address=\|IP:\|Status: Up" | grep -Eo $IP_REG | sort -u > $HOST_LIST
echo "Host discovery done, $(cat $HOST_LIST | wc -l) hosts found."
echo ""

# Start the scan
echo "Starting final scan..."
set -x
$NM $TIM $FLAGS -iL $HOST_LIST -oX $FNAME.xml -oN $FNAME.txt
set +x

# End and clean up
printf "Output saved to %s.txt and %s.xml\n" $FNAME $FNAME
