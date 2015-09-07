#!/usr/bin/env bash
#
# Convenience script to enable debug mode, disable caching, and
# enablenginx/gunicorn.  The MTURK debug status is not changed.
#
# If you edit this script, also edit enable_production.sh
#

DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source "$DIR/load_config.sh"

F="$SRC_SETTINGS_DIR/settings_local.py"

sed -r -i \
	-e 's/^\s*DEBUG\s*=.*$/DEBUG = True/' \
	"$F"

echo "Relevant variables in $F:"
cat $F | grep "^DEBUG ="
cat $F | grep "^ENABLE_CACHING ="
cat $F | grep "^DEBUG_TOOLBAR ="
cat $F | grep "^MTURK_SANDBOX ="

bash "$DIR/files_changed.sh"
