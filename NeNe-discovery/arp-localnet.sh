#!/bin/bash

IFACE_DEFAULT="$(/usr/local/bin/netiface-default.py)"

/usr/bin/arp-scan --interface=${IFACE_DEFAULT} --localnet
