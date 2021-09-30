#! /bin/bash



DIR=$(dirname $0)
IFS=$'\n'

globalize_args() {
    ## This method is used to bring all args preceding any From statements to the top of the file. 
    ## Allows for ARGs defined globally in composite images to be global in the compiled dockerfile
    gblarg=($((sed -n '/FROM/q;p' $1) | grep ARG)) # list of args in arr with carriage returns at end
}

combine_dockerfile() {
    echo $"Combining $base with $1 \n"
    filename=$1
    echo $1 | cut -d'/' -f 3
    

    echo $"Collecting global arguments in $1 to globalize them in the final dockerfile.\n"
    globalize_args $1
    printf '%s\n' "${gblarg[@]}" > ./temp.txt
    cat ./temp.txt $base $1 > ./out/java/java11-appservice.Dockerfile
}

base="./host.Dockerfile"

langimgs=($(find ../java/ -name "*-composite.Dockerfile"))

combine_dockerfile ${langimgs[@]}
