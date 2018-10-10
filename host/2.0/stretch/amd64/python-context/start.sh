#! /bin/bash

# Directory name for start.sh
DIR="$(dirname $0)"

echo "python == $(which python)"
echo "PYTHONPATH == $PYTHONPATH"

echo "starting the python worker"
$HOME/site/wwwroot/worker/worker $@