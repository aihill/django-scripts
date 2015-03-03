#!/usr/bin/env bash
#
# This flushes the site-wide cache
#

DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source $DIR/load_config.sh

$VENV_DIR/bin/python $SRC_DIR/manage.py clear_cache
