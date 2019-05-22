function display-duplicate -d "Duplicates the display onto the external monitor"
    set xcom0 (xrandr -q | egrep '(HDMI1|VGA1|DP1) connected' | egrep -o '(HDMI1|VGA1|DPI)')
    command xrandr --output eDP1 --mode 1920x1080 --output $xcom0 --auto --scale-from 1920x1080 --same-as eDP1 
end
