#! /bin/bash



DIR=$(dirname $0)
IFS=$'\n'

globalize_args() {
    ## This method is used to bring all args preceding any From statements to the top of the file. 
    ## Allows for ARGs defined globally in composite images to be global in the compiled dockerfile
    gblarg=($((sed -n '/FROM/q;p' $1) | grep ARG)) # list of args in arr with carriage returns at end
    printf "\t ARGs globalized for $1 : \n"
    for arg in ${gblarg[@]};
    do
        printf "\t\t $arg \n"
    done 

}

combine_dockerfile() {
    printf $"  Combining $base with $1\n"
    runtime=`echo $1 | cut -d'/' -f 2`
    runtimeversion=`echo $1 | cut -d'/' -f 3`
    printf "\t Image Runtime and Version: $runtimeversion \n"

    # File structure creation
    outputdir=$"../out/${runtime}"
    if [ "$TESTMODE" == "true" ]; then
        printf "\t Test Mode enabled. Updating test dockerfiles.\n"
        outputdir=$"../test/${runtime}"
    fi
    mkdir -p $outputdir
    outputfile="$outputdir/${runtimeversion}-appservice.Dockerfile"

    printf $"\t Collecting global arguments in $1 to globalize them in the final dockerfile.\n"
    globalize_args $1
    echo "${gblarg[@]}" | cat - $base $1 > $outputfile

    printf $"\t Completed compilation of $runtimeversion. Output file available at : $outputfile\n"
}

generate_appservice() {
    base="./host.Dockerfile"
    echo $"Generating Appservice Images for [ $@ ] using base $base"
    for lang in $@; 
    do 
        langimgs=($(find ../$lang/ -name "*-composite.template"))
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
}

clear_outputdir() {
    echo "Clearing output folder..."
    rootdir=$"../out/*"
    if [ "$TESTMODE" == "true" ]; then
        printf "\t Test Mode enabled. Clearing test dockerfiles.\n"
        rootdir=$"../test/*"
    fi
    rm -rf rootdir
}



# Defines a flag -t for testing purposes. Developers are required to manually regenerate their test files when they intentionally alter composite files
# Useful for keeping a closer eye on our full dockerfiles. As we will be gitignoring output files and generating them every PR. 
while getopts "t" flag;do
    case ${flag} in
      t)
        TESTMODE="true"
        echo "Test Mode is enabled"
        ;;
    esac
done

clear_outputdir

declare -a argarray
for arg do
    if [ "${arg:0:1}" != '-' ]; then
        argarray+=($arg)
    fi
done

if [ ${#argarray[@]} == 0 ]; then
    echo "No language arguments supplied for compilation. Please supply a supported language or all as an input."
    exit 1
fi

if [ ${#argarray[@]} == 1 ] && [ "$argarray" == "all" ]; then
    echo "All supported languages targetted."
    supportedlangs=("java" "python")
    generate_appservice ${supportedlangs[@]}
else 
    generate_appservice ${argarray[@]}
fi


# suggested solution. Create a function to place the shared configs in each output folder
