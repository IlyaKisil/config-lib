#!/bin/bash

usage()
{
echo "*****************************************************"
cat << EOF
usage: $0 [-h] [-r] [-p port] [-c name] [-v venv]
This script starts a jupyter lab.
TYPICAL USE:
	$0
	This will start a jupyter lab with automatic selection of the port
BASIC OPTIONS:
   -h			Show this message
   -r			Start jupyter lab on remote machine
   -p [port]	Use port for starting/connecting to, Default is '8888'
   -c [name]	Connect to remote server that runs jupyter lab
   -v [venv]	Activate conda environment prior starting jupyter lab

By Ilya Kisil <ilyakisil@gmail.com>
EOF
echo "*****************************************************"
}

RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BROWN="\033[0;33m"
WHITE="\033[0;0m"

start_type=0
use_venv=0
port="8888"
while getopts ":c:v:p:rh" OPTION
do
    case $OPTION in
        h)
            usage
            exit
            ;;
		v)
			use_venv=1
			venv="${OPTARG:r}"
			;;
		p)
			port="${OPTARG:r}"
			;;
		r)
            start_type=1
            ;;
        c)
            start_type=2
            id="${OPTARG:r}"
            ;;
        \?)
			echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
     esac
done



if [[ ($use_venv == 1) ]]; then
	printf "Activating conda environment: ${GREEN}${venv}${WHITE}\n"
    source deactivate
    source activate "${venv}"
fi

if [[ ($start_type == 0) ]]; then
	printf "Starting Jupyter Lab for local use\n"
	jupyter lab --port="${port}"
elif [[ ($start_type == 1) ]]; then
	printf "Starting Jupyter Lab for remote use\n"
	jupyter lab --no-browser --port="${port}"
elif [[ ($start_type == 2) ]]; then
	printf "Creating a tunnel to the jupyter server running remotely.\n"
	ssh -N -f -L localhost:${port}:localhost:${port} ${id}
	printf "Jupyter Lab hosted on ${GREEN}${id}${WHITE} can be accessed through:\n\n"
	printf "\t${GREEN}http://localhost:${port}/${WHITE} \n\n"
fi
