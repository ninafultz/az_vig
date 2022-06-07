#!/bin/bash                                                                                               

# how to write it out: ./motion_correction.sh -n inkref_07_cap -d /data1/ninafultz/az_vig -s scripts
# nina fultz may 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for motion correction
*************************************************************************************** "
    echo Usage: ./registration.sh -n -d -s
       -n: Name of subject
       -d: Home directory
       -s: Scripts directory
}


if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:s:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
        s) export SCRIPTS_DIR=$OPTARG ;;
    esac
done

export SUBJECT_DATA_DIR=$PROJ_PATH/
echo $SUBJECT_DATA_DIR

export REG_DIR=$PROJ_PATH/$SUBJECT_NAME/reg
mkdir $REG_DIR
echo $REG_DIR

export SUBJECTS_DIR=$PROJ_PATH/$SUBJECT_NAME
echo $SUBJECTS_DIR

##Create directory for motion corrected files

export MC2_DIR=$SUBJECT_DATA_DIR/$SUBJECT_NAME/mc
mkdir $MC2_DIR
echo $MC2_DIR

cd $SUBJECT_DATA_DIR/$SUBJECT_NAME/func
bash $SCRIPTS_DIR/motionCorrect_zpad_noslicetime.sh

INFO=$SUBJECT_DATA_DIR/$SUBJECT_NAME/mc/*mc.nii*
echo $INFO
if [ -f $INFO ]; then
  echo "${INFO##*/} motion correction is all done! All done, have a lovely day! "
else
  echo "${INFO##*/} motion correction failed! "
fi
