#!/usr/bin/env bash
#
# Flush the memcached cache for the entire system
#

DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source $DIR/load_config.sh

echo "flushing..."
echo "flush_all" | /bin/netcat -q 2 $MEMCACHED_HOST $MEMCACHED_PORT
echo "done."
