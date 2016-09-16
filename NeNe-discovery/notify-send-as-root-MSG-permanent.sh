#!/bin/bash -x
#
# This script shows how to send a libnotify message
# to a specific user.
#
# It looks for a process that was started by the user and is connected to dbus.
# process to determine DBUS_SESSION_BUS_ADDRESS
NOTIFY_USER=ruza
TIME="$(date +%H:%M:%S)"
NOTIFY_SEND_BIN="/usr/bin/notify-send"
#PARAMS="$3"

. /usr/local/bin/dbus-find-session.sh

#TITLE="$(echo $1|tr -d \')"
#MESSAGE="$(echo $2|tr -d \')"
TITLE="$1"
MESSAGE="$2"

# send notify
DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION su -s /bin/bash -c "$NOTIFY_SEND_BIN -t 0 \"${TITLE}\" \"${MESSAGE}\"" ${NOTIFY_USER}

#/usr/bin/logger "${NOTIFY_USER} notified: ${TITLE}: ${MESSAGE}"
