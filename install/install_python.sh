#!/bin/bash
#
# Install python packages
#

DIR="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
source $DIR/load_config.sh
cd "$REPO_DIR"

echo "Install Python packages..."

# detect whether we need sudo for pip
if [[ "$(which pip)" == "/usr/bin/pip" ]] || [[ "$(stat -c %U $(which pip))" == "root" ]]; then
	GLOBAL_PIP="sudo pip"
else
	GLOBAL_PIP="pip"
fi
echo "GLOBAL_PIP=$GLOBAL_PIP"

echo "Upgrading versiontools..."
$GLOBAL_PIP install --upgrade versiontools

echo "Upgrading virtualenv..."
$GLOBAL_PIP install --upgrade virtualenv

if [[ ! -d "$VENV_DIR" ]]; then
	echo "Create virtualenv (with python2.7)..."
	virtualenv --python=$(which python2.7) "$VENV_DIR"
fi

echo "Activate virtualenv ($VENV_DIR)..."
source "$VENV_DIR/bin/activate"

##########################################
# Below here is local to the virtualenv

echo "Installing newest pip (>= 1.5) locally..."
mkdir -p opt/pip
cd opt/pip
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O get-pip.py
python get-pip.py
cd "$REPO_DIR"

LOCAL_PIP="$VENV_DIR/bin/pip"

echo "Installing setup packages (locally)..."
$LOCAL_PIP install --upgrade setuptools
$LOCAL_PIP install --upgrade distribute
$LOCAL_PIP install --upgrade versiontools

echo "Installing python packages (locally) in a particular order..."
for f in $(ls -1 $DIR/install/requirements-python-*.txt | sort); do
	$LOCAL_PIP install $PIP_OPTS -r $f
done

echo "Patch manage.py to use virtualenv"
sed '1d' $SRC_DIR/manage.py > $SRC_DIR/manage.py.tmp
echo '#!../venv/bin/python' > $SRC_DIR/manage.py
cat $SRC_DIR/manage.py.tmp >> $SRC_DIR/manage.py
rm $SRC_DIR/manage.py.tmp
