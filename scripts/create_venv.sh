#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    This script creates virtual environment and associated
    ipykernel. Requires conda tools.

Usage: $_FILE_NAME [-h|--help] [-n=|--name=<venv_name>] [-p=|--python=<version>]

Examples:
    $_FILE_NAME -n=my_venv_name
    $_FILE_NAME -n=my_venv_name -p=3.6
    $_FILE_NAME --name=my_venv_name
    $_FILE_NAME --name=my_venv_name --python=3.5

Options:
    -h|--help
        Show this message.

    -n=|--name=<venv_name>
        Name for the virtual environment and ipykernel.

    -p=|--python=<version>
        Version of python interpreter.
        Default is '3.6.5'.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

# Source utility functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/print_utils.sh"

# Default value for variables
python_version="3.6.5"
venv_name=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -n=*|--name=*)
            venv_name="${arg#*=}"
            ;;
        -p=*|--python=*)
            python_version="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

# Check if name of venv has been specified
if [ -z "$venv_name" ]; then
    echo "`ERROR` Name a new venv has not been specified." >&2
    echo "Use '-h' to get help." >&2
    exit 1
fi

echo "`INFO` Creating $venv_name with python=$python_version"

conda create --name ${venv_name} python=${python_version} pip ipykernel

source activate $venv_name

python -m ipykernel install --user --name ${venv_name} --display-name ${venv_name}

source deactivate $venv_name