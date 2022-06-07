#!/bin/bash                                                                                                                                            

# how to write it out: ./pet_motion_correction.sh -n az111 -d /users/ninafultz/az_vig -f NP3-kontrol.nii.gz
# nina fultz may 2021

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for pet motion correction AZ project:

# input files: 1) dynamic template file you made with ./pet_registration
#              2) dynamic pet data raw
#              3) motion corrected output 

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

while getopts "n:d:f:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
        f) export PET_AC=$OPTARG ;;
    esac
done

#defining paths
    export SUBJECT_DATA_DIR=$PROJ_PATH/*
    export SUBJECTS_DIR=$PROJ_PATH/$SUBJECT_NAME/

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

    export PET_MC=$PROJ_PATH/$SUBJECT_NAME/pet/mc
    echo $PET_MC
    mkdir $PET_MC

# motion correction script -- created by PetSurfer
# input files: 1) dynamic template file you made with ./pet_registration
#              2) dynamic pet data raw
#              3) motion corrected output 

echo mc-afni2 --t $PET_TEMPLATE/dynamic_template.nii.gz --i $PET_DYNAMIC/$PET_AC --o $PET_MC/${PET_AC}_mc.nii.gz --mcdat $PET_MC/motion-parameters.dat
mc-afni2 --t $PET_TEMPLATE/dynamic_template.nii.gz --i $PET_DYNAMIC/$PET_AC --o $PET_MC/${PET_AC}_mc.nii.gz --mcdat $PET_MC/motion-parameters.dat

mri_convert $PET_MC/${PET_AC}_mc.nii.gz $PET_MC/${PET_AC}_mc.nii

FILE=$PET_MC/${PET_AC}_mc.nii
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists!"
else
   echo "File ${FILE##*/} does not exist! "
fi

echo "motion corrected dynamic pet data - have a lovely day!"
