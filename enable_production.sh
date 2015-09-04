#!/usr/bin/env bash
#
# Convenience script to disable debug mode, enable caching, and
# enable nginx/gunicorn.  The MTURK debug status is not changed.
#
# If you edit this script, also edit enable_debug.sh
#

DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source "$DIR/load_config.sh"

F="$SRC_SETTINGS_DIR/settings_local.py"

sed -r -i \
	-e 's/^\s*DEBUG\s*=.*$/DEBUG = False/' \
	-e 's/^\s*ENABLE_CACHING\s*=.*$/ENABLE_CACHING = True/' \
	"$F"

echo "Relevant variables in $F:"
cat $F | grep "^DEBUG ="
cat $F | grep "^ENABLE_CACHING ="
cat $F | grep "^DEBUG_TOOLBAR ="
cat $F | grep "^MTURK_SANDBOX ="

echo ""
echo "$0: mark site as changed"
sudo touch "$SRC_SETTINGS_DIR/wsgi.py"

bash "$DIR/nginx_make_public.sh"
bash "$DIR/memcached_flush.sh"
sudo supervisorctl restart $PROJECT_NAME
