#!/bin/bash                                                                                               

# how to write it out: ./recon_brainstem.sh -n az111 -d /users/ninafultz/az_vig
# nina fultz may 2021

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to take do brainstem reconall -- this is now a seperate function in freesurfer
*************************************************************************************** "
    echo Usage: ./recon_brainstem.sh -n -d
       -n: Name of subject
       -d: Project directory
}


if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:" opts;
do
    case $opts in
        n) SUBJECT=$OPTARG ;;
        d) PROJECT_DIR=$OPTARG ;;
    esac
done


export SUBJECTS_DIR=$PROJECT_DIR/$SUBJECT/
echo $SUBJECTS_DIR
segmentBS.sh fs $SUBJECT_DIR

FILE=$PROJECT_DIR/$SUBJECT/fs/mri/brainstemSsVolumes.v12.txt
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists. your brainstemSsVolumes in dynamic space exists!"
   echo "All done! Have a lovely day!"
else
   echo "File ${FILE##*/} does not exist. Something went wrong! "
fi

