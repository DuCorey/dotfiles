#!/usr/bin/bash
echo -n $(basename $1) | xclip -selection "clipboard"
exit 0
