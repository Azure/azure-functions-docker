#! /bin/bash

# Directory name for start.sh
DIR="$(dirname $0)"

echo "python == $(which python)"
echo "PYTHONPATH == $PYTHONPATH"

echo "starting the python worker"
python $DIR/worker.py $@
