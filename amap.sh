#!/bin/sh
NM=nmap
IP_REG='[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}'
CIDR_REG=$(printf "%s/[0-9]{1,3}" $IP_REG)
FNAME=nmap_$(date '+%s')
TMP=/tmp
DEFLINE=a
FLAGS=''
TIM='-T4'

# Parse command line options

while [ $# -gt 0 ]; do
	key="$1"
	case $key in
		-f)FLAGS="$FLAGS -F";shift 1;;
		-b)BCAST=1;shift 1;;
		-v)FLAGS="$FLAGS -sV";shift 1;;
		*)shift;;
	esac
done

# Check for WSL
if [ nmap.exe ]; then
	echo 'Detected WSL, using nmap.exe...'
	NM=nmap.exe
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
printf 'Found default network [%s]\n' $IP_RANGE

# Start host discovery

# Start the scan
echo 'Starting scan...'
set -x
$NM $FLAGS -oX $FNAME.xml -oN $FNAME.txt $IP_RANGE
set +x
echo Output written to $FNAME.xml
