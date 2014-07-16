#!/usr/bin/env bash
#
# Start a celery worker
#

DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source $DIR/load_config.sh

concurrency=2
if [ $# -ge 1 ]; then
	concurrency=$1
fi

queue=celery
if [ $# -ge 2 ]; then
	queue=$2
fi

user=$SERVER_USER

# TODO: run as a background process with a higher log level
celery_cmd="source $VENV_DIR/bin/activate; builtin cd $SRC_DIR; $VENV_DIR/bin/celery worker -B -A $PROJECT_NAME -Q $queue --loglevel=info --concurrency=$concurrency"

set -x
sudo rm -f $SRC_DIR/celerybeat-schedule
if [[ $USER == $user ]]; then
	"$celery_cmd"
else
	sudo -u $user bash -c "$celery_cmd"
fi
