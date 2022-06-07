#!/bin/bash

# how to write it out: ./formatting_fastmap_rois.sh -n racsleep06 -s SRTM2 -d /autofs/cluster/ldl/nina/pet_eeg_fmri/
#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to take graph.dat data from fastmap SRTM2 file and make it readable in matlab for figures!
*************************************************************************************** "
    echo Usage: ./formatting_fastmap_rois.sh -n -d
       -n: Name of subject
       -d: SRTM output directory
       -s: SRTM directory
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

while getopts "n:d:b:s:" opts;
do
    case $opts in
        n) SUBJECT=$OPTARG ;;
        d) PROJECT_DIR=$OPTARG ;;
        s) SRTM=$OPTARG ;;
    esac
done

export ROIS=$PROJECT_DIR/$SUBJECT/pet/fastmap_outputs/$SRTM/
echo $ROIS
export BP_RESULTS=$PROJECT_DIR/$SUBJECT/pet/fastmap_outputs/$SRTM/bp_results
mkdir $BP_RESULTS

rsync -aP $ROIS/graph.dat $BP_RESULTS/graph.txt
rsync -aP $BP_RESULTS/graph.txt $BP_RESULTS/graph.txt.bak

cd $BP_RESULTS
awk '$1~/^[0-9]+$/{print > out; next} {close(out); out=$3".txt"}' graph.txt

cd $ROIS
for label in putamen thalamus caudate amygdala midbrain medulla pons SCP cortex cerebellum ACC raphe_nuclei cingulate occipital
do
  echo "$label"

FILE=$BP_RESULTS/"$label".txt
if [ -f $FILE ]; then
   echo "File ${FILE##*/} exists. your ${ROI_NAME} txt files exist for analysis!"
   echo "All done! Have a lovely day!"
else
   echo "File ${FILE##*/} does not exist. Something went wrong! "
fi

done
