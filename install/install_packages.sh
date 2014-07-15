#!/bin/bash
#
# Install all the packages used by the server
#

# find the scripts directory (note the /..)
DIR="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source $DIR/load_config.sh
cd "$REPO_DIR"

#########################

echo "Installing Ubuntu packages..."

# install ubuntu packages
sudo apt-get update -y
sudo apt-get install -y $(cat $DIR/install/requirements-ubuntu.txt)

sudo apt-get install -y \
	postgresql-$PSQL_VERSION \
	postgresql-contrib-$PSQL_VERSION \
	postgresql-server-dev-$PSQL_VERSION

# install dependencies for numpy/scipy
sudo apt-get build-dep -y python-numpy python-scipy

# make sure the image libraries are in /usr/lib
for f in libfreetype.so libjpeg.so libz.so liblcms.so; do
	if [[ ! -f /usr/lib/$f ]]; then
		sudo ln -s /usr/lib/`uname -i`-linux-gnu/$f /usr/lib/$f
	fi
done

#########################

echo "Installing node.js..."

# fix npm registry
echo "Uninstall old node"
sudo apt-get remove -y nodejs npm
sudo rm -f /usr/bin/coffee /usr/local/bin/coffee
sudo rm -f /usr/bin/lessc /usr/local/bin/lessc

echo "Install newest node"
if [[ ${VERSION%%.*} -ge 14 ]]; then
	# Ubuntu 14.04
	sudo add-apt-repository -y ppa:chris-lea/node.js
else
	# Ubuntu 12.04
	sudo add-apt-repository -y ppa:richarvey/nodejs
fi

sudo apt-get update -y
sudo apt-get install -y nodejs npm
echo "Node version:"
node -v

npm config set registry http://registry.npmjs.org/
echo "Install coffeescript"
sudo npm install -g coffee-script
echo "Install less"
sudo npm install -g less

#########################

echo "$0: done"
