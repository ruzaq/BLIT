#!/bin/bash

USER_DBUS_PROCESS_NAME="gconfd-2"
export NOTIFY_SEND_BIN="/usr/bin/notify-send"

# get pid of user dbus process
DBUS_PID="$(ps ax | grep $USER_DBUS_PROCESS_NAME | grep -v grep | awk '{ print $1 }')"

# get DBUS_SESSION_BUS_ADDRESS variable
export DBUS_SESSION="$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$DBUS_PID/environ | sed -e s/DBUS_SESSION_BUS_ADDRESS=//)"
