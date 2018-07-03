#! /bin/bash

# Directory name for start.sh
DIR="$(dirname $0)"

# If we're not in a virtual environment, check if either:
#   $AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT is set, use it for venv
#   if it's not set and there is a default venv, activate it
#   else use the container python
if [ -z "$VIRTUAL_ENV"]
then

    # Determining the virtual environment entry point
    if [ -z "$AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT" ] && [ -f "$HOME/site/wwwroot/worker_venv/bin/activate" ]
    then
        AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT="$HOME/site/wwwroot/worker_venv/bin/activate"
    fi

    if [ -z "$AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT" ]
    then
        echo "using system python"
    else
        echo "activating virtual environment"
        source $AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT
    fi
fi

CUSTOM_PACKAGES="/home/site/wwwroot/.python_packages"
if [ -d "$CUSTOM_PACKAGES" ]
then
    echo "appending $CUSTOM_PACKAGES to PYTHONPATH"
    export PYTHONPATH=$PYTHONPATH:$CUSTOM_PACKAGES
fi

echo "starting the python worker"
python $DIR/worker.py $@
