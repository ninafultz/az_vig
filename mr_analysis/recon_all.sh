#!/bin/bash -l
# Script for recon all 
# Nina Fultz May 2022

# how to write it out: ./get_data.sh -n dicoms -d /users/ninafultz/az_vig/$SUBJECT -s dcm2niix
#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to retrieve data from scanner, convert to nifti and create minimal meta data files
*************************************************************************************** "
    echo "Usage: ./get_data.sh -n -d -s
           -n: Name of dicom directory - e.g. dicoms
           -d: Subject directory /autofs/cluster/mreg_project
           -s: Pathway to dcm2niix - you can download this from https://github.com/dangom/dcm2niix onto your cluster"
}

#$ -P fastfmri

#$ -l mem_per_core=4G

#$ -pe omp 12

#$ -m ea

#$ -N recon-all

#$ -j y

#$ -t 6

# how to write it out: ./recon_all.sh -d /users/ninafultz/az_vig/$SUBJECT

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to run recon all with freesurfer
*************************************************************************************** 
    echo "Usage: ./recon_all.sh -d
           -n: Name of dicom directory - e.g. dicoms
           -d: Subject directory /autofs/cluster/mreg_project"
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

unset SubjectOnScanner DIR Subject

while getopts "d:" opts;
do
    case $opts in
        d) OUTPUT_FILE=$OPTARG ;;
    esac
done

SUBJECTS_DIR=$OUTPUT_FILE
recon-all -all -subjid fs_v2 -parallel -i $SUBJECTS_DIR/anat/Head_t1_mprage_sag_p2_iso.nii.gz

