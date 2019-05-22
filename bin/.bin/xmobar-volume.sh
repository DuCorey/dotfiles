#!/bin/bash
vol=$(amixer get Master | awk -F'[]%[]' '/%/ {if ($(NF-1) == "off") { print "M" } else { print $2 }}' | head -n 1)

case $vol in
    "M"|[0-9]|[0-2][0-9])
	echo '<icon=/home/corey/.xmonad/icons/audio-volume-low.xbm/>'$vol 
	;;
    [3-6][0-9])
	echo '<icon=/home/corey/.xmonad/icons/audio-volume-medium.xbm/>'$vol 
	;;
    [7-9][0-9]|100)
	echo '<icon=/home/corey/.xmonad/icons/audio-volume-high.xbm/>'$vol 
	;;
esac
