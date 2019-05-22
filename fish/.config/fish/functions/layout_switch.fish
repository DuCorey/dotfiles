#!/bin/fish
# switch between keyboard layouts

# If an explicit layout is provided as an argument, us it.
# Otherwise, select the next layout from the set [us, ca_fr].

if count $argv > /dev/null
   setxkbmap $arvg
else
    set cur_layout (setxkbmap -query | awk 'END{print $2}')
    switch $cur_layout
        case us
	     setxkbmap -layout ca -variant fr > /dev/null
	     dunstify -a "mykbdlayoutswtich" -i keyboard -t 800 -r 2593 -u normal "ca_fr"
	     
        case fr
	     setxkbmap us > /dev/null
	     dunstify -a "mykbdlayoutswtich" -i keyboard -t 800 -r 2593 -u normal "us"
    end
end	    
