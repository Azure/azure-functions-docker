#! /bin/bash



DIR=$(dirname $0)
IFS=$'\n'

select_version() {
    ## Selects the directory of the version to be generated
    ## Defaults to v3 for now 
    if [ "$VERSION" == "4" ]; then
        echo "Version 4 selected"
        DIR=$(dirname $0)/4/bullseye/amd64/base
    elif [ "$VERSION" == "3" ]; then
        echo "Version 4 selected"
        DIR=$(dirname $0)/3.0/buster/amd64/base
    else
        echo "No valid version selected. Defaulting to v3"
        DIR=$(dirname $0)/3.0/buster/amd64/base
    fi
}

globalize_args() {
    ## This method is used to bring all args preceding any From statements to the top of the file. 
    ## Allows for ARGs defined globally in composite images to be global in the compiled dockerfile
    gblarg=($((sed -n '/FROM/q;p' $1) | grep ARG)) # list of args in arr with carriage returns at end
    if [ ${#gblarg[@]} == 0 ]; then 
        printf "\t No global ARGs in $1 \n"
    else
        printf "\t ARGs globalized for $1 : \n"
        for arg in ${gblarg[@]};
        do
            printf "\t\t $arg \n"
        done 
    fi
}

combine_dockerfile() {
    printf $"  Combining $base with $1\n"
    localfile=$(printf $1 | awk -F'\\.\\.' '{print $2}')
    runtime=`echo $localfile | cut -d'/' -f 2`
    runtimeversion=`echo $localfile | cut -d'/' -f 3`
    printf "\t Image Runtime and Version: $runtimeversion \n"

    # Output path
    

    # File structure creation
    outputdir=$"$DIR/../out/${runtime}"
    if [ "$RELEASE" == "true" ]; then
        printf "\t Release Mode enabled. Updating release dockerfiles.\n"
        outputdir=$"$DIR/../release/${runtime}"
    fi
    mkdir -p $outputdir
    outputfile="$outputdir/${runtimeversion}-appservice.Dockerfile"

    printf $"\t Collecting global arguments in $1 to globalize them in the final dockerfile.\n"
    globalize_args $1
    echo "${gblarg[@]}" | cat - $base $1 > $outputfile

    printf $"\t Completed compilation of $runtimeversion. Output file available at : $outputfile\n"
}

generate_appservice() {
    base="$DIR/host.Dockerfile"
    echo $"Generating Appservice Images for [ $@ ] using base $base"
    for lang in $@; 
    do 
        langimgs=($(find $DIR/../$lang/ -name "*-composite.template"))
        if [ -z "$langimgs" ]; then
            echo "No composite images found for language : $lang. Skipping compilation..."
        else
            echo $"Found following images for compilation of language $lang: ${langimgs[@]}"
            for version in ${langimgs[@]};
            do
                combine_dockerfile $version
                printf "\n"
            done
            printf $"Completed compilation of $lang images \n\n"
        fi
    done
    echo "Compilation of all images in list: [ $@ ] complete."
    printf "\n"
}

copy_shared_config() {
     
    
    echo "Copying shared config files into the following language output directories: "
    for lang in $@;
    do
        outputdir=$"$DIR/../out/${lang}/"
        if [ "$RELEASE" == "true" ]; then
            outputdir=$"$DIR/../release/${lang}/"
        fi
        printf "\t $outputdir\n"
        cp -R $DIR/sharedconfig/* $outputdir
    done
}

clear_outputdir() {
    ## Seems to not be working currently. Further investigation needed
    echo "Clearing output folder..."
    rootdir=$"$DIR/../out/*"
    rm -rf rootdir
}


# Defines a flag -r : Release Mode.  Release mode will generate artifacts in a folder titled /release/
# These .Dockerfile artifacts will be used to create the containers uploaded to ACR. Increases trace-ability.
# Flags must come before parameters
while getopts ":r43" flag;do
    case ${flag} in
      r)
        RELEASE="true"
        echo "Release Mode is enabled"
        ;;
      4)
        VERSION="4"
        echo "Version 4 selected"
        ;;
      3)
        VERSION="3"
        echo "Version 3 selected"
        ;;
    esac
done

select_version

echo "Dir is : $DIR"

if [ -z $RELEASE ]; then
    clear_outputdir
fi

# Remove flags from input. Store args in array
declare -a argarray
for arg do
    if [ "${arg:0:1}" != '-' ]; then
        echo $arg
        argarray+=($arg)
    fi
done

if [ ${#argarray[@]} == 0 ]; then
    echo "No language arguments supplied for compilation. Please supply a supported language or 'all' as an input."
    exit 1
fi

if [ ${#argarray[@]} == 1 ] && [ "$argarray" == "all" ]; then
    echo "All supported languages targetted."
    supportedlangs=("java" "node" "python")
    argarray=(${supportedlangs[@]})
fi

generate_appservice ${argarray[@]}

copy_shared_config ${argarray[@]}