!/bin/bash

# how to write it out: ./jip_organizing.sh -n racsleep06 -d /ad/eng/research/eng_research_lewislab/users/nfultz/pet_eeg_fmri -b /ad/eng/research/eng_research_lewislab/users/nfultz/
# nina fultz may 2021

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
wrapper script to run jip-srtm so that you can then go run ./jip-srtm jip_control_file.txt; we are moving everything to that folder!

steps of all analysis:
1) move all required files to jip_km folder:
        a) motion corrected DYNAMIC images (make sure in .nii format)x
        b) pet.glm #in project dir
        c) timing-table #in project dir
        d) copy control file over to jip dir
        e) jip-srtm dir
        f) jip-display dir
        g) dynamic template
2) run putamen_overlay and cerebellum overlay - will make overlays using ANTS - will be doing this with the dynamic template
3) run voxel_to_xyz script in matlab #SEP SCRIPT
4) ./jip-srtm controlfile #SEP SCRIPT
5) jip-display -t control file -o overlay-list.dat #SEP SCRIPT
      #this will be in format:
      putamen /your/path/putamen_overlay.txt red
6) save out timeseries for your rois manually 
7) jip_splitting_roi
*************************************************************************************** "
    echo Usage: ./jip_srtm_shell.sh -n -d -b
       -n: Name of subject
       -d: Project directory
       -b: Home directory
}

module load freesurfer
module load matlab
module load spm

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:b:" opts;
do
    case $opts in
        n) export SUBJECT=$OPTARG ;;
        d) export PROJECT_DIR=$OPTARG ;;
                b) export HOME=$OPTARG ;;
    esac
done

export JIP_KM=$PROJECT_DIR/$SUBJECT/pet/jip_km
mkdir $JIP_KM
echo $JIP_KM

export MC=$PROJECT_DIR/$SUBJECT/pet/mc

export SCRIPTS=$HOME/scripts/pet_analysis/pet_analysis

FILE=$MC/DYNAMIC_PRR_AC_Images.nii.gz  
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists. copying dynamic image!"
   rsync -aP $MC/DYNAMIC_PRR_AC_Images_mc.nii.gz $PROJECT_DIR/$SUBJECT/pet/mc/DYNAMIC_PRR_AC_Images_mc_copy.nii.gz
   mri_convert $MC/DYNAMIC_PRR_AC_Images_mc.nii.gz $MC/DYNAMIC_PRR_AC_Images_mc.nii
   rsync -aP $MC/DYNAMIC_PRR_AC_Images_mc.nii $JIP_KM/
else
   echo "File ${FILE##*/} does not exist! "
fi

#making jip folder and copying over files needed control file
rsync -aP $SCRIPTS/jip_control_file.txt $JIP_KM

#copying over ovelay txt that points to overlay files = should be putamen, caudate, thalamus
rsync -aP $SCRIPTS/overlay*.txt $JIP_KM

#copying over dynamic template images
mri_convert $PROJECT_DIR/$SUBJECT/pet/template_for_reg/dynamic_template.nii.gz $PROJECT_DIR/$SUBJECT/pet/template_for_reg/dynamic_template.nii
rsync -aP $PROJECT_DIR/$SUBJECT/pet/template_for_reg/dynamic_template.nii $JIP_KM/

FILE=$JIP_KM/jip_control_file.txt
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists!"
else
   echo "File ${FILE##*/} does not exist! "
fi

FILE=$JIP_KM/overlay*.txt
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists!"
else
   echo "File ${FILE##*/} does not exist! "
fi

########## 
# making roi of putamen and cerebellum and then applying them to the dynamic template with ANS

bash $SCRIPTS/putamen_overlay_ants.sh -n $SUBJECT -d $PROJECT_DIR
bash $SCRIPTS/cerebellum_overlay_ants.sh -n $SUBJECT -d $PROJECT_DIR
bash $SCRIPTS/cortex_thal_caudate_overlay_ants.sh -n $SUBJECT -d $PROJECT_DIR


echo "copied files over and created overlay for the caudate, thalamus, cerebellum and putamen! have a lovely day!"
