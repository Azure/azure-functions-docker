#! /bin/bash

# Directory name for start.sh
DIR="$(dirname $0)"

CUSTOM_PACKAGES_PY37="$HOME/site/wwwroot/.python_packages/lib/python3.7/site-packages"
CUSTOM_VENV_PACKAGES_PY37="$HOME/site/wwwroot/worker_venv/lib/python3.7/site-packages"

export PYTHONPATH=$CUSTOM_PACKAGES_PY37:$CUSTOM_VENV_PACKAGES_PY37:$PYTHONPATH

echo "python == $(which python)"
echo "PYTHONPATH == $PYTHONPATH"

echo "starting the python worker"
exec python $DIR/worker.py $@
