#!/bin/bash                                                                                                                                            

# how to write it out: ./pet_motion_correction.sh -n racsleep11 -d /ad/eng/research/eng_research_lewislab/users/nfultz/pet_eeg_fmri
# nina fultz may 2021

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for pet az files organization
*************************************************************************************** "
    echo Usage: ./pet_motion_correction.sh -n -d
       -n: Name of subject
       -d: Home directory
}


if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
    esac
done

#defining paths
    export SUBJECT_DATA_DIR=$PROJ_PATH/*
    export SUBJECTS_DIR=$PROJ_PATH/$SUBJECT_NAME/

    export PET_REG=$PROJ_PATH/$SUBJECT_NAME/fastmap
    echo $PET_REG
    mkdir $PET_REG

    export PET_REG=$PROJ_PATH/$SUBJECT_NAME/fastmap_outputs
    echo $PET_REG
    mkdir $PET_REG

    export PET_REG=$PROJ_PATH/$SUBJECT_NAME/tacs
    echo $PET_REG
    mkdir $PET_REG

echo "pet data organized! have a good day"
