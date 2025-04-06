#!/bin/bash

# Chatgpt recommended firewall rules

# QUICK FLUSH
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# DEFAULT DROP EVERYTHING
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# LOOPBACK for local ops
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ESTABLISHED / RELATED for response traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# SSH (Port 22)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# FTP (Port 21 + Passive Range)
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 30000:30010 -j ACCEPT

# -- LOGGING (rate limited to prevent spam) --
# Log dropped INPUT packets
iptables -A INPUT -m limit --limit 5/min --limit-burst 10 -j LOG --log-prefix "IPTables-INPUT-Dropped: " --log-level 4

# Log dropped OUTPUT packets
iptables -A OUTPUT -m limit --limit 5/min --limit-burst 10 -j LOG --log-prefix "IPTables-OUTPUT-Dropped: " --log-level 4

# (Packets that hit here after all rules above are dropped & logged)
