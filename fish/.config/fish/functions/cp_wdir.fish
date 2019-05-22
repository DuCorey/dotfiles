function cp_wdir --description 'Copy file and creates directory if missing.'
    mkdir -p (dirname -- $argv[2]); and cp $argv 
end
