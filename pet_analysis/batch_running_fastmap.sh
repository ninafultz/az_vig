#!/bin/bash                                                                                                                                            

# how to write it out: ./batch_running_fastmap.sh -n az111 -d //data1/ninafultz/az_vig
# nina fultz june 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to bathc run FASTMAP data
*************************************************************************************** "
    echo Usage: ./batch_running_fastmap.sh -n -d
       -n: Name of subject
       -d: Home directory
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
    esac
done

export SUBJECTS_DATA_DIR=$PROJ_PATH/$SUBJECT_NAME
export FASTMAP=$PROJ_PATH/$SUBJECT_NAME/pet/fastmap/fastmap_orig
export FASTMAP_OUTPUTS=$PROJ_PATH/$SUBJECT_NAME/pet/fastmap
mkdir $FASTMAP_OUTPUTS


#these are all of the different pet glm files with different time points in minutes 

for GLM in pet_40_to_90_90lim pet_50_to_120  pet_50_to_65_90lim pet_50_to_70_90lim pet_50_to_75_90lim pet_50_to_80_90lim pet_60_to_120 pet_60_to_90_90lim pet_70_to_120 pet_70_to_90_90lim 
do
echo "***************************************************************************************
Running FASTMAP for $GLM
*************************************************************************************** "

export FASTMAP_WITH_GLM_PATH=$FASTMAP_OUTPUTS/$GLM
mkdir $FASTMAP_WITH_GLM_PATH
echo $FASTMAP_WITH_GLM_PATH

export FASTMAP_RESULTS=$PROJ_PATH/$SUBJECT_NAME/pet/fastmap_outputs
mkdir $FASTMAP_RESULTS
echo $FASTMAP_RESULTS

export RESULTS=$PROJ_PATH/$SUBJECT_NAME/pet/fastmap_outputs/$GLM
mkdir $RESULTS
echo $RESULTS

cd $FASTMAP_WITH_GLM_PATH
//data1/ninafultz/toolboxes/jip/bin/Linux-x86_64/FM-2021-July --open pet -o overlay-list.txt -b timeModel.dat -threads 50

done

#making fastmap folder and copying over files needed control file

FILE=$RESULTS/graph.dat
if [ -f $FILE  ]; then
echo  File ${FILE##*/} exists! 
echo "fastmap has been run! have a lovely day!"
else
echo "File ${FILE##*/} does not exist! "
fi
