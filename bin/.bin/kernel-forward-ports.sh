#!/bin/bash
# Forward ports for jupyter kernel in the JSON file of the current folder.
# You can also specify the ssh_control_socket when forwarding the ports.
# Author: Corey Ducharme


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -S)
        ssh_control_socket="$2"
	shift; shift
	;;
    *)
      HOST="$1"
      shift
    ;;
esac
done

FILE=$(find $PWD/ -name "*.json")
FILENUM=$(echo "$FILE" | wc -l)

if [ -z "$FILE" ]; then
    echo "No kernel file found in current dir."
    exit
fi

if [ "$FILENUM" -ne 1 ]; then
    echo "Multiple kernel files found in current dir."
    exit
fi

# Open the socket if we don't have one
if [ -z "${ssh_control_socket+x}" ]; then
    tmp_dir=$(mktemp -d "/tmp/$(basename "$0").XXXXXX")
    ssh_control_socket="$tmp_dir/ssh_control_socket"
    ssh -M -S "$ssh_control_socket" -fnNT "${HOST}" > /dev/null 2>&1
fi


for port in $(cat "${FILE}" | grep '_port' | grep -o '[0-9]\+')
do
    ssh -S "$ssh_control_socket" "${HOST}" -fN -L $port:127.0.0.1:$port > /dev/null 2>&1
done

exit
