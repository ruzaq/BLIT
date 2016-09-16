#!/bin/bash -x
export DISPLAY=:0
TPTHEFT_PIDFILE="/tmp/tp-theft.pid"

## stop dunst notifications?
#/usr/bin/killall -SIGUSR1 dunst &

# forget all sudo cached credentials
/usr/bin/sudo -K

# turn on TP-theft protection
/usr/bin/sudo /usr/local/bin/tp-theft.pl -a &

# log TP-theft PID 
echo $! >${TPTHEFT_PIDFILE}

# switch to i3 WM workspace that is not in use and has zero possibility you'd write
# confidential information (like password) blindly into some application (i.e. to an IRC)
/usr/bin/i3-msg workspace 99 && /usr/bin/i3lock -i /home/ruza/tmp/images/Terminal.png -f

## screen was unlocked so kill an antitheft script
/usr/bin/sudo /bin/kill -9 $(cat $TPTHEFT_PIDFILE)

