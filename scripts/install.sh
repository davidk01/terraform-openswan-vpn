#!/bin/bash -exu
if ! (grep $(hostname) /etc/hosts); then
  echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts
fi

sudo apt-get update
sudo apt-get install -y openswan

# Disable re-directs

for vpn in /proc/sys/net/ipv4/conf/*; do
  echo 0 | sudo tee $vpn/accept_redirects
  echo 0 | sudo tee $vpn/send_redirects
done

# Make sure the settings stick

if ! (grep '^net.ipv4.ip_forward = 1' /etc/sysctl.conf); then
  echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
fi

if ! (grep '^net.ipv4.conf.all.accept_redirects = 0' /etc/sysctl.conf); then
  echo 'net.ipv4.conf.all.accept_redirects = 0' | sudo tee -a /etc/sysctl.conf
fi

if ! (grep '^net.ipv4.conf.all.send_redirects = 0' /etc/sysctl.conf); then
  echo 'net.ipv4.conf.all.send_redirects = 0' | sudo tee -a /etc/sysctl.conf
fi

sudo sysctl -p

# NOTE: Make sure MTU on right side is set to 1399 because for some reason shit doesn't
# work otherwise. Which is to say that when going from us-west-1 to us-west-2 we need
# to set the MTU on us-west-1 side to 1399 because there are way too many NATs and routes
# on us-west-2 side and that seems to mess things up

# Firewall rules

iptables -F
iptables -F -t nat

# We need masquerading to avoid setting up further routes and tunnels

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
