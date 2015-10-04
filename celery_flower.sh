#!/usr/bin/env bash
#
# Start the celery flower monitoring tool
#

DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source $DIR/load_config.sh

builtin cd $SRC_DIR
cmd="$VENV_DIR/bin/celery flower -A $PROJECT_NAME --address=127.0.0.1 --port=5555 --logging=none"
echo $cmd
$cmd
