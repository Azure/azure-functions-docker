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

    printf $"\t Collecting global arguments in $1 to globalize them in the final dockerfile.\n"
    globalize_args $1
    printf '%s\n' "${gblarg[@]}" > ./temp.txt
    cat ./temp.txt $base $1 > ./out/${runtime}/${runtimeversion}-appservice.Dockerfile
    printf $"\t Completed compilation of $runtimeversion. Output file available at : ./out/${runtime}/${runtimeversion}-appservice.Dockerfile\n"
}

generate_appservice() {
    base="./host.Dockerfile"
    echo $"Generating Appservice Images for [ $@ ] using base $base"
    for lang in $@; 
    do 
        langimgs=($(find ../$lang/ -name "*-composite.Dockerfile"))
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

generate_appservice "java" "python"
