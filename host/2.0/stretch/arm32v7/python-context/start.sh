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
    if [ -z "$AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT" ]
    then
        echo "using system python"
    else
        echo "activating virtual environment"
        source $AZURE_FUNCTIONS_VIRTUAL_ENVIRONMENT
    fi
fi

if [ -z "$SKIP_PYTHONPATH_UPDATE" ]
then
    CUSTOM_PACKAGES="$HOME/site/wwwroot/.python_packages/lib/python3.7/site-packages"
    if [ -d "$CUSTOM_PACKAGES" ]
    then
        echo "appending $CUSTOM_PACKAGES to PYTHONPATH"
        export PYTHONPATH=$PYTHONPATH:$CUSTOM_PACKAGES
    else
        echo "path $CUSTOM_PACKAGES doesn't exist"
    fi

    CUSTOM_VENV_PACKAGES="$HOME/site/wwwroot/worker_venv/lib/python3.7/site-packages"
    if [ -d "$CUSTOM_VENV_PACKAGES" ]
    then
        echo "appending $CUSTOM_VENV_PACKAGES to PYTHONPATH"
        export PYTHONPATH=$PYTHONPATH:$CUSTOM_VENV_PACKAGES
    else
        echo "path $CUSTOM_VENV_PACKAGES doesn't exist"
    fi

    CUSTOM_PACKAGES="$HOME/site/wwwroot/.python_packages/lib/python3.6/site-packages"
    if [ -d "$CUSTOM_PACKAGES" ]
    then
        echo "appending $CUSTOM_PACKAGES to PYTHONPATH"
        export PYTHONPATH=$PYTHONPATH:$CUSTOM_PACKAGES
    else
        echo "path $CUSTOM_PACKAGES doesn't exist"
    fi

    CUSTOM_VENV_PACKAGES="$HOME/site/wwwroot/worker_venv/lib/python3.6/site-packages"
    if [ -d "$CUSTOM_VENV_PACKAGES" ]
    then
        echo "appending $CUSTOM_VENV_PACKAGES to PYTHONPATH"
        export PYTHONPATH=$PYTHONPATH:$CUSTOM_VENV_PACKAGES
    else
        echo "path $CUSTOM_VENV_PACKAGES doesn't exist"
    fi
else
    echo "SKIP_PYTHONPATH_UPDATE == $SKIP_PYTHONPATH_UPDATE"
fi

echo "python == $(which python)"
echo "PYTHONPATH == $PYTHONPATH"

echo "starting the python worker"
if [ -f $HOME/site/wwwroot/worker-bundle/worker-bundle ]
then
    chmod +x $HOME/site/wwwroot/worker-bundle/worker-bundle
    $HOME/site/wwwroot/worker-bundle/worker-bundle $@
else
    python $DIR/worker.py $@
fi