#!/bin/bash                                                                                               

# how to write it out: ./annot_lobes_to_niftis.sh -n az127 -d //data1/ninafultz/az_vig
# nina fultz may 2021

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to take annotation files and convert them into readable nifti files for fastmap
*************************************************************************************** "
    echo Usage: ./annot_lobes_to_niftis.sh -n -d
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

mri_annotation2label --subject fs/ \
  --hemi rh \
  --outdir $SUBJECTS_DIR/labels
  
mri_annotation2label --subject fs/ \
  --hemi lh \
  --outdir $SUBJECTS_DIR/labels

ALL_REGION_LABELS=("caudalanteriorcingulate" "rostralanteriorcingulate" "posteriorcingulate")

for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
echo ${ROI_LABEL}
    mri_mergelabels -i $SUBJECTS_DIR/labels/rh.${ROI_LABEL}.label -i $SUBJECTS_DIR/labels/lh.${ROI_LABEL}.label -o $SUBJECTS_DIR/labels/${ROI_LABEL}.label

done

mri_mergelabels -i $SUBJECTS_DIR/labels/caudalanteriorcingulate.label -i $SUBJECTS_DIR/labels/rostralanteriorcingulate.label -i $SUBJECTS_DIR/labels/posteriorcingulate.label -o $SUBJECTS_DIR/labels/cingulate.label
mri_mergelabels -i $SUBJECTS_DIR/labels/caudalanteriorcingulate.label -i $SUBJECTS_DIR/labels/rostralanteriorcingulate.label -o $SUBJECTS_DIR/labels/ACC.label

ALL_REGION_LABELS=("lateraloccipital" "lingual" "cuneus" "pericalcarine")

for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
echo ${ROI_LABEL}
    mri_mergelabels -i $SUBJECTS_DIR/labels/rh.${ROI_LABEL}.label -i $SUBJECTS_DIR/labels/lh.${ROI_LABEL}.label -o $SUBJECTS_DIR/labels/${ROI_LABEL}.label
done

mri_mergelabels -i $SUBJECTS_DIR/labels/lateraloccipital.label -i $SUBJECTS_DIR/labels/lingual.label -i $SUBJECTS_DIR/labels/cuneus.label -i $SUBJECTS_DIR/labels/pericalcarine.label -o $SUBJECTS_DIR/labels/occipital_cortex.label

ALL_REGION_LABELS=("ACC" "cingulate" "occipital_cortex")

for r in "${!ALL_REGION_LABELS[@]}"
do
ROI_LABEL=${ALL_REGION_LABELS[$r]}
echo ${ROI_LABEL}
rsync -aP $SUBJECTS_DIR/labels/${ROI_LABEL}.label $SUBJECTS_DIR/labels/${ROI_LABEL}.label.bk
mri_label2vol --label $SUBJECTS_DIR/labels/${ROI_LABEL}.label --temp $SUBJECTS_DIR/pet/template_for_reg/dynamic_template.nii.gz --o $SUBJECTS_DIR/labels/${ROI_LABEL}_mask_in_dynamic_space.nii --reg $SUBJECTS_DIR/pet/reg/pet_template.reg.lta
done

FINAL=$SUBJECTS_DIR/labels/${ROI_LABEL}.nii
   if [ -f $FINAL ]; then
      echo "${FINAL##*/} to annotation done! All done, have a lovely day! "
    else
      echo "${FINAL##*/} to annotation failed failed! "
    fi
