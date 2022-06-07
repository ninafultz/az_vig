#!/bin/bash                                                                                               

# how to write it out: ./extract_rois.sh -n az127 -d //data1/ninafultz/az_vig
# nina fultz may 2021

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to take annotation files and convert them into readable nifti files for fastmap
*************************************************************************************** "
    echo Usage: ./extract_rois.sh -n -d
       -n: Name of subject
       -d: Home directory
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

SUBJECTS_DIR=$PROJECT_DIR/$SUBJECT/
SUBJECTS_DATA_DIR=$PROJECT_DIR/$SUBJECT/

export ALL_REGION_LABELS=("thalamus" "caudate" "putamen" "amygdala" "cerebellum") 
export ALL_REGION_NUM=("10 49" "11 50" "12 51" "18 54" "8 47") 
for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
ROI=${ALL_REGION_NUM[$r]}
echo "${ROI_LABEL}"
mkdir "$PROJECT_DIR"/"$SUBJECT"/labels
export ROI_LABEL_ORIG_PATH=$PROJECT_DIR/$SUBJECT/labels/$ROI_LABEL #this one orig is the file!
export ROI_LABEL_PATH=$PROJECT_DIR/$SUBJECT/labels/$ROI_LABEL #this is the output registered file 
export fastmap=$PROJECT_DIR/$SUBJECT/pet/fastmap

## Masks in anatomical space
        #first path is to anatomical file
        #number corresponds to ROIS
        #second path is name of new label file
        #third path is name of new nifti file
mri_extract_label "$SUBJECTS_DATA_DIR"/fs/mri/aparc+aseg.mgz $ROI "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii
echo mri_extract_label "$SUBJECTS_DATA_DIR"/fs/mri/aparc+aseg.mgz $ROI "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii
rsync -aP "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".bk.nii
mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/pet/template_for_reg/dynamic_template.nii.gz --targ "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/pet/reg/pet_template.reg.lta --inv --o "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}"_mask_in_dynamic_space.nii --no-save-reg --nearest
echo mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/pet/template_for_reg/dynamic_template.nii.gz --targ "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/pet/reg/pet_template.reg.lta --inv --o "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}"_mask_in_dynamic_space.nii --no-save-reg --nearest

done

ROI_ALL=$SUBJECTS_DIR/labels/${ROI_LABEL}_mask_in_dynamic_space.nii
if [ -f "$ROI_ALL" ]; then
     echo "${ROI_ALL##*/} already exists! "
  echo "${ROI_ALL##*/} done! All done, have a lovely day! "
else
  echo "${ROI_ALL##*/} failed! "
fi

#brainstem regions
export ALL_REGION_LABELS=("medulla" "SCP" "midbrain" "pons")
export ALL_REGION_NUM=("175" "178" "173" "174")

for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
echo ${ROI_LABEL}
ROI=${ALL_REGION_NUM[$r]}
mri_extract_label $PROJECT_DIR/$SUBJECT/fs/mri/brainstemSsLabels.v12.mgz $ROI $PROJECT_DIR/$SUBJECT/labels/${ROI_LABEL}.nii 
echo mri_extract_label $PROJECT_DIR/$SUBJECT/fs/mri/brainstemSsLabels.v12.mgz $ROI $PROJECT_DIR/$SUBJECT/labels/${ROI_LABEL}.nii 
rsync -aP "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".bk.nii
mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/pet/template_for_reg/dynamic_template.nii.gz --targ "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/pet/reg/pet_template.reg.lta --inv --o "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}"_mask_in_dynamic_space.nii --no-save-reg --nearest
echo mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/pet/template_for_reg/dynamic_template.nii.gz --targ "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/pet/reg/pet_template.reg.lta --inv --o "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}"_mask_in_dynamic_space.nii --no-save-reg --nearest

done

ROI_ALL=$SUBJECTS_DIR/labels/${ROI_LABEL}_mask_in_dynamic_space.nii
if [ -f "$ROI_ALL" ]; then
     echo "${ROI_ALL##*/} already exists! "
  echo "${ROI_ALL##*/} done! All done, have a lovely day! "
else
  echo "${ROI_ALL##*/} failed! "
fi

#brainstem regions
export ALL_REGION_LABELS=("cerebral_cortex")
export ALL_REGION_NUM=("3 42")

for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
ROI=${ALL_REGION_NUM[$r]}

#cortex
mri_extract_label "$SUBJECTS_DATA_DIR"/fs/mri/aseg.auto.mgz $ROI $PROJECT_DIR/$SUBJECT/labels/"${ROI_LABEL}".nii
mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/pet/template_for_reg/dynamic_template.nii.gz --targ "$SUBJECTS_DIR"/labels/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/pet/reg/pet_template.reg.lta --inv --o "$SUBJECTS_DATA_DIR"/labels/"${ROI_LABEL}"_mask_in_dynamic_space.nii --no-save-reg --nearest

done

ROI_ALL=$SUBJECTS_DIR/labels/"${ROI_LABEL}"_mask_in_dynamic_space.nii
if [ -f "$ROI_ALL" ]; then
     echo "${ROI_ALL##*/} already exists! "
  echo "${ROI_ALL##*/} done! All done, have a lovely day! "
else
  echo "${ROI_ALL##*/} failed! "
fi
