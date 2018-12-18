#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename ${BASH_SOURCE[0]}`

cat << HELP_USAGE

Description:
    Compile latex document into pdf. By default employs 'latexmk',
    but 'pdflatex' can also be used with the same options.

Usage: $_FILE_NAME [-h|--help] [--file=<FILE_NAME>] [--aux-dir=<AUX_DIR>]
    [--pdflatex] [--bibtex] [--verbose]

Examples:
    $_FILE_NAME --file=my_main.tex
        Use 'my_main.tex' to produce pdf document with 'latexmk'.

    $_FILE_NAME --bibtex --aux-dir=tmp
        Use bibtex during the process of producing pdf document
        and store all so-generated files in './tmp'.

    $_FILE_NAME --pdflatex
        Use this for the fastest compilation process.
        However, it does not check whether there were modifications
        to the source files.

    $_FILE_NAME --pdflatex --bibtex
        Use 'pdflatex -> bibtex -> pdflatex -> pdflatex ->' to
        produce pdf document. Could be handy if there are issues with
        invoking 'latexmk'.

    $_FILE_NAME --pdflatex --bibtex --aux-dir=tmp --file=my_main.tex
        Do not know why you would choose this option over default.

Options:
    -h|--help
        Show this message.

    --file=<FILE_NAME>
        Defines the name of file for which pdf will be generated.
        Must have markdown file extension ('*.tex').
        Default is 'main.tex'.

    --aux-dir=<AUX_DIR>
        Defines where so-generated auxiliary files are placed.
        Default is './build'.

    --pdflatex
        Use 'pdflatex' to produce pdf document.
        By default 'latexmk' is used.

    --bibtex
        If specified, then compile with 'bibtex' and, therefore,
        will take longer to finish.

    --verbose
        If specified, then 'STDIN' will contain more output text

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

### Utility functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/print_utils.sh"
MAKE_PDF=`basename ${BASH_SOURCE[0]}`

### Default values for variables
FILE="main.tex"
AUX_DIR="build"
ENGINE=1
USE_BIBTEX=0
QUIET="-quiet"

### Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        --file=*)
            FILE="${arg#*=}"
            ;;
        --aux-dir=*)
            AUX_DIR="${arg#*=}"
            ;;
        --pdflatex)
            ENGINE=2
            ;;
        --bibtex)
            USE_BIBTEX=1
            ;;
        --verbose)
            QUIET=""
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

### Define new variables with respect to the parsed arguments


##########################################
#--------          MAIN          --------#
##########################################

if [[ ${FILE} != *.tex ]]; then
    echo "`ERROR $MAKE_PDF` This script can only be used for files with LaTeX extension (*.tex)" >&2
    echo "$FILE" >&2
    exit
fi

if [ ! -f ${FILE} ]; then
    echo "`ERROR $MAKE_PDF` Specified file does not exist." >&2
    echo "$FILE" >&2
    exit
fi

if [[ ($ENGINE == 1) ]]; then
	echo "`INFO $MAKE_PDF` Creating pdf with 'latexmk'"
    if [[ ($USE_BIBTEX == 1) ]]; then
        BIBTEX="-bibtex"
    else
        BIBTEX="-nobibtex"
    fi
    latexmk -pdf $QUIET $BIBTEX -auxdir=$AUX_DIR -outdir=$AUX_DIR $FILE

elif [[ ($ENGINE == 2) ]]; then
    echo "`INFO $MAKE_PDF` Creating pdf with 'pdflatex'"
    pdflatex -output-directory=$AUX_DIR $FILE
    if [[ ($USE_BIBTEX == 1) ]]; then
        file_name="${FILE%.*}"
        file_aux="${file_name}.aux"
        bibtex ${AUX_DIR}/${file_aux}
        pdflatex -output-directory=$AUX_DIR $FILE
        pdflatex -output-directory=$AUX_DIR $FILE
    fi
else
	echo "`WARNING $MAKE_PDF` Nothing has been compiled" >&2
fi

echo "`INFO $MAKE_PDF` Success :-)"
