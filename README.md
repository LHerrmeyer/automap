# automap
A tool to automate nmap scans and exploitation on the local network.

## Command-line options
* `-b` Scan using broadcast (ping and mDNS) only, don't scan through the whole network
* `-f` Fast scan (only scan 100 most common ports instead of 1000, this is nmap -F)
* `-e` Exploitation, guess passwords for HTTP Basic Auth and Telnet. Timeout can be set in script.
* `-v` Vulners scan, run vulners script to search for vulnerabilities on open ports
* `-g` Auto script download, automatically download needed nmap scripts
* `-d` Discovery scan, run discovery scripts (category default and safe)
* `-h`/`--help` Show help menu


## Example outputs

```
logern@DESKTOP-BQQG455:/mnt/c/Users/logan/Documents/prog/automap$ ./amap.sh -s -v -e -d
Starting automap...
Options:
Version scan
Vulners scan (run ./get_vulners.sh first)
Password exploitation
Discovery script scan
--------
Running auto script download...
File ‘my_vulners.nse’ already there; not retrieving.
Auto script download done
Detected WSL, using nmap.exe...

Finding default interface...
Found default interface [wifi0]
Finding default network...
Found default network [192.168.1.68/24]
Found user ip [192.168.1.68], will exclude from scan

Starting host discovery...
Starting full net scan with timeout of 120 sec...
Starting mDNS scan...
WARNING: No targets were specified, so 0 hosts scanned.
Starting broadcast ping scan...
WARNING: No targets were specified, so 0 hosts scanned.
Host discovery done, 27 hosts found.

Starting final scan...
+ nmap.exe -T4 -sV -sV --script=./my_vulners.nse --script http-brute --script-args unpwdb.timelimit=60 --script telnet-brute --script-args unpwdb.timelimit=60 --script default and safe --exclude 192.168.1.68 -iL host_list -oX nmap_1641436745.xml -oN nmap_1641436745.txt

Starting Nmap 7.31 ( https://nmap.org ) at 2022-01-05 20:39 Central Standard Time
Warning: 192.168.1.20 giving up on port because retransmission cap hit (6).
Warning: 192.168.1.81 giving up on port because retransmission cap hit (6).
WARNING: Service 192.168.1.1:4444 had already soft-matched rtsp, but now soft-matched sip; ignoring second value
WARNING: Service 192.168.1.1:4567 had already soft-matched rtsp, but now soft-matched sip; ignoring second value

...

Nmap scan report for 192.168.1.10
Host is up (0.00066s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE    VERSION
53/tcp open  tcpwrapped
80/tcp open  tcpwrapped
| http-brute:
|_  Path "/" does not require authentication
|_http-title: NETGEAR RBW30

...

Nmap scan report for 192.168.1.23
Host is up (0.0038s latency).
Not shown: 801 closed ports, 198 filtered ports
PORT      STATE SERVICE    VERSION
62078/tcp open  tcpwrapped

...

Nmap done: 26 IP addresses (24 hosts up) scanned in 387.06 seconds
+ set +x
Output saved to nmap_1641436745.txt and nmap_1641436745.xml
```

## Roadmap

### Done
- Finding network interface
- Detecting host OS
- Gathering from both initial scan, UPnP, and mDNS
- Testing on android
- Exploitation (default passwords)
- Options documentation

### Not done
- More exploitation options

