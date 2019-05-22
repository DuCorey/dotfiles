function display-external -d "Set the display to the external monitor"
    set xcom0 (xrandr -q | egrep '(HDMI1|VGA1|DP1) connected' | egrep -o '(HDMI1|VGA1|DPI)')
    command xrandr --output $xcom0 --auto --scale 1x1 --output eDP1 --off    
end
