function display-extend -d "Extend the display on the direction specified in the argument"
    set xcom0 (xrandr -q | egrep '(HDMI1|VGA1|DP1|DP2) connected' | egrep -o '(HDMI1|VGA1|DPI|DP2)')

    switch (echo $argv)
        case left
       	    command xrandr --output eDP1 --mode 1920x1080 --output $xcom0 --auto --left-of eDP1
	    command feh --bg-scale /home/corey/.wallpaper/doom.png
        case right
            command xrandr --output eDP1 --mode 1920x1080 --output $xcom0 --auto --right-of eDP1
	    command feh --bg-scale /home/corey/.wallpaper/doom.png
    end
    command xmonad --restart
end
