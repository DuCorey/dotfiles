#!/bin/bash
# Initialize a remote jupyter kernel in a dtach terminal on a HOST.
# You can specify the conda environment to run the kernel in.
# Currently supports R and python kernels.
# You can call this script like this :
# kernel_init --ssh HOST --kernel KERNEL --e|--env CONDA_ENV NAME

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --ssh)
        HOST="$2"
	shift; shift
    ;;
    --kernel)
        case "$2" in
	    --r|R)
	        KERNEL="ir"
		;;
	    --python)
	        KERNEL="python"
		;;
	esac
	shift; shift
    ;;
    -e|--env)
	ENV="$2"
	shift;shift
	;;
    *)
      NAME="$1"
      shift
    ;;
esac
done

# We don't have to clean up after ourselves since we want our socket to stay alive
# on_complete() {
#     ssh -S "$ssh_control_socket" -O exit "$HOST"
#     rm -r "$tmp_dir"
# }
# trap 'on_complete 2> /dev/null' SIGINT SIGHUP SIGTERM EXIT

tmp_dir=$(mktemp -d "/tmp/$(basename "$0").XXXXXX")
ssh_control_socket="$tmp_dir/ssh_control_socket"

# Setup control master
ssh -M -S "$ssh_control_socket" -fnNT "${HOST}"


# Process the data
# Replace sleep with inotifywait if available on the server

sshret=$(ssh -S "$ssh_control_socket" -T "${HOST}" <<ENDSSH
RUNDIR="\$(jupyter --runtime-dir)"
start_files="\$(find \${RUNDIR} -maxdepth 1)"
source activate ${ENV} && dtach -n kernel-${KERNEL}-${NAME} -z -E -r none jupyter kernel --kernel=${KERNEL} &
sleep 3
end_files="\$(find \${RUNDIR} -maxdepth 1)"
KERNEL_FILE="\$(echo " \${start_files}, \${end_files}" | tr ',' '\n' | sort | uniq -u | paste -sd,)"
echo "\${KERNEL_FILE}"
ENDSSH
)

res=$(echo "${sshret}" | grep run)

scp -o 'ControlPath='"$ssh_control_socket" "${HOST}":"${res}" $PWD/

kernel_forward_ports.sh -S "$ssh_control_socket" "${HOST}"

exit
