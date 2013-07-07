#!/bin/bash

iptables --flush
iptables --delete-chain

iptables --table nat --flush
iptables --table nat --delete-chain
iptables --table mangle --flush
iptables --table mangle --delete-chain

iptables --policy INPUT DROP
iptables --policy FORWARD DROP
iptables --policy OUTPUT DROP

iptables --new-chain LOGDROP
iptables --append LOGDROP -m limit --limit 15/minute --limit-burst 10  --jump LOG --log-prefix "INVALID : " --log-level 4
iptables -A LOGDROP --jump DROP

iptables --append INPUT --protocol tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags SYN,FIN SYN,FIN --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags SYN,RST SYN,RST --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags FIN,RST FIN,RST --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ACK,FIN FIN --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ACK,URG URG --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ACK,PSH PSH --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ALL ALL --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ALL NONE --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ALL FIN,PSH,URG --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ALL SYN,FIN,PSH,URG --jump LOGDROP
iptables --append INPUT --protocol tcp -m tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG --jump LOGDROP

iptables --append INPUT --protocol tcp ! --syn -m state --state NEW --jump LOGDROP

iptables --append INPUT --in-interface lo --jump ACCEPT
iptables --append OUTPUT --out-interface lo --jump ACCEPT

iptables --append INPUT --protocol tcp -m state --state ESTABLISHED,RELATED --jump ACCEPT
iptables --append INPUT --protocol udp -m state --state ESTABLISHED,RELATED --jump ACCEPT
iptables --append OUTPUT -m state --state NEW,ESTABLISHED,RELATED --jump ACCEPT



#: http/https
iptables --append OUTPUT --protocol tcp --dport 80 --jump ACCEPT
iptables --append OUTPUT --protocol tcp --dport 443 --jump ACCEPT

#: ping
iptables --append OUTPUT --protocol icmp --jump ACCEPT

#: irc
iptables --append OUTPUT --protocol tcp --dport 6667 --jump ACCEPT



iptables --append INPUT -m limit --limit 15/minute --limit-burst 10 --jump LOG --log-prefix "INPUT DROP : "
iptables --append FORWARD -m limit --limit 15/minute --limit-burst 10 --jump LOG --log-prefix "FORWARD DROP : "
iptables --append OUTPUT -m limit --limit 15/minute --limit-burst 10 --jump LOG --log-prefix "OUTPUT DROP : "

iptables --append INPUT --jump DROP
iptables --append FORWARD --jump DROP
iptables --append OUTPUT --jump DROP
