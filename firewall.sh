#!/bin/bash
set -e

IPT=iptables

# Delete old rules
$IPT -F
$IPT -X

# Default policy
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

# 1) Loopback
$IPT -A INPUT -i lo -j ACCEPT

# 2) Existing connections
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3) SSH from admin IP
$IPT -A INPUT -p tcp -s 192.168.1.10 --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# 4) Web server
$IPT -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
$IPT -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# 5) Ping
$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# 6) Log before drop
$IPT -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables-drop: " --log-level 4

# 7) Drop the rest
$IPT -A INPUT -j DROP
