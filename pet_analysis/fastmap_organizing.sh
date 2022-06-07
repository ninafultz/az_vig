#!/bin/bash

# how to write it out: ./fastmap_organizing.sh -n $SUBJECT -d /users/ninafultz/az_vig -f NP3-kontrol.nii.gz -s /users/ninafultz/scripts/az_vig/pet_analysis/
# nina fultz may 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
wrapper script to run fastmap so that you can then go run ff DYNAMIC -o overlay-list.dat ; we are moving everything to that folder!

steps of all analysis:
1) move all required files to jip_km folder:
        a) motion corrected DYNAMIC images (make sure in .nii format)x
        b) pet.glm #in project dir
        c) timing-table #in project dir
        d) fastmap dir
2) run putamen_overlay and cerebellum overlay - will make overlays using ANTS - will be doing this with the dynamic template
3) run voxel_to_xyz script in matlab #SEP SCRIPT
5) ff control file -o overlay-list.dat #SEP SCRIPT
      #this will be in format:
      putamen /your/path/putamen_overlay.txt red
6) save out timeseries for your rois manually 
7) formatting_fastmap_results - will seperate the fastmap results into txt files that you can then plot
*************************************************************************************** "
    echo Usage: ./fastmap_organizing.sh -n -d -s
       -n: Name of subject
       -d: Project directory
       -f: name of dynamic image
       -s: scripts directory
}


if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:f:s:" opts;
do
    case $opts in
        n) export SUBJECT=$OPTARG ;;
        d) export PROJECT_DIR=$OPTARG ;;
        f) export FILE=$OPTARG ;;
        s) export SCRIPTS=$OPTARG ;;
    esac
done

export FAST_MAP=$PROJECT_DIR/$SUBJECT/pet/fastmap
mkdir $FAST_MAP
echo $FAST_MAP

rsync -aP $PROJECT_DIR/$SUBJECT/pet/mc/${FILE}*.nii $FAST_MAP
echo $FAST_MAP

rsync -aP $PROJECT_DIR/glm/*glm $FAST_MAP
rsync -aP $PROJECT_DIR/time/pet-timing.table $FAST_MAP
rsync -aP $SCRIPTS/overlay* $FAST_MAP
echo rsync -aP $SCRIPTS/overlay* $FAST_MAP

#making fastmap folder and copying over files needed control file

FILE=$FAST_MAP/overlay*.txt
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists!"
else
   echo "File ${FILE##*/} does not exist! "
fi

echo "you are now set up to run FASTMAP! have a lovely day!"
