#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/corey/.Xauthority

xrandr --output eDP1 --auto --primary
