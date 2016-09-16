#!/usr/bin/python

import sys
import netifaces as ni

gw_iface = ni.gateways()['default'][ni.AF_INET][1]
print  gw_iface
