#!/bin/bash                                                                                               

# how to write it out: ./registration.sh -n inkref_07_cap -d  -i image name
# nina fultz may 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for registration for asl az_vig project
*************************************************************************************** "
    echo Usage: ./registration.sh -n -d
       -n: Name of subject
       -d: Home directory
       -i: name of your images - e.g. NP3-kontrol.nii.gz
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:i:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
        i) export IMAGE_NAME=$OPTARG ;;
    esac
done
echo "$IMAGE_NAME"

export SUBJECT_DATA_DIR=$PROJ_PATH/
echo "$SUBJECT_DATA_DIR"

export REG_DIR=$PROJ_PATH/$SUBJECT_NAME/reg
mkdir "$REG_DIR"
echo "$REG_DIR"

export SUBJECTS_DIR=$PROJ_PATH/$SUBJECT_NAME
echo "$SUBJECTS_DIR"

#lol this is silly but alas:
export SUBJECT_DATA_DIR=$PROJ_PATH/$SUBJECT_NAME/*
  echo "$SUBJECT_DATA_DIR"

visual_reg=$PROJ_PATH/$SUBJECT_NAME/reg/mc_cortex_reg.dat
if [ -f "$visual_reg" ]; then
     echo "${visual_reg##*/} already exists! "
else
  echo "${visual_regg##*/} does not exists. running bbregister! "
fi

for i in $IMAGE_NAME; do
  bbregister --s fs/ --mov "$PROJ_PATH"/"$SUBJECT_NAME"/mc/${i}_mc2.nii --init-fsl --reg "$PROJ_PATH"/"$SUBJECT_NAME"/reg/${i}_mc_reg.dat --bold  
    if [ -f "$visual_reg" ]; then
      echo "${visual_regg##*/} running bbregister done! "
    else
      echo "${visual_regg##*/} bbregister failed! "
    fi
done
