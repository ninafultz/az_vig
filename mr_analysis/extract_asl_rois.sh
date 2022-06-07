#!/bin/bash                                                                                                                                            

# how to write it out: ./extract_asl_rois.sh -n $SUBJECT -d //data1/ninafultz/az_vig -i Head_ep2d_pcasl_UI_PHC_LT1730PLD1500_p2
# nina fultz june 2022

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script for cortex to ts for az project
*************************************************************************************** "
    echo Usage: ./cortex_to_ts.sh -n -d
       -n: Name of subject
       -d: Home directory
       -i: Functional image or ASL image
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
        i) export IMAGE=$OPTARG ;;
    esac
done

#defining paths
export SUBJECTS_DATA_DIR=$PROJ_PATH/$SUBJECT_NAME
export TS=$PROJ_PATH/$SUBJECT_NAME/ts
mkdir $TS

export LABELS=$PROJ_PATH/$SUBJECT_NAME/labels
mkdir $LABELS

#extracting aparc+aseg.mgz and making labels
export ALL_REGION_LABELS=("thalamus" "caudate" "putamen" "amygdala" "cerebellum")
export ALL_REGION_NUM=("10 49" "11 50" "12 51" "18 54" "8 47") 

export ASL_DIR=$SUBJECTS_DATA_DIR/labels_asl
mkdir $ASL_DIR
echo $ASL_DIR

export ROI_LABEL_ORIG_PATH=$PROJECT_DIR/$SUBJECT/labels/$ROI_LABEL #this one orig is the file!

for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
ROI=${ALL_REGION_NUM[$r]}
echo "${ROI_LABEL}"

mri_extract_label "$SUBJECTS_DATA_DIR"/fs/mri/aparc+aseg.mgz $ROI $ASL_DIR/"${ROI_LABEL}".nii
mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --targ $ASL_DIR/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --inv --o $ASL_DIR/"${ROI_LABEL}"_mask.nii --no-save-reg --nearest
fslmeants -i "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii -m $ASL_DIR/"${ROI_LABEL}"_mask.nii -o "$SUBJECTS_DATA_DIR"/ts/"${ROI_LABEL}".txt
done

export ALL_REGION_LABELS=("medulla" "SCP" "midbrain" "pons") 
export ALL_REGION_NUM=("175" "178" "173" "174") 

for r in "${!ALL_REGION_LABELS[@]}"
do
    ROI_LABEL=${ALL_REGION_LABELS[$r]}
    ROI=${ALL_REGION_NUM[$r]}
    echo "${ROI_LABEL}"

    mri_extract_label "$SUBJECTS_DATA_DIR"/fs/mri/brainstemSsLabels.v12.mgz $ROI $ASL_DIR/"${ROI_LABEL}".nii
    mri_vol2vol --mov "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --targ $ASL_DIR/"${ROI_LABEL}".nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --inv --o $ASL_DIR/"${ROI_LABEL}"_mask.nii --no-save-reg --nearest
    fslmeants -i "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii -m $ASL_DIR/"${ROI_LABEL}"_mask.nii -o "$SUBJECTS_DATA_DIR"/ts/"${ROI_LABEL}".txt
done


ROI_LABEL=("cortex")

echo "${ROI_LABEL}"
#extracting cortex
mri_label2vol --label "$SUBJECTS_DATA_DIR"/fs/label/rh.cortex.label --temp  "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --o $ASL_DIR/rh_cortex.nii
echo mri_label2vol --label "$SUBJECTS_DATA_DIR"/fs/label/rh.cortex.label --temp  "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --o $ASL_DIR/rh_cortex.nii

mri_label2vol --label "$SUBJECTS_DATA_DIR"/fs/label/lh.cortex.label --temp  "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --o $ASL_DIR/lh_cortex.nii
echo mri_label2vol --label "$SUBJECTS_DATA_DIR"/fs/label/lh.cortex.label --temp  "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --o $ASL_DIR/lh_cortex.nii

fslmaths $ASL_DIR/rh_cortex.nii -add $ASL_DIR/lh_cortex.nii $ASL_DIR/cortex_mask.nii
fslmeants -i "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii -m $ASL_DIR/cortex_mask.nii -o "$SUBJECTS_DATA_DIR"/ts/whole_cortex.txt

mri_label2vol --label "$SUBJECTS_DATA_DIR"/labels/ACC.label --temp  "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --o $ASL_DIR/ACC_mask.nii
mri_label2vol --label "$SUBJECTS_DATA_DIR"/labels/occipital_cortex.label --temp  "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii --reg "$SUBJECTS_DATA_DIR"/reg/"$IMAGE"_mc_reg.dat --o $ASL_DIR/occipital_mask.nii
fslmeants -i "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii -m $ASL_DIR/ACC_mask.nii -o "$SUBJECTS_DATA_DIR"/ts/ACC.txt
fslmeants -i "$SUBJECTS_DATA_DIR"/mc/"$IMAGE"_mc2.nii -m $ASL_DIR/occipital_mask.nii -o "$SUBJECTS_DATA_DIR"/ts/occipital.txt

ROI_ALL=$ASL_DIR/${ROI_LABEL}_mask.nii
if [ -f "$ROI_ALL" ]; then
     echo "${ROI_ALL##*/} already exists! "
  echo "${ROI_ALL##*/} done! All done, have a lovely day! "
else
  echo "${ROI_ALL##*/} failed! "
fi
