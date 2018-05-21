#!/usr/bin/env sh

# Terminate already running bar instances
logger -t polybar "Killing existing instances"
killall -q polybar

# Wait until the processes have been shut down
logger -t polybar "Waiting for instances to shut down"
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch main bar
logger -t polybar "Launching bars"
if type "xrandr"; then
    logger -t polybar "xrandr found"
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
       MONITOR=$m polybar --reload main-bar &
    done
else
   polybar --reload main-bar &
fi
