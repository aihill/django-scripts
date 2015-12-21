#!/bin/bash
#
# Sets up the public nginx/gunicorn server, if not configured
#
# This does the opposite of nginx_make_private.sh.
#

# Load config
DIR="$( builtin cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
source "$DIR/load_config.sh"

##
# static files

bash "$DIR/django_collect_static.sh"

##
# $RUN_DIR directory

echo "Preparing $RUN_DIR directory..."
sudo mkdir -p $RUN_DIR
sudo chown -R $SERVER_USER:$SERVER_GROUP $RUN_DIR
for f in gunicorn nginx-access nginx-error; do
	sudo -u $SERVER_USER touch $RUN_DIR/$f.log
done

##
# gunicorn

if [[ ! -f /etc/supervisor/conf.d/$PROJECT_NAME.conf ]]; then
	echo "Setting up gunicorn..."

	# fill in the config file
	sed -e "s|REPO_DIR|$REPO_DIR|g" \
		-e "s|SRC_DIR|$SRC_DIR|g" \
		-e "s|RUN_DIR|$RUN_DIR|g" \
		-e "s|SCRIPTS_DIR|$DIR|g" \
		-e "s|SERVER_USER|$SERVER_USER|g" \
		-e "s|SERVER_GROUP|$SERVER_GROUP|g" \
		-e "s|PROJECT_NAME|$PROJECT_NAME|g" \
		$SUPERVISOR_TEMPLATE \
		> $REPO_DIR/_tmp.conf

	sudo mv $REPO_DIR/_tmp.conf \
		/etc/supervisor/conf.d/$PROJECT_NAME.conf

	sudo supervisorctl reread
	sudo supervisorctl update
else
	echo "gunicorn already set up"
fi
sudo supervisorctl start $PROJECT_NAME

##
# logrotate

if [[ ! -f /etc/logrotate.d/nginx-$PROJECT_NAME ]]; then
	echo "Setting up logrotate..."

	sed -e "s|REPO_DIR|$REPO_DIR|g" \
		-e "s|RUN_DIR|$RUN_DIR|g" \
		-e "s|SERVER_USER|$SERVER_USER|g" \
		-e "s|SERVER_GROUP|$SERVER_GROUP|g" \
		"$LOGROTATE_TEMPLATE" \
		> "$REPO_DIR/_tmp.conf"

	logrotate_file="/etc/logrotate.d/nginx-$PROJECT_NAME"
	sudo mv "$REPO_DIR/_tmp.conf" "$logrotate_file"

	# fix permissions: has to be 0644 root:root
	sudo chown root:root "$logrotate_file"
	sudo chmod 0644 "$logrotate_file"
fi

##
# nginx

if [[ ! -f /etc/nginx/sites-available/$PROJECT_NAME ]]; then
	echo "Setting up nginx..."

	# fill in the template config file
	sed -e "s|PROJECT_NAME|$PROJECT_NAME|g" \
		-e "s|RUN_DIR|$RUN_DIR|g" \
		-e "s|REPO_DIR|$REPO_DIR|g" \
		-e "s|SRC_DIR|$SRC_DIR|g" \
		-e "s|DOCS_DIR|$DOCS_DIR|g" \
		-e "s|DATA_DIR|$DATA_DIR|g" \
		-e "s|ADMIN_EMAIL|$ADMIN_EMAIL|g" \
		-e "s|SERVER_NAME|$SERVER_NAME|g" \
		-e "s|SERVER_USER|$SERVER_USER|g" \
		-e "s|SERVER_GROUP|$SERVER_GROUP|g" \
		$NGINX_TEMPLATE \
		> $REPO_DIR/_tmp.conf

	sudo mv $REPO_DIR/_tmp.conf \
		/etc/nginx/sites-available/$PROJECT_NAME

	# disable the default nginx site
	sudo rm -f /etc/nginx/sites-enabled/default
fi

if [[ ! -f /etc/nginx/sites-enabled/$PROJECT_NAME ]]; then
	echo "Enabling nginx site..."

	# activate our site
	sudo ln -f -s \
		/etc/nginx/sites-available/$PROJECT_NAME \
		/etc/nginx/sites-enabled/$PROJECT_NAME
else
	echo "nginx already set up"
fi

sudo service nginx restart
