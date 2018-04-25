#! /bin/bash
set -x

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
        echo "activating virtual environment"
        source $AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT
    else
        echo "using system python"
    fi
fi

echo "starting the python worker"
python $DIR/worker.py $@
