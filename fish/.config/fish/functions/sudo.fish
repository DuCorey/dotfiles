function sudo -d "Allow for !! in fish for sudo"
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end
