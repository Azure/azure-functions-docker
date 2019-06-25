#! /bin/bash

# Directory name for start.sh
DIR="$(dirname $0)"

CUSTOM_PACKAGES_PY36="$HOME/site/wwwroot/.python_packages/lib/python3.6/site-packages"
CUSTOM_VENV_PACKAGES_PY36="$HOME/site/wwwroot/worker_venv/lib/python3.6/site-packages"

# Needed to import Python packages 
mkdir -p "$CUSTOM_PACKAGES_PY36"
mkdir -p "$CUSTOM_VENV_PACKAGES_PY36"

export PYTHONPATH=$CUSTOM_PACKAGES_PY36:$CUSTOM_VENV_PACKAGES_PY36:$PYTHONPATH

echo "python == $(which python)"
echo "PYTHONPATH == $PYTHONPATH"

echo "starting the python worker"
python $DIR/worker.py $@
