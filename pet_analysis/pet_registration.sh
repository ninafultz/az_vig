#!/bin/bash                                                                                                                                            

# how to write it out: ./pet_registration.sh -n az111 -d /users/ninafultz/az_vig -f NP3-kontrol.nii.gz
# nina fultz may 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for pet registration AZ project:
    1) will make dynamic template
    2) will output reg in .lta format
*************************************************************************************** "
    echo Usage: ./pet_registration.sh -n -d
       -n: Name of subject
       -d: Home directory
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:f:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
        f) export PET_AC=$OPTARG ;;
    esac
done


##defining paths
export SUBJECT_DATA_DIR=$PROJ_PATH/*
export SUBJECTS_DIR=$PROJ_PATH/$SUBJECT_NAME/

    mkdir $PROJ_PATH/$SUBJECT_NAME/pet

    export PET_REG=$PROJ_PATH/$SUBJECT_NAME/pet/reg
    echo $PET_REG
    mkdir $PET_REG
    
    export PET_TEMPLATE=$PROJ_PATH/$SUBJECT_NAME/pet/template_for_reg
    echo $PET_TEMPLATE
    mkdir $PET_TEMPLATE

    export PET_DYNAMIC=$PROJ_PATH/$SUBJECT_NAME/dynamic
    echo $PET_DYNAMIC
    mkdir $PET_DYNAMIC
    
    export PET_NIFTIS=$PROJ_PATH/$SUBJECT_NAME/pet/niftis
    echo $PET_NIFTIS
    mkdir $PET_NIFTIS
    

## Register your PET image with the anatomical

# If your PET data has multiple frames (ie, dynamic), then you will need to
# create the template from the dynamic data: averaging all the time frames together (eg, mri_concat pet.nii.gz
# --mean --o template.nii.gz). 

mri_concat $PET_DYNAMIC/$PET_AC --frame 0 --o $PET_TEMPLATE/dynamic_template.nii.gz

mri_coreg --s fs --mov $PET_TEMPLATE/dynamic_template.nii.gz --reg $PET_REG/pet_template.reg.lta

# where template.nii.gz is the template image for your PET data. If your
# PET data only has one frame (eg, an SUV image), then that will be your
# template. If your PET data has multiple frames (ie, dynamic), then you
# will need to create the template from the dynamic data. This can be done
# by extracting a single frame (mri_convert pet.nii.gz --frame frameno
# template.nii.gz) or averaging all the time frames together (eg,
# mri_concat pet.nii.gz --mean --o template.nii.gz). It might make sense to
# do a time-weighted average rather than simple average, but we do not have
# a tool to do that easily, but you can do it in matlab. For parallel
# operation, add --threads N where N is the number of CPUs you want to use.
# You should check the registration with:

# tkregisterfv --mov $PET_TEMPLATE/dynamic_template.nii.gz --reg $PET_REG/pet_template.reg.lta --surfs

