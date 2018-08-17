#!/bin/sh
# Auto rotate screen based on device orientation

# Receives input from monitor-sensor (part of iio-sensor-proxy package)
# Screen orientation and Touchpanal orientation set based on monitor-sensor
# This script should be added to startup applications for the user

# Clear sensor.log so it doesn't get too long over time
> sensor.log

# Launch monitor-sensor and store the output in a variable that can be parsed by the rest of the script
monitor-sensor >> sensor.log 2>&1 &

# Parse output or monitor sensor to get the new orientation whenever the log file is updated
# Possibles are: normal, bottom-up, right-up, left-up
# Light data will be ignored
while inotifywait -e modify sensor.log; do
# Read the last line that was added to the file and get the orientation
ORIENTATION=$(tail -n 1 sensor.log | grep 'orientation' | grep -oE '[^ ]+$')

# Set the actions to be taken for each possible orientation
#This is a bit hacky but it works!
#Tablet display (monitor-sensor) reports orintation bottom-up when displayed in normal landscape please be aware of this.

case "$ORIENTATION" in
normal)
xrandr --output DSI-1 --rotate inverted &&  xinput --set-prop "Silead GSLx680 Touchscreen" --type=float "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1 ;;
bottom-up)
xrandr --output DSI-1 --rotate normal &&    xinput --set-prop "Silead GSLx680 Touchscreen" --type=float "Coordinate Transformation Matrix" 0 0 0 0 0 0 0 0 0;;
right-up)
xrandr --output DSI-1 --rotate right &&     xinput --set-prop "Silead GSLx680 Touchscreen" --type=float "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1;;
left-up)
xrandr --output DSI-1 --rotate left &&      xinput --set-prop "Silead GSLx680 Touchscreen" --type=float "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1;;
esac

done
