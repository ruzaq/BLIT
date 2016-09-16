#!/bin/bash

PIDFILE="/run/wifi-probe-scanner.pid"
WIFI_INTERFACE="wlxra"
UPLINK_WLAN=""
NOW="$(date +%Y-%m-%d--%H:%M:%S)"
#HOOVER_OPTS="--verbose"
MY_PID="$$"

# this is your first wifi device used to connect to Internet. We are detecting your location based on SSID you are connected to on yout first wifi device.
UPLINK_WLAN="${UPLINK_WLAN:-wlp3s0}"
WLAN0_SSID="$(iw dev ${UPLINK_WLAN} info | awk -F' ' '/ssid/ {print $2 }')"

DUMPFILE="/home/LEAKS/wifi/probes/dump-${NOW}-${WLAN0_SSID}.txt"

. /usr/local/bin/dbus-find-session.sh

function airmon_stop {
	MON_IFACES="$(ifconfig -a|grep $(ifconfig -a|grep ${WIFI_INTERFACE}|awk '{print $5}'|sed 's/:/-/g'|tr a-z A-Z)|awk '{print $1}')" 
	for mon in ${MON_IFACES};do
		echo "## Shutting down $mon"
	        sudo airmon-ng stop ${mon} && echo "** Monitoring device ${mon} destroyed"
	done
}

trap ctrl_c INT
function ctrl_c() {
        echo "** Trapped [CTRL-C]"
        airmon_stop
        echo "** ${DUMPFILE} occasionally written"
}

function main_start {
        echo "${MY_PID}" > ${PIDFILE}
        
        sudo ifconfig ${WIFI_INTERFACE} up
        sudo airmon-ng start ${WIFI_INTERFACE} && echo "** Monitoring device for ${WIFI_INTERFACE} started"
        
        touch  ${DUMPFILE} && echo "** dumpfile is ${DUMPFILE}"
        
        sudo /usr/local/bin/hoover.pl --interface mon0 --dumpfile ${DUMPFILE} ${HOOVER_OPTS} | while read LINE
                do
                # echo $LINE
                
                if [[ $LINE == *probe* ]] ; then
                        # notify-send "$(echo \"${LINE}\"|sed 's/.*++//')"
                        #MSG="$(echo \"${LINE}\"|sed 's/.*++//')"
                        # /usr/local/bin/notify-send-as-root-MSG.sh "" "${TITLE}" "${MSG}"
			#export DISPLAY=:0
                        #sudo -s /bin/bash su -c /usr/local/bin/notify-send-as-root-MSG.sh "-u low" "WiFi probe" "${MSG}"
                        # notify-send "${MSG}"
			#DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION /usr/bin/notify-send "Wifi Probe" "$(echo \"${LINE}\"|sed 's/.*++//')"
			DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION /usr/bin/notify-send -u low "$(echo \"${LINE}\"|sed 's/.*++//')"
                fi
        done
}

function main_stop {
       #kill -INT $MY_PID 
       airmon_stop
       kill $MY_PID 
}

case "$1" in
  start)
	#main_stop
        main_start
        ;;
   stop)
        main_stop
        ;;
      *)
        main_start
        ;;
esac
