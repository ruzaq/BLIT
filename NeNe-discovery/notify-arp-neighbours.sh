#!/bin/bash

#. /usr/local/bin/dbus-find-session.sh

#/usr/bin/notify-send -t 0 "$(/usr/local/bin/arp-localnet.sh)"
/usr/local/bin/notify-send-as-root-MSG-permanent.sh LocalNet "$(/usr/local/bin/arp-localnet.sh)"
