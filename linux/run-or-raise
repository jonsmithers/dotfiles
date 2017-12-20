#!/bin/sh
# syntax: run-or-raise WM_CLASS_name COMMAND
#   WM_CLASS_name : the WM_CALL_name of the window (from wmctrl -lx output)
#   COMMAND : the command to run if nothing to raise

#logfile=/tmp/$(basename $0).log
#exec > $logfile 2>&1

# get windows ids matching WM_CLASS_name
WINIDS=$(wmctrl -lx | awk '{ if ($3 == "'"$1"'") print $1}')

# run if nothing started. exec will end the script
[ -z "$WINIDS" ] && exec "$2"

# if the window is active, we minimize all the windows of the class
ACTIVEWIN=$(wmctrl -a :ACTIVE: -v 2>&1 | sed -n 's/^Using window: \(.*\)/\1/p')
MINIMIZE=false
if echo "$WINIDS" | grep -q "$ACTIVEWIN"; then
        MINIMIZE=true
fi

for ID in $WINIDS; do
        if $MINIMIZE; then
                xdotool windowminimize "$ID"
        else
                wmctrl -i -a "$ID"
        fi
done
