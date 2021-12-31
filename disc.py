import nmap
import netifaces as ni
import os


def get_ip_nw():
    # Get interface from default gateway
    iface = ni.gateways()['default'][ni.AF_INET][1]
    # Get addr from default interface
    addrs = ni.ifaddresses(iface)[ni.AF_INET][0]
    addr = addrs['addr']
    mask = addrs['netmask']
    prefix_len = sum(bin(int(x)).count('1') for x in mask.split('.'))
    return f"{addr}/{prefix_len}"


def do_scan(ip, script="default and safe", args="-F -sV --script default and safe"):
    nm = nmap.PortScanner()
    nm.scan(ip, arguments=args)
    host_list = []
    for host in nm.all_hosts():
        host_list.append({'host':host,'ports':nm[host]['tcp'].keys()})
        print(nm[host]['tcp'].keys())
    return host_list
