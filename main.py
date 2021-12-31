import nmap
import netifaces as ni
import os
import disc
import logging as log

log.basicConfig(level=log.DEBUG)

rules = {
    'exclude_ports': (80,90),
    'include_ports': (23),
    'exclude_hosts': None,
    'include_hosts': None,
}

# Get IP addresses
ip_range = disc.get_ip_nw()
ip_range = "pbs.org scanme.nmap.org"

# Start the scan
log.info(f"Starting nmap scan on network {ip_range}")
host_list = disc.do_scan(ip_range)
log.info("nmap scan finished")
print(host_list.keys())
