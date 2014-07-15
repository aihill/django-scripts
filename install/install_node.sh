#!/bin/bash
#
# Install Ubuntu packages used by the server
#

# find the scripts directory (note the /..)
DIR="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source $DIR/load_config.sh
cd "$REPO_DIR"

#########################

echo "Installing node.js..."

echo "Uninstall old node"
sudo apt-get remove -y nodejs npm
sudo rm -f /usr/bin/coffee /usr/local/bin/coffee
sudo rm -f /usr/bin/lessc /usr/local/bin/lessc

echo "Install node 0.10"
curl https://raw.githubusercontent.com/creationix/nvm/v0.10.0/install.sh | bash
nvm install 0.10
nvm use 0.10
nvm alias default 0.10
npm config set registry http://registry.npmjs.org/

echo "Install coffeescript"
sudo npm install -g coffee-script

echo "Install less"
sudo npm install -g less

#########################

echo "$0: done"
