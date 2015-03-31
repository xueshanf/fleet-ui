#!/bin/sh

export ETCD_PEER=${ETCD_PEER:-$(/sbin/ip route|awk '/default/ { print $3 }')}
export STATUS_INTERVAL=${STATUS_INTERVAL:-70000}

if [ -f /root/id_rsa ]; then
  eval `ssh-agent -s` && ssh-add /root/id_rsa
fi

/root/fleet-ui/fleet-ui

