#!/bin/bash                                                                                                                                            
# nina fultz january 2022: nfultz@mgh.harvard.edu

# how to write it out: ./bpnd_to_ts.sh -n racsleep11 -d /autofs/cluster/ldl/nina/pet_eeg_fmri -b BP-A

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for taking the bpnd from fastmap kinetic model 

        - if you run into problems:
                1) check that your inputs are correct
                2) check that your BP roi is in .nii.gz format -- can use: module load freesurfer 
                                                                                                           mri_convert YOUR_FILE YOUR_FILE.nii.gz
*************************************************************************************** "
    echo Usage: ./bpnd_to_ts.sh -n -d -b
       -n: Name of subject
       -d: Home directory
       -b: bp type
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:b:" opts;
do
    case $opts in
        n) export SUBJECT_NAME=$OPTARG ;;
        d) export PROJ_PATH=$OPTARG ;;
        b) export BP=$OPTARG ;;
    esac
done

export TS=$PROJ_PATH/$SUBJECT_NAME/ts #this is where your timeseries output will be
mkdir $TS
echo $TS

export ROI=$PROJ_PATH/$SUBJECT_NAME/ROIs #this is where your timeseries output will be
mkdir $ROI
echo $ROI

export SRTM=$PROJ_PATH/$SUBJECT_NAME/fastmap_outputs/SRTM2/ #where is your SRTM fastmap outputs
echo $SRTM

mri_convert $SRTM/${BP}.nii $ROI/${BP}.nii.gz

export SUBJECT_DIR=$PROJ_PATH/$SUBJECT_NAME
echo $SUBJECT_DIR

        BP_FILE=$PROJ_PATH/$SUBJECT_NAME/ts/${BP}_to_ts.txt
        if [ -f $BP_FILE ]; then
        echo "${BP_FILE##*/} already exists! "
        echo "${BP_FILE##*/} BP to txt already done! "
else


    fslmeants -i $ROI/${BP}.nii.gz -o $TS/${BP}_to_ts.txt


        if [ -f $BP_FILE ]; then
                echo "${BP_FILE##*/} BP to txt done! All done, have a lovely day! "
        else
                echo "${BP_FILE##*/} BP to txt failed! "
        fi
fi


