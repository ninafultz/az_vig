#!/bin/bash                                                                                                                                            

# how to write it out: ./fastmap_multiple_timemodels.sh -n az111 -d //data1/ninafultz/az_vig -s //data1/ninafultz/scripts/az_vig/pet_analysis -f NP3-kontrol.nii.gz_mc.nii
# nina fultz june 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for using many timemodels with different time points to batch process FASTMAP data
*************************************************************************************** "
    echo Usage: ./fastmap_multiple_timemodels.sh -n -d
       -n: Name of subject
       -d: Home directory
       -s: scripts directory
       -f: PET dynamic file
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:s:f:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
        s) export SCRIPTS=$OPTARG ;;
        f) export FILE=$OPTARG ;;
    esac
done

export SUBJECTS_DATA_DIR=$PROJ_PATH/$SUBJECT_NAME
export FASTMAP=$PROJ_PATH/$SUBJECT_NAME/pet/fastmap/fastmap_orig
export FASTMAP_OUTPUTS=$PROJ_PATH/$SUBJECT_NAME/pet/fastmap
mkdir $FASTMAP_OUTPUTS
#these are all of the different pet glm files with different time points in minutes 

for GLM in pet_groundtruth_90lim pet_groundtruth pet_40_to_120 pet_40_to_90_90lim pet_50_to_120  pet_50_to_65_90lim pet_50_to_70_90lim pet_50_to_75_90lim pet_50_to_80_90lim pet_60_to_120 pet_60_to_90_90lim pet_70_to_120 pet_70_to_90_90lim 
do
echo "***************************************************************************************
Organizing FASTMAP for $GLM
*************************************************************************************** "

export FASTMAP_WITH_GLM_PATH=$FASTMAP_OUTPUTS/$GLM
mkdir $FASTMAP_WITH_GLM_PATH
echo $FASTMAP_WITH_GLM_PATH

rsync -aP $SUBJECTS_DATA_DIR/pet/mc/$FILE $FASTMAP_WITH_GLM_PATH
echo rsync -aP $SUBJECTS_DATA_DIR/pet/mc/$FILE $FASTMAP_WITH_GLM_PATH

rsync -aP $PROJ_PATH/glm/${GLM}.glm $FASTMAP_WITH_GLM_PATH
echo rsync -aP $PROJ_PATH/glm/${GLM}.glm $FASTMAP_WITH_GLM_PATH
rsync -aP $PROJ_PATH/time/pet-timing.table $FASTMAP_WITH_GLM_PATH
rsync -aP $SCRIPTS/overlay* $FASTMAP_WITH_GLM_PATH
rsync -aP $SCRIPTS/timeModel.dat $FASTMAP_WITH_GLM_PATH
rsync -aP $FASTMAP_WITH_GLM_PATH/${GLM}.glm $FASTMAP_WITH_GLM_PATH/${GLM}.glm.bk
mv $FASTMAP_WITH_GLM_PATH/${GLM}.glm $FASTMAP_WITH_GLM_PATH/pet.glm

rsync -aP $FASTMAP/*mask_in_dynamic* $FASTMAP_WITH_GLM_PATH
done

#making fastmap folder and copying over files needed control file

FILE=$FASTMAP_WITH_GLM_PATH/pet.glm
if [ -f $FILE  ]; then
echo  File ${FILE##*/} exists! 
echo "you are now set up to run FASTMAP! have a lovely day!"
else
echo "File ${FILE##*/} does not exist! "
fi
